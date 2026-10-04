--!nocheck
-- One keyboard listener per library instance. Bindings outlive tab widget disposal.
return function(Internal, widgets)
    local manager = {entries = {}, capture = nil, conflict = nil, options = {}}
    Internal._keybinds = manager
    local UIS = widgets.UserInputService

    local function keyName(value)
        if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then return value.Name end
        if value == "None" then return value end
        if type(value) == "string" and Enum.KeyCode[value] and value ~= "Unknown" then return value end
        return "None"
    end
    local function notify(name, value)
        local callback = manager.options[name]
        if callback then callback(value) end
    end
    local function refresh(entry)
        for button in pairs(entry.buttons) do
            if button.Parent then
                button.Text = manager.capture == entry.id and "..." or keyName(entry.keybind.value)
            else entry.buttons[button] = nil end
        end
    end
    function manager.Register(keybind, action, label)
        assert(type(keybind) == "table" and type(keybind.set) == "function", "Keybind requires a Rere State")
        local id = keybind.ID
        local entry = manager.entries[id]
        if not entry then
            entry = {id = id, keybind = keybind, buttons = {}}
            manager.entries[id] = entry
            entry.disconnect = keybind:onChange(function() refresh(entry) end)
        end
        entry.action = action
        entry.label = label or entry.label or id
        return entry
    end
    function manager.Unregister(keybind)
        local id = keybind.ID
        if manager.capture == id then manager.Cancel() end
        if manager.conflict then manager.Resolve(false) end
        local entry = manager.entries[id]
        if entry and entry.disconnect then entry.disconnect() end
        manager.entries[id] = nil
    end
    function manager.Cancel()
        local previous = manager.entries[manager.capture]
        manager.capture = nil
        if previous then refresh(previous) end
        notify("OnCaptureChanged", nil)
    end
    function manager.Begin(keybind)
        local entry = manager.entries[keybind.ID]
        assert(entry, "Register this keybind before capturing it")
        manager.Cancel()
        if manager.conflict then manager.Resolve(false) end
        manager.capture = entry.id
        refresh(entry)
        notify("OnCaptureChanged", entry.id)
    end
    function manager.Assign(entry, name)
        local conflicts = {}
        if name ~= "None" then
            for _, other in pairs(manager.entries) do
                if other.id ~= entry.id and keyName(other.keybind.value) == name then
                    table.insert(conflicts, other)
                end
            end
        end
        if #conflicts > 0 then
            table.sort(conflicts, function(a, b) return a.label < b.label end)
            manager.conflict = {entry = entry, name = name, conflicts = conflicts}
            manager.dialogOpened = nil
            notify("OnConflictChanged", manager.conflict)
        else entry.keybind:set(name) end
    end
    function manager.Resolve(move)
        local conflict = manager.conflict
        if not conflict then return end
        manager.conflict = nil
        if move then
            -- Recheck current values: bindings may have changed while the dialog was open.
            for _, entry in pairs(manager.entries) do
                if entry.id ~= conflict.entry.id and keyName(entry.keybind.value) == conflict.name then
                    entry.keybind:set("None")
                end
            end
            conflict.entry.keybind:set(conflict.name)
        end
        notify("OnConflictChanged", nil)
    end
    function manager.Cleanup()
        manager.Cancel()
        manager.Resolve(false)
        for _, entry in pairs(manager.entries) do
            if entry.disconnect then entry.disconnect() end
            table.clear(entry.buttons); entry.action = nil
        end
        table.clear(manager.entries)
    end
    widgets.registerEvent("InputBegan", function(event, processed)
        if not Internal._started or Internal._shutdown then return end
        if event.UserInputType ~= Enum.UserInputType.Keyboard or event.KeyCode == Enum.KeyCode.Unknown then return end
        if manager.capture then
            if UIS:GetFocusedTextBox() then return end
            local entry = manager.entries[manager.capture]
            manager.Cancel()
            if entry then manager.Assign(entry, event.KeyCode == Enum.KeyCode.Escape and "None" or event.KeyCode.Name) end
            return
        end
        if manager.conflict then
            if event.KeyCode == Enum.KeyCode.Escape then manager.Resolve(false) end
            return
        end
        if processed or UIS:GetFocusedTextBox() then return end
        if manager.options.CanTrigger and not manager.options.CanTrigger() then return end
        local selected
        for _, entry in pairs(manager.entries) do
            if keyName(entry.keybind.value) == event.KeyCode.Name and entry.action then
                -- A config with duplicate keys is ambiguous: do not toggle several controls.
                if selected then return end
                selected = entry
            end
        end
        if selected then
            selected.action()
            notify("OnTriggered", selected.id)
        end
    end)
    function manager.Render(Iris)
        local conflict = manager.conflict
        if not conflict then return end
        Iris.PushId("Rere/native-keybind-conflict")
        if not manager.dialogOpened then
            Iris.SetNextWidgetID("Rere/keybind/dialog/opened")
            manager.dialogOpened = Iris.State(true)
            manager.dialogOpened:set(true)
        end
        Iris.SetNextWidgetID("Rere/keybind/dialog/size")
        local size = Iris.State(Vector2.new(320, 180))
        Iris.SetNextWidgetID("Rere/keybind/dialog/window")
        local dialog = Iris.Window({"Keybind Conflict", false, true, true}, {size = size, isOpened = manager.dialogOpened})
        if dialog.state.isOpened.value then
            local labels = {}
            for _, entry in ipairs(conflict.conflicts) do table.insert(labels, entry.label) end
            Iris.TextWrapped({conflict.name .. " is used by " .. table.concat(labels, ", ") .. ". Move this keybind?"})
            if Iris.Button({"Move keybind"}).clicked() then manager.Resolve(true) end
            if Iris.Button({"Cancel"}).clicked() then manager.Resolve(false) end
            if manager.focusDialog ~= conflict then
                manager.focusDialog = conflict
                Internal.SetFocusedWindow(dialog)
            end
        else manager.Resolve(false) end
        Iris.End()
        Iris.PopId()
    end
end
