local Types = require(script.Parent.Types)

return function(Iris: Types.Iris): Types.Internal
    local Internal = {} :: Types.Internal

    Internal._version = [[ 2.5.2 ]]

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
    Internal._hasShownFatalError = false

    function Internal._HandleFatalError(errMessage: any)
        if Internal._hasShownFatalError then return end
        Internal._hasShownFatalError = true
        Iris.Disabled = true

        local reason = tostring(errMessage or "Unknown Rere Internal Error")

        local rootGui = Internal.parentInstance
        if not rootGui or not rootGui.Parent then
            local ok, hui = pcall(function()
                return (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
            end)
            rootGui = (ok and hui) or (game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui"))
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "Rere_FatalErrorModal"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999999
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset = true

        local modalBackdrop = Instance.new("Frame")
        modalBackdrop.Name = "ModalBackdrop"
        modalBackdrop.Size = UDim2.fromScale(1, 1)
        modalBackdrop.Position = UDim2.fromScale(0, 0)
        modalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        modalBackdrop.BackgroundTransparency = 0.45
        modalBackdrop.BorderSizePixel = 0
        modalBackdrop.Active = true
        modalBackdrop.Parent = screenGui

        local errorWindow = Instance.new("Frame")
        errorWindow.Name = "ErrorWindow"
        errorWindow.AnchorPoint = Vector2.new(0.5, 0.5)
        errorWindow.Position = UDim2.fromScale(0.5, 0.5)
        errorWindow.Size = UDim2.fromOffset(480, 320)
        errorWindow.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        errorWindow.BorderSizePixel = 0
        errorWindow.ClipsDescendants = true
        errorWindow.Parent = modalBackdrop

        local windowCorner = Instance.new("UICorner")
        windowCorner.CornerRadius = UDim.new(0, 10)
        windowCorner.Parent = errorWindow

        local windowStroke = Instance.new("UIStroke")
        windowStroke.Thickness = 2
        windowStroke.Color = Color3.fromRGB(230, 45, 45)
        windowStroke.Parent = errorWindow

        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 42)
        titleBar.Position = UDim2.fromScale(0, 0)
        titleBar.BackgroundColor3 = Color3.fromRGB(180, 25, 25)
        titleBar.BorderSizePixel = 0
        titleBar.Parent = errorWindow

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = titleBar

        local titleText = Instance.new("TextLabel")
        titleText.Name = "TitleText"
        titleText.Size = UDim2.new(1, -20, 1, 0)
        titleText.Position = UDim2.fromOffset(15, 0)
        titleText.BackgroundTransparency = 1
        titleText.Font = Enum.Font.GothamBold
        titleText.Text = "⚠️ Rere Error Encountered"
        titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleText.TextSize = 16
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.Parent = titleBar

        local warnDesc = Instance.new("TextLabel")
        warnDesc.Name = "WarnDesc"
        warnDesc.Size = UDim2.new(1, -30, 0, 30)
        warnDesc.Position = UDim2.fromOffset(15, 48)
        warnDesc.BackgroundTransparency = 1
        warnDesc.Font = Enum.Font.GothamMedium
        warnDesc.Text = "This Rere cannot be used due to an internal error."
        warnDesc.TextColor3 = Color3.fromRGB(255, 180, 180)
        warnDesc.TextSize = 14
        warnDesc.TextXAlignment = Enum.TextXAlignment.Left
        warnDesc.Parent = errorWindow

        local reasonLabel = Instance.new("TextLabel")
        reasonLabel.Name = "ReasonLabel"
        reasonLabel.Size = UDim2.new(1, -30, 0, 20)
        reasonLabel.Position = UDim2.fromOffset(15, 80)
        reasonLabel.BackgroundTransparency = 1
        reasonLabel.Font = Enum.Font.GothamBold
        reasonLabel.Text = "Reason:"
        reasonLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
        reasonLabel.TextSize = 14
        reasonLabel.TextXAlignment = Enum.TextXAlignment.Left
        reasonLabel.Parent = errorWindow

        local reasonScroll = Instance.new("ScrollingFrame")
        reasonScroll.Name = "ReasonScroll"
        reasonScroll.Size = UDim2.new(1, -30, 0, 130)
        reasonScroll.Position = UDim2.fromOffset(15, 104)
        reasonScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
        reasonScroll.BorderSizePixel = 0
        reasonScroll.CanvasSize = UDim2.fromScale(0, 0)
        reasonScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        reasonScroll.ScrollBarThickness = 6
        reasonScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
        reasonScroll.Parent = errorWindow

        local reasonCorner = Instance.new("UICorner")
        reasonCorner.CornerRadius = UDim.new(0, 6)
        reasonCorner.Parent = reasonScroll

        local reasonStroke = Instance.new("UIStroke")
        reasonStroke.Thickness = 1
        reasonStroke.Color = Color3.fromRGB(50, 50, 58)
        reasonStroke.Parent = reasonScroll

        local reasonText = Instance.new("TextLabel")
        reasonText.Name = "ReasonText"
        reasonText.Size = UDim2.new(1, -16, 0, 0)
        reasonText.Position = UDim2.fromOffset(8, 8)
        reasonText.AutomaticSize = Enum.AutomaticSize.Y
        reasonText.BackgroundTransparency = 1
        reasonText.Font = Enum.Font.Code
        reasonText.Text = reason
        reasonText.TextColor3 = Color3.fromRGB(240, 240, 245)
        reasonText.TextSize = 13
        reasonText.TextWrapped = true
        reasonText.TextXAlignment = Enum.TextXAlignment.Left
        reasonText.TextYAlignment = Enum.TextYAlignment.Top
        reasonText.Parent = reasonScroll

        local btnContainer = Instance.new("Frame")
        btnContainer.Name = "BtnContainer"
        btnContainer.Size = UDim2.new(1, -30, 0, 42)
        btnContainer.Position = UDim2.new(0, 15, 1, -55)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = errorWindow

        local copyBtn = Instance.new("TextButton")
        copyBtn.Name = "CopyBtn"
        copyBtn.Size = UDim2.new(0.48, 0, 1, 0)
        copyBtn.Position = UDim2.fromScale(0, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
        copyBtn.BorderSizePixel = 0
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.Text = "📋 Copy Reason"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.TextSize = 14
        copyBtn.Parent = btnContainer

        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 6)
        copyCorner.Parent = copyBtn

        copyBtn.MouseButton1Click:Connect(function()
            local copyFunc = (type(setclipboard) == "function" and setclipboard) or (type(toclipboard) == "function" and toclipboard)
            if copyFunc then
                copyFunc(reason)
                copyBtn.Text = "✅ Copied to Clipboard!"
                task.delay(2, function()
                    if copyBtn and copyBtn.Parent then
                        copyBtn.Text = "📋 Copy Reason"
                    end
                end)
            else
                copyBtn.Text = "⚠️ Clipboard not supported"
            end
        end)

        local exitBtn = Instance.new("TextButton")
        exitBtn.Name = "ExitBtn"
        exitBtn.Size = UDim2.new(0.48, 0, 1, 0)
        exitBtn.Position = UDim2.new(0.52, 0, 0, 0)
        exitBtn.BackgroundColor3 = Color3.fromRGB(190, 35, 35)
        exitBtn.BorderSizePixel = 0
        exitBtn.Font = Enum.Font.GothamBold
        exitBtn.Text = "❌ Exit Rere"
        exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        exitBtn.TextSize = 14
        exitBtn.Parent = btnContainer

        local exitCorner = Instance.new("UICorner")
        exitCorner.CornerRadius = UDim.new(0, 6)
        exitCorner.Parent = exitBtn

        exitBtn.MouseButton1Click:Connect(function()
            pcall(function() screenGui:Destroy() end)
            pcall(function() Iris.Shutdown() end)
        end)

        screenGui.Parent = rootGui
    end

    Internal._cycleCoroutine = coroutine.create(function()
        while Internal._started do
            for _, callback in Internal._connectedFunctions do
                debug.profilebegin("Iris/Connection")
                local status, _error: string = pcall(callback)
                debug.profileend()
                if not status then
                    Internal._stackIndex = 1
                    coroutine.yield(false, _error)
                end
            end
            coroutine.yield(true)
        end
    end)

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
                Internal._widgets[thisWidget.type].UpdateState(thisWidget)
            end
        end

        for _, callback in self.ConnectedFunctions do
            callback(newValue)
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

    function Internal._cycle(deltaTime: number)
        if Iris.Disabled then
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
                callback()
            end
        end)

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
            local _, success, result = coroutine.resume(Internal._cycleCoroutine)
            if success == false then
                Internal._HandleFatalError(result)
                return
            end
        elseif coroutineStatus == "running" then
            Internal._HandleFatalError("Iris cycleCoroutine took too long to yield. Connected functions should not yield.")
            return
        else
            Internal._HandleFatalError("Unrecoverable Rere state (coroutine status: " .. tostring(coroutineStatus) .. ")")
            return
        end

        if Internal._stackIndex ~= 1 then
            Internal._stackIndex = 1
            Internal._HandleFatalError("Too few calls to Iris.End().")
            return
        end

        if #Internal._pushedIds ~= 0 then
            table.clear(Internal._pushedIds)
            Internal._HandleFatalError("Too few calls to Iris.PopId().")
            return
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
        local ID = thisWidget.ID .. stateName
        if Internal._states[ID] then
            Internal._states[ID].ConnectedWidgets[thisWidget.ID] = thisWidget
            Internal._states[ID].lastChangeTick = Internal._cycleTick
            return Internal._states[ID]
        else
            local newState = {
                ID = ID,
                value = initialValue,
                lastChangeTick = Internal._cycleTick,
                ConnectedWidgets = { [thisWidget.ID] = thisWidget },
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
