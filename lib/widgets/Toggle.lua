--!nocheck
return function(Iris, widgets)
    local manager = Iris._keybinds
    Iris.WidgetConstructor("Toggle", {
        hasState = true, hasChildren = false,
        Args = {Text = 1},
        Events = {
            checked = {Init = function() end, Get = function(widget) return widget.lastCheckedTick == Iris._cycleTick end},
            unchecked = {Init = function() end, Get = function(widget) return widget.lastUncheckedTick == Iris._cycleTick end},
            keybindChanged = {Init = function() end, Get = function(widget) return widget.lastKeybindTick == Iris._cycleTick end},
            hovered = widgets.EVENTS.hover(function(widget) return widget.Instance end),
        },
        Generate = function(widget)
            local row = Instance.new("Frame")
            row.Name = "Rere_Toggle"
            row.AutomaticSize = Enum.AutomaticSize.XY
            row.Size = UDim2.fromOffset(0, 0)
            row.BackgroundTransparency = 1
            widgets.UIListLayout(row, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center

            local height = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
            local bind = Instance.new("TextButton")
            bind.Name = "Keybind"
            bind.Size = UDim2.fromOffset(math.max(62, height * 2), height)
            bind.BackgroundColor3 = Iris._config.ButtonColor
            bind.BackgroundTransparency = Iris._config.ButtonTransparency
            bind.AutoButtonColor = false
            widgets.applyTextStyle(bind)
            bind.TextXAlignment = Enum.TextXAlignment.Center
            bind.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = Iris._config.TextSize; constraint.MinTextSize = 8; constraint.Parent = bind
            widgets.applyFrameStyle(bind)
            bind.Parent = row
            widget.KeybindButton = bind
            widgets.applyInteractionHighlights("Background", bind, bind, {
                Color = Iris._config.ButtonColor, Transparency = Iris._config.ButtonTransparency,
                HoveredColor = Iris._config.ButtonHoveredColor, HoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ActiveColor = Iris._config.ButtonActiveColor, ActiveTransparency = Iris._config.ButtonActiveTransparency,
            })
            widgets.applyButtonClick(bind, function() manager.Begin(widget.state.keybind) end)

            local button = Instance.new("TextButton")
            button.Name = "ToggleButton"
            button.LayoutOrder = 1
            button.AutomaticSize = Enum.AutomaticSize.XY
            button.Size = UDim2.fromOffset(0, 0)
            button.BackgroundTransparency = 1; button.BorderSizePixel = 0
            button.Text = ""; button.AutoButtonColor = false
            widgets.UIListLayout(button, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X)).VerticalAlignment = Enum.VerticalAlignment.Center
            button.Parent = row
            local box = Instance.new("Frame")
            box.Name = "Box"; box.Size = UDim2.fromOffset(height, height)
            box.BackgroundColor3 = Iris._config.FrameBgColor; box.BackgroundTransparency = Iris._config.FrameBgTransparency
            widgets.applyFrameStyle(box, true)
            widgets.UIPadding(box, Vector2.new(math.floor(height / 10), math.floor(height / 10)))
            box.Parent = button
            widgets.applyInteractionHighlights("Background", button, box, {
                Color = Iris._config.FrameBgColor, Transparency = Iris._config.FrameBgTransparency,
                HoveredColor = Iris._config.FrameBgHoveredColor, HoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                ActiveColor = Iris._config.FrameBgActiveColor, ActiveTransparency = Iris._config.FrameBgActiveTransparency,
            })
            local check = Instance.new("ImageLabel")
            check.Name = "Checkmark"; check.Size = UDim2.fromScale(1, 1); check.BackgroundTransparency = 1
            check.Image = widgets.ICONS.CHECKMARK; check.ImageColor3 = Iris._config.CheckMarkColor
            check.ImageTransparency = 1; check.ScaleType = Enum.ScaleType.Fit; check.Parent = box
            local label = Instance.new("TextLabel")
            label.Name = "TextLabel"; label.AutomaticSize = Enum.AutomaticSize.XY
            label.BackgroundTransparency = 1; label.LayoutOrder = 1
            widgets.applyTextStyle(label); label.Parent = button
            widgets.applyButtonClick(button, function()
                widget.state.isChecked:set(not widget.state.isChecked.value)
            end)
            return row
        end,
        GenerateState = function(widget)
            if widget.state.isChecked == nil then widget.state.isChecked = Iris._widgetState(widget, "checked", false) end
            if widget.state.keybind == nil then widget.state.keybind = Iris._widgetState(widget, "keybind", "None") end
        end,
        Update = function(widget)
            local instance = rawget(widget, "Instance")
            if not instance or not instance.Parent then return end
            local toggleButton = instance:FindFirstChild("ToggleButton")
            if not toggleButton then return end
            local label = toggleButton:FindFirstChild("TextLabel")
            if label then label.Text = widget.arguments.Text or "Toggle" end
            local states = rawget(widget, "state")
            if states then
                local checked = states.isChecked
                local entry = manager.Register(states.keybind, function() checked:set(not checked.value) end, widget.arguments.Text or "Toggle")
                local keybindButton = rawget(widget, "KeybindButton") or instance:FindFirstChild("Keybind")
                if keybindButton and keybindButton.Parent == instance then
                    widget.KeybindButton = keybindButton
                    entry.buttons[keybindButton] = true
                end
            end
        end,
        UpdateState = function(widget)
            local instance = rawget(widget, "Instance")
            if not instance or not instance.Parent then return end
            local toggleButton = instance:FindFirstChild("ToggleButton")
            local box = toggleButton and toggleButton:FindFirstChild("Box")
            local checkmark = box and box:FindFirstChild("Checkmark")
            local checked = widget.state.isChecked.value
            if checkmark then
                checkmark.ImageTransparency = checked and Iris._config.CheckMarkTransparency or 1
            end
            if widget.previousChecked ~= checked then
                widget.previousChecked = checked
                if checked then widget.lastCheckedTick = Iris._cycleTick + 1 else widget.lastUncheckedTick = Iris._cycleTick + 1 end
            end
            local key = widget.state.keybind.value
            if widget.previousKeybind ~= key then widget.previousKeybind = key; widget.lastKeybindTick = Iris._cycleTick + 1 end
            local checkedState = widget.state.isChecked
            local entry = manager.Register(widget.state.keybind, function() checkedState:set(not checkedState.value) end, widget.arguments.Text or "Toggle")
            local keybindButton = rawget(widget, "KeybindButton") or instance:FindFirstChild("Keybind")
            if keybindButton and keybindButton.Parent == instance then
                widget.KeybindButton = keybindButton
                entry.buttons[keybindButton] = true
                keybindButton.Text = manager.capture == entry.id and "..." or tostring(key)
            end
        end,
        Discard = function(widget)
            local states = rawget(widget, "state")
            local keybind = states and states.keybind
            local entry = keybind and manager.entries[keybind.ID]
            local instance = rawget(widget, "Instance")
            -- A parent may have destroyed the row before its widget is discarded.
            local button = rawget(widget, "KeybindButton") or (instance and instance:FindFirstChild("Keybind"))
            if entry then
                if button then entry.buttons[button] = nil end
                for registered in pairs(entry.buttons) do
                    if not registered.Parent then entry.buttons[registered] = nil end
                end
            end
            widget.KeybindButton = nil
            if instance then instance:Destroy() end
            if states then widgets.discardState(widget) end
        end,
    })
end
