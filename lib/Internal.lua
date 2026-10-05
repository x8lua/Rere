local Types = require(script.Parent.Types)
local CrashPopup = require(script.Parent.CrashPopup)

return function(Iris: Types.Iris): Types.Internal
    local Internal = {} :: Types.Internal

    Internal._version = [[ 2.5.3 ]]

    Internal._started = false
    Internal._shutdown = false
    Internal._cycleTick = 0
    Internal._deltaTime = 0

    Internal._globalRefreshRequested = false
    Internal._refreshCounter = 0
    Internal._refreshLevel = 1
    Internal._refreshStack = table.create(16)

    Internal._widgets = {}
    Internal._stackIndex = 1
    Internal._rootInstance = nil
    Internal._rootWidget = {
        ID = "R",
        type = "Root",
        Instance = Internal._rootInstance,
        ZIndex = 0,
        ZOffset = 0,
    }
    Internal._lastWidget = Internal._rootWidget

    Internal._rootConfig = {}
    Internal._config = Internal._rootConfig

    Internal._IDStack = { "R" }
    Internal._usedIDs = {}
    Internal._pushedIds = {}
    Internal._newID = false
    Internal._nextWidgetId = nil

    Internal._states = {}

    Internal._postCycleCallbacks = {}
    Internal._connectedFunctions = {}
    Internal._connections = {}
    Internal._initFunctions = {}

    Internal._fullErrorTracebacks = game:GetService("RunService"):IsStudio()
    
    Internal._errored = false
    Internal._errorReason = ""
    Internal._crashOptions = {}
    Internal._crashPopup = nil
    Internal._notice = nil
    Internal._noticeQueue = {}
    Internal._noticeEntries = {}
    Internal._mutedErrors = {}
    Internal._unusableSince = nil
    Internal._unusableFrames = 0

    function Internal._DismissNotices()
        local notice = Internal._notice
        Internal._notice = nil
        table.clear(Internal._noticeQueue)
        table.clear(Internal._noticeEntries)
        if notice and notice.gui then notice.gui:Destroy() end
    end

    local function showNextNotice()
        if Internal._notice or Internal._shutdown then return end
        local entry
        while #Internal._noticeQueue > 0 do
            local nextEntry = table.remove(Internal._noticeQueue, 1)
            if not Internal._mutedErrors[nextEntry.key] then
                entry = nextEntry
                break
            end
            Internal._noticeEntries[nextEntry.key] = nil
        end
        if not entry then return end
        Internal._notice = entry
        entry.OnMute = function(muted)
            Internal._mutedErrors[entry.key] = muted or nil
        end
        entry.OnDismiss = function()
            if Internal._notice ~= entry then return end
            Internal._notice = nil
            Internal._noticeEntries[entry.key] = nil
            showNextNotice()
        end
        entry.gui, entry.card = CrashPopup(Iris, entry.reason, Internal._crashOptions, entry)
    end

    function Internal._RecordRuntimeError(errMessage: any, critical: boolean?): boolean
        if Internal._errored then return true end
        if Internal._shutdown or not Internal._started then return false end
        local reason = tostring(errMessage or "Unknown Rere runtime error")
        if critical then
            Internal._HandleFatalError(reason)
            return true
        end
        -- The failing source line identifies the error; changing caller traces do not.
        local key = reason:match("^[^\r\n]+") or reason
        if Internal._mutedErrors[key] then return false end
        local existing = Internal._noticeEntries[key]
        if existing then
            existing.count += 1
            if existing.UpdateCount then existing.UpdateCount(existing.count) end
            return false
        end
        if #Internal._noticeQueue >= 32 then return false end
        local entry = {key = key, reason = reason, count = 1}
        Internal._noticeEntries[key] = entry
        table.insert(Internal._noticeQueue, entry)
        showNextNotice()
        return false
    end

    function Internal._HandleFatalError(errMessage: any)
        if Internal._errored or Internal._shutdown then return end
        Internal._errored = true
        Internal._errorReason = tostring(errMessage or "Unknown Rere Internal Error")
        local options = Internal._crashOptions
        -- Capture options before consumer cleanup calls Shutdown again.
        local shutdownOK, shutdownError = pcall(Iris.Shutdown)
        if not shutdownOK then
            Internal._errorReason ..= "\nShutdown error: " .. tostring(shutdownError)
        end
        if type(options.OnTerminate) == "function" then
            local ok, err = pcall(options.OnTerminate, Internal._errorReason)
            if not ok then Internal._errorReason ..= "\nCleanup error: " .. tostring(err) end
        end
        Internal._crashPopup, Internal._crashCard = CrashPopup(Iris, Internal._errorReason, options)
    end

    function Internal._ResetRenderContext()
        Internal._stackIndex = 1
        table.clear(Internal._IDStack)
        Internal._IDStack[1] = "R"
        table.clear(Internal._pushedIds)
        Internal._nextWidgetId = nil
        Internal._config = Internal._rootConfig
        Internal._refreshLevel = 1
        Internal._refreshCounter = 0
        table.clear(Internal._refreshStack)
        Internal._lastWidget = Internal._rootWidget
    end

    local function trackUnusableFrame(reason, usable)
        if usable then
            Internal._unusableSince = nil
            Internal._unusableFrames = 0
            return
        end
        Internal._unusableSince = Internal._unusableSince or os.clock()
        Internal._unusableFrames += 1
        if Internal._unusableFrames >= 3
            and os.clock() - Internal._unusableSince >= (Internal._crashOptions.UnusableSeconds or 5) then
            Internal._HandleFatalError("The entire UI could not recover.\n" .. tostring(reason))
        end
    end

    local function hasUsableControls()
        if type(Internal._VDOM) ~= "table" then return false end
        for _, widget in Internal._VDOM do
            local class = Internal._widgets[widget.type]
            local interactive = class and ((class.hasState and not class.hasChildren)
                or (class.Events and class.Events.clicked))
            if interactive and widget.Instance and widget.Instance.Parent
                and widget.Instance:IsA("GuiObject") and widget.Instance.Visible then
                local visible = true
                local ancestor = widget.Instance.Parent
                while ancestor and ancestor ~= Internal.parentInstance do
                    if (ancestor:IsA("GuiObject") and not ancestor.Visible)
                        or (ancestor:IsA("ScreenGui") and not ancestor.Enabled) then
                        visible = false
                        break
                    end
                    ancestor = ancestor.Parent
                end
                if visible then return true end
            end
        end
        return false
    end

    local function createCycleCoroutine()
        return coroutine.create(function()
            while Internal._started do
                local successful = 0
                local attempted = 0
                local lastError
                for _, callback in Internal._connectedFunctions do
                    if Internal._shutdown then break end
                    attempted += 1
                    debug.profilebegin("Iris/Connection")
                    local status, err = xpcall(callback, debug.traceback)
                    debug.profileend()
                    if status and (Internal._stackIndex ~= 1 or #Internal._pushedIds ~= 0
                        or Internal._refreshLevel ~= 1) then
                        status = false
                        err = "Unbalanced Rere Window/End, PushId/PopId or PushConfig/PopConfig calls."
                    end
                    if status then
                        successful += 1
                    else
                        lastError = err
                        Internal._ResetRenderContext()
                        Internal._RecordRuntimeError(err)
                    end
                end
                coroutine.yield(true, {successful = successful, attempted = attempted, reason = lastError})
            end
        end)
    end
    Internal._cycleCoroutine = createCycleCoroutine()

    local StateClass = {}
    StateClass.__index = StateClass

    function StateClass:get<T>()
        return self.value
    end

    function StateClass:set<T>(newValue: T, force: true?)
        if newValue == self.value and force ~= true then
            return self.value
        end
        self.value = newValue
        self.lastChangeTick = Iris.Internal._cycleTick
        for _, thisWidget: Types.Widget in self.ConnectedWidgets do
            if thisWidget.lastCycleTick ~= -1 then
                local ok, err = xpcall(Internal._widgets[thisWidget.type].UpdateState, debug.traceback, thisWidget)
                if not ok then Internal._RecordRuntimeError(err) end
            end
        end

        for _, callback in self.ConnectedFunctions do
            local ok, err = xpcall(callback, debug.traceback, newValue)
            if not ok then Internal._RecordRuntimeError(err) end
        end
        return self.value
    end

    function StateClass:onChange<T>(callback: (newValue: T) -> ())
        local connectionIndex: number = #self.ConnectedFunctions + 1
        self.ConnectedFunctions[connectionIndex] = callback
        return function()
            self.ConnectedFunctions[connectionIndex] = nil
        end
    end

    function StateClass:changed<T>()
        return self.lastChangeTick + 1 == Internal._cycleTick
    end

    Internal.StateClass = StateClass

    local function cycle(deltaTime: number)
        if Iris.Disabled or Internal._shutdown or Internal._errored then
            return
        end

        Internal._rootWidget.lastCycleTick = Internal._cycleTick
        if Internal._rootInstance == nil or Internal._rootInstance.Parent == nil then
            Iris.ForceRefresh()
        end

        for _, widget in Internal._lastVDOM do
            if widget.lastCycleTick ~= Internal._cycleTick and (widget.lastCycleTick ~= -1) then
                Internal._DiscardWidget(widget)
            end
        end

        setmetatable(Internal._lastVDOM, { __mode = "kv" })
        Internal._lastVDOM = Internal._VDOM
        Internal._VDOM = Internal._generateEmptyVDOM()

        task.spawn(function()
            for _, callback in Internal._postCycleCallbacks do
                if Internal._shutdown then return end
                local ok, err = xpcall(callback, debug.traceback)
                if not ok then Internal._RecordRuntimeError(err) end
            end
        end)
        if Internal._shutdown then return end

        if Internal._globalRefreshRequested then
            Internal._generateSelectionImageObject()
            Internal._globalRefreshRequested = false
            for _, widget in Internal._lastVDOM do
                Internal._DiscardWidget(widget)
            end
            Internal._generateRootInstance()
            Internal._lastVDOM = Internal._generateEmptyVDOM()
        end

        Internal._cycleTick += 1
        Internal._deltaTime = deltaTime
        table.clear(Internal._usedIDs)

        local compatibleParent = (Internal.parentInstance:IsA("GuiBase2d") or Internal.parentInstance:IsA("BasePlayerGui"))
        if compatibleParent == false then
            Internal._HandleFatalError("The Iris parent instance will not display any GUIs.")
            return
        end

        local coroutineStatus = coroutine.status(Internal._cycleCoroutine)
        if coroutineStatus == "suspended" then
            local resumed, success, result = coroutine.resume(Internal._cycleCoroutine)
            if not resumed or success == false then
                local reason = resumed and result or success
                Internal._RecordRuntimeError(reason)
                Internal._ResetRenderContext()
                Internal._cycleCoroutine = createCycleCoroutine()
                trackUnusableFrame(reason, hasUsableControls())
                return
            end
            if type(result) == "table" then
                trackUnusableFrame(result.reason, result.attempted == 0 or result.successful > 0 or hasUsableControls())
            end
        elseif coroutineStatus == "running" then
            local reason = "Rere UI callback is still waiting. Connected functions should not yield."
            Internal._RecordRuntimeError(reason)
            trackUnusableFrame(reason, hasUsableControls())
            return
        else
            local reason = "Rere renderer needs recovery (coroutine status: " .. tostring(coroutineStatus) .. ")"
            Internal._RecordRuntimeError(reason)
            Internal._ResetRenderContext()
            Internal._cycleCoroutine = createCycleCoroutine()
            trackUnusableFrame(reason, hasUsableControls())
            return
        end

        if Internal._stackIndex ~= 1 then
            Internal._ResetRenderContext()
            Internal._RecordRuntimeError("Too few calls to Iris.End().")
            return
        end

        if #Internal._pushedIds ~= 0 then
            Internal._ResetRenderContext()
            Internal._RecordRuntimeError("Too few calls to Iris.PopId().")
            return
        end
    end

    function Internal._cycle(deltaTime: number)
        if Internal._shutdown or Internal._errored then return end
        local ok, err = xpcall(cycle, debug.traceback, deltaTime)
        if not ok then
            Internal._ResetRenderContext()
            Internal._RecordRuntimeError(err)
            Internal._globalRefreshRequested = true
            trackUnusableFrame(err, hasUsableControls())
        end
    end

    function Internal._NoOp() end

    function Internal.WidgetConstructor(type: string, widgetClass: Types.WidgetClass)
        local Fields = {
            All = {
                Required = {
                    "Generate",
                    "Discard",
                    "Update",
                    "Args",
                    "Events",
                    "hasChildren",
                    "hasState",
                },
                Optional = {},
            },
            IfState = {
                Required = {
                    "GenerateState",
                    "UpdateState",
                },
                Optional = {},
            },
            IfChildren = {
                Required = {
                    "ChildAdded",
                },
                Optional = {
                    "ChildDiscarded",
                },
            },
        }

        local thisWidget = {} :: Types.WidgetClass
        for _, field in Fields.All.Required do
            assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets`)
            thisWidget[field] = widgetClass[field]
        end

        for _, field in Fields.All.Optional do
            if widgetClass[field] == nil then
                thisWidget[field] = Internal._NoOp
            else
                thisWidget[field] = widgetClass[field]
            end
        end

        if widgetClass.hasState then
            for _, field in Fields.IfState.Required do
                assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with state`)
                thisWidget[field] = widgetClass[field]
            end
            for _, field in Fields.IfState.Optional do
                if widgetClass[field] == nil then
                    thisWidget[field] = Internal._NoOp
                else
                    thisWidget[field] = widgetClass[field]
                end
            end
        end

        if widgetClass.hasChildren then
            for _, field in Fields.IfChildren.Required do
                assert(widgetClass[field] ~= nil, `field {field} is missing from widget {type}, it is required for all widgets with children`)
                thisWidget[field] = widgetClass[field]
            end
            for _, field in Fields.IfChildren.Optional do
                if widgetClass[field] == nil then
                    thisWidget[field] = Internal._NoOp
                else
                    thisWidget[field] = widgetClass[field]
                end
            end
        end

        Internal._widgets[type] = thisWidget
        Iris.Args[type] = thisWidget.Args

        local ArgNames = {}
        for index, argument in thisWidget.Args do
            ArgNames[argument] = index
        end
        thisWidget.ArgNames = ArgNames

        for index, _ in thisWidget.Events do
            if Iris.Events[index] == nil then
                Iris.Events[index] = function()
                    return Internal._EventCall(Internal._lastWidget, index)
                end
            end
        end
    end

    function Internal._Insert(widgetType: string, args: Types.WidgetArguments?, states: Types.WidgetStates?)
        local ID = Internal._getID(3)

        local thisWidgetClass = Internal._widgets[widgetType]

        if Internal._VDOM[ID] then
            return Internal._ContinueWidget(ID, widgetType)
        end

        local arguments = {} :: Types.Arguments
        if args ~= nil then
            if type(args) ~= "table" then
                args = { args }
            end

            for index, argument in args do
                assert(index > 0, `Widget Arguments must be a positive number, not {index} of type {typeof(index)} for {argument}.`)
                arguments[thisWidgetClass.ArgNames[index]] = argument
            end
        end
        table.freeze(arguments)

        local lastWidget = Internal._lastVDOM[ID]
        if lastWidget then
            if Internal._refreshCounter > 0 or widgetType ~= lastWidget.type then
                Internal._DiscardWidget(lastWidget)
                lastWidget = nil
            end
        end
        local thisWidget = if lastWidget == nil then Internal._GenNewWidget(widgetType, arguments, states, ID) else lastWidget

        local parentWidget = thisWidget.parentWidget

        if thisWidget.type ~= "Window" and thisWidget.type ~= "Tooltip" then
            if thisWidget.ZIndex ~= parentWidget.ZOffset then
                parentWidget.ZUpdate = true
            end

            if parentWidget.ZUpdate then
                thisWidget.ZIndex = parentWidget.ZOffset
                if thisWidget.Instance then
                    thisWidget.Instance.ZIndex = thisWidget.ZIndex
                    thisWidget.Instance.LayoutOrder = thisWidget.ZIndex
                end
            end
        end

        if parentWidget.type == "Table" then
            local Table = parentWidget :: Types.Table
            Table._rowCycles[Table._rowIndex] = Internal._cycleTick
        end

        if Internal._deepCompare(thisWidget.providedArguments, arguments) == false then
            thisWidget.arguments = Internal._deepCopy(arguments)
            thisWidget.providedArguments = arguments
            thisWidgetClass.Update(thisWidget)
        end

        thisWidget.lastCycleTick = Internal._cycleTick
        parentWidget.ZOffset += 1

        if thisWidgetClass.hasChildren then
            local thisParent = thisWidget :: Types.ParentWidget
            thisParent.ZOffset = 0
            thisParent.ZUpdate = false
            Internal._stackIndex += 1
            Internal._IDStack[Internal._stackIndex] = thisWidget.ID
        end

        Internal._VDOM[ID] = thisWidget
        Internal._lastWidget = thisWidget

        return thisWidget
    end

    function Internal._GenNewWidget(widgetType: string, arguments: Types.Arguments, states: Types.WidgetStates?, ID: Types.ID)
        local parentId = Internal._IDStack[Internal._stackIndex]
        local parentWidget: Types.ParentWidget = Internal._VDOM[parentId]
        local thisWidgetClass = Internal._widgets[widgetType]

        local thisWidget = {} :: Types.Widget
        setmetatable(thisWidget, thisWidget)

        thisWidget.ID = ID
        thisWidget.type = widgetType
        thisWidget.parentWidget = parentWidget
        thisWidget.trackedEvents = {}

        thisWidget.ZIndex = parentWidget.ZOffset

        thisWidget.Instance = thisWidgetClass.Generate(thisWidget)
        parentWidget = thisWidget.parentWidget

        if Internal._config.Parent then
            thisWidget.Instance.Parent = Internal._config.Parent
        else
            thisWidget.Instance.Parent = Internal._widgets[parentWidget.type].ChildAdded(parentWidget, thisWidget)
        end

        thisWidget.providedArguments = arguments
        thisWidget.arguments = Internal._deepCopy(arguments)
        thisWidgetClass.Update(thisWidget)

        local eventMTParent
        if thisWidgetClass.hasState then
            local stateWidget = thisWidget :: Types.StateWidget
            if states then
                for index, state in states do
                    if not (type(state) == "table" and getmetatable(state :: any) == Internal.StateClass) then
                        states[index] = Internal._widgetState(stateWidget, index, state)
                    end
                    states[index].lastChangeTick = Internal._cycleTick
                end

                stateWidget.state = states
                for _, state in states do
                    state.ConnectedWidgets[stateWidget.ID] = stateWidget
                end
            else
                stateWidget.state = {}
            end

            thisWidgetClass.GenerateState(stateWidget)
            thisWidgetClass.UpdateState(stateWidget)

            stateWidget.stateMT = {}
            setmetatable(stateWidget.state, stateWidget.stateMT)

            stateWidget.__index = stateWidget.state
            eventMTParent = stateWidget.stateMT
        else
            eventMTParent = thisWidget
        end

        eventMTParent.__index = function(_, eventName)
            return function()
                return Internal._EventCall(thisWidget, eventName)
            end
        end
        return thisWidget
    end

    function Internal._ContinueWidget(ID: Types.ID, widgetType: string)
        local thisWidgetClass = Internal._widgets[widgetType]
        local thisWidget = Internal._VDOM[ID]

        if thisWidgetClass.hasChildren then
            Internal._stackIndex += 1
            Internal._IDStack[Internal._stackIndex] = thisWidget.ID
        end

        Internal._lastWidget = thisWidget
        return thisWidget
    end

    function Internal._DiscardWidget(widgetToDiscard: Types.Widget)
        local widgetParent = widgetToDiscard.parentWidget
        if widgetParent then
            Internal._widgets[widgetParent.type].ChildDiscarded(widgetParent, widgetToDiscard)
        end

        Internal._widgets[widgetToDiscard.type].Discard(widgetToDiscard)
        widgetToDiscard.lastCycleTick = -1
    end

    function Internal._widgetState<T>(thisWidget: Types.StateWidget, stateName: string, initialValue: T)
        local ID = thisWidget and (thisWidget.ID .. stateName) or stateName
        if Internal._states[ID] then
            if thisWidget then
                Internal._states[ID].ConnectedWidgets[thisWidget.ID] = thisWidget
            end
            Internal._states[ID].lastChangeTick = Internal._cycleTick
            return Internal._states[ID]
        else
            local newState = {
                ID = ID,
                value = initialValue,
                lastChangeTick = Internal._cycleTick,
                ConnectedWidgets = thisWidget and { [thisWidget.ID] = thisWidget } or {},
                ConnectedFunctions = {},
            } :: Types.State<T>
            setmetatable(newState, Internal.StateClass)
            Internal._states[ID] = newState
            return newState
        end
    end

    function Internal._EventCall(thisWidget: Types.Widget, eventName: string)
        local Events = Internal._widgets[thisWidget.type].Events
        local Event = Events[eventName]
        assert(Event ~= nil, `widget {thisWidget.type} has no event of name {eventName}`)

        if thisWidget.trackedEvents[eventName] == nil then
            Event.Init(thisWidget)
            thisWidget.trackedEvents[eventName] = true
        end
        return Event.Get(thisWidget)
    end

    function Internal._GetParentWidget(): Types.ParentWidget
        return Internal._VDOM[Internal._IDStack[Internal._stackIndex]]
    end

    function Internal._generateEmptyVDOM()
        return {
            ["R"] = Internal._rootWidget,
        }
    end

    function Internal._generateRootInstance()
        Internal._rootInstance = Internal._widgets["Root"].Generate(Internal._widgets["Root"])
        Internal._rootInstance.Parent = Internal.parentInstance
        Internal._rootWidget.Instance = Internal._rootInstance
    end

    function Internal._generateSelectionImageObject()
        if Internal.SelectionImageObject then
            Internal.SelectionImageObject:Destroy()
        end

        local SelectionImageObject = Instance.new("Frame")
        SelectionImageObject.Position = UDim2.fromOffset(-1, -1)
        SelectionImageObject.Size = UDim2.new(1, 2, 1, 2)
        SelectionImageObject.BackgroundColor3 = Internal._config.SelectionImageObjectColor
        SelectionImageObject.BackgroundTransparency = Internal._config.SelectionImageObjectTransparency
        SelectionImageObject.BorderSizePixel = 0

        Internal._utility.UIStroke(SelectionImageObject, 1, Internal._config.SelectionImageObjectBorderColor, Internal._config.SelectionImageObjectBorderTransparency)
        Internal._utility.UICorner(SelectionImageObject, 2)

        Internal.SelectionImageObject = SelectionImageObject
    end

    function Internal._getID(levelsToIgnore: number)
        if Internal._nextWidgetId then
            local ID = Internal._nextWidgetId
            Internal._nextWidgetId = nil
            return ID
        end

        local i = 1 + (levelsToIgnore or 1)
        local ID = ""
        local levelInfo = debug.info(i, "l")
        while levelInfo ~= -1 and levelInfo ~= nil do
            ID ..= "+" .. levelInfo
            i += 1
            levelInfo = debug.info(i, "l")
        end

        local discriminator = Internal._usedIDs[ID]
        if discriminator then
            Internal._usedIDs[ID] += 1
            discriminator += 1
        else
            Internal._usedIDs[ID] = 1
            discriminator = 1
        end

        if #Internal._pushedIds == 0 then
            return ID .. ":" .. discriminator
        elseif Internal._newID then
            Internal._newID = false
            return ID .. "::" .. table.concat(Internal._pushedIds, "\\")
        else
            return ID .. ":" .. discriminator .. ":" .. table.concat(Internal._pushedIds, "\\")
        end
    end

    function Internal._deepCompare(t1: {}, t2: {})
        for i, v1 in t1 do
            local v2 = t2[i]
            if type(v1) == "table" then
                if v2 and type(v2) == "table" then
                    if Internal._deepCompare(v1, v2) == false then
                        return false
                    end
                else
                    return false
                end
            else
                if type(v1) ~= type(v2) or v1 ~= v2 then
                    return false
                end
            end
        end

        return true
    end

    function Internal._deepCopy(t: {}): {}
        local copy: {} = table.clone(t)

        for k, v in t do
            if type(v) == "table" then
                copy[k] = Internal._deepCopy(v)
            end
        end

        return copy
    end

    Internal._lastVDOM = Internal._generateEmptyVDOM()
    Internal._VDOM = Internal._generateEmptyVDOM()

    Iris.Internal = Internal
    Iris._config = Internal._config
    return Internal
end
