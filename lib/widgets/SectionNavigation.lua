-- Pull down at the top of a window to jump between the active tab's sections.
-- The clipped slot occupies exactly zero pixels when closed.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local SHOW_HEIGHT = 44
local LABEL_ANGLE = 12
local ANIMATION = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local WHEEL_RELEASE = 0.85 -- Wheel input has no held/released state; allow time to select a section.

return function(Iris, widgets, window, tabBar, parent)
    local controller = {open = false, destroyed = false, sections = {}, connections = {}, buttons = {}}
    local scroll = window.ChildContainer
    local slot = Instance.new("Frame")
    slot.Name = "RereSectionNavigation"
    slot.Size = UDim2.new(1, 0, 0, 0)
    slot.BackgroundTransparency = 1
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    slot.LayoutOrder = -1
    slot.Visible = false
    slot.Parent = scroll
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "DiagonalSections"
    panel.Position = UDim2.fromOffset(0, -SHOW_HEIGHT)
    panel.Size = UDim2.new(1, 0, 0, SHOW_HEIGHT)
    panel.BackgroundColor3 = Iris._config.WindowBgColor:Lerp(Color3.new(1, 1, 1), 0.06)
    panel.BorderSizePixel = 0
    panel.CanvasSize = UDim2.new()
    panel.AutomaticCanvasSize = Enum.AutomaticSize.X
    panel.ScrollingDirection = Enum.ScrollingDirection.X
    panel.ScrollBarThickness = 2
    panel.ScrollBarImageColor3 = Iris._config.SliderGrabColor
    panel.ElasticBehavior = Enum.ElasticBehavior.Never
    panel.ClipsDescendants = true
    panel.Parent = slot
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = panel
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = panel
    controller.Slot, controller.Panel = slot, panel
    local slotTween, panelTween, hideTask, touch, touchY, touchAtTop, jumpAnchor

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(controller.connections, connection)
        return connection
    end
    local function inside(gui, position)
        local p, s = gui.AbsolutePosition - widgets.GuiOffset, gui.AbsoluteSize
        return position.X >= p.X and position.X <= p.X + s.X and position.Y >= p.Y and position.Y <= p.Y + s.Y
    end
    local function visible()
        return not controller.destroyed and window.state.isOpened.value and window.state.isUncollapsed.value
            and tabBar.Instance.Visible and #controller.sections > 0
    end
    local function cancelHide()
        if hideTask then pcall(task.cancel, hideTask); hideTask = nil end
    end
    function controller.SetOpen(value, immediate)
        if controller.destroyed then return end
        value = value and visible()
        if value == controller.open and not immediate then return end
        controller.open = value
        if slotTween then slotTween:Cancel() end
        if panelTween then panelTween:Cancel() end
        if immediate then
            slot.Size = UDim2.new(1, 0, 0, value and SHOW_HEIGHT or 0)
            panel.Position = UDim2.fromOffset(0, value and 0 or -SHOW_HEIGHT)
            slot.Visible = value
            return
        end
        slot.Visible = true
        slotTween = TweenService:Create(slot, ANIMATION, {Size = UDim2.new(1, 0, 0, value and SHOW_HEIGHT or 0)})
        panelTween = TweenService:Create(panel, ANIMATION, {Position = UDim2.fromOffset(0, value and 0 or -SHOW_HEIGHT)})
        slotTween.Completed:Once(function(state)
            if state == Enum.PlaybackState.Completed and not controller.destroyed and not controller.open then
                slot.Visible = false
                task.defer(function()
                    local section = jumpAnchor
                    if controller.destroyed or not section or not section.Instance.Parent then return end
                    local offset = section.Instance.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
                    scroll.CanvasPosition = Vector2.new(0, math.clamp(offset, 0, math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)))
                    window.state.scrollDistance.value = scroll.CanvasPosition.Y
                    jumpAnchor = nil
                end)
            end
        end)
        slotTween:Play(); panelTween:Play()
    end
    local function releaseLater()
        cancelHide()
        hideTask = task.delay(WHEEL_RELEASE, function()
            hideTask = nil
            if not controller.destroyed and not touch and not inside(slot, widgets.getMouseLocation()) then controller.SetOpen(false) end
        end)
    end
    function controller.Jump(section)
        if controller.destroyed or not section.Instance.Parent then return end
        section.state.isUncollapsed:set(true)
        -- Keep the target anchored while the navigation slot smoothly collapses.
        jumpAnchor = section
        cancelHide(); controller.SetOpen(false)
        task.defer(function()
            if controller.destroyed or not section.Instance.Parent then return end
            local offset = section.Instance.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
            local maximum = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
            scroll.CanvasPosition = Vector2.new(0, math.clamp(offset, 0, maximum))
            window.state.scrollDistance.value = scroll.CanvasPosition.Y
        end)
        window.state.scrollDistance.value = scroll.CanvasPosition.Y
    end
    function controller.Refresh()
        if controller.destroyed then return end
        local active
        for _, tab in ipairs(tabBar.Tabs) do if tab.state and tab.state.isOpened.value then active = tab; break end end
        local sections = {}
        if active then for _, section in pairs(rawget(active, "BetaSections") or {}) do table.insert(sections, section) end end
        table.sort(sections, function(a, b) return a.ZIndex < b.ZIndex end)
        local signature = active and active.ID or ""
        for _, section in ipairs(sections) do signature ..= "|" .. section.ID .. ":" .. tostring(section.arguments.Text) end
        if controller.signature == signature then return end
        controller.signature = signature
        controller.SetOpen(false, true); cancelHide()
        for _, button in ipairs(controller.buttons) do button:Destroy() end
        table.clear(controller.buttons)
        controller.sections = sections
        panel.CanvasPosition = Vector2.zero
        for index, section in ipairs(sections) do
            local text = section.arguments.Text or "Section"
            local textWidth = math.ceil(TextService:GetTextSize(text, 11, Enum.Font.Code, Vector2.new(1000, 14)).X) + 2
            local cellWidth = math.ceil(textWidth * math.cos(math.rad(LABEL_ANGLE)) + 14 * math.sin(math.rad(LABEL_ANGLE))) + 10
            local cell = Instance.new("TextButton")
            cell.Name = "Section_" .. index
            cell.Size = UDim2.fromOffset(cellWidth, SHOW_HEIGHT)
            cell.LayoutOrder = index
            cell.Text = ""
            cell.BackgroundTransparency = 1
            cell.BorderSizePixel = 0
            cell.AutoButtonColor = false
            cell.Parent = panel
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.Position = UDim2.fromScale(0.5, 0.5)
            label.Size = UDim2.fromOffset(textWidth, 14)
            label.BackgroundTransparency = 1
            label.FontFace = Font.fromEnum(Enum.Font.Code)
            label.TextSize = 11
            label.TextColor3 = Iris._config.TextColor
            label.TextTransparency = 0.15
            label.Text = text
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Rotation = LABEL_ANGLE
            label.Parent = cell
            local edge = Instance.new("Frame")
            edge.Name = "Edge"
            edge.Size = UDim2.new(1, -6, 0, 1)
            edge.Position = UDim2.new(0, 3, 1, -3)
            edge.BackgroundColor3 = Iris._config.BorderColor
            edge.BorderSizePixel = 0
            edge.Parent = cell
            cell.MouseEnter:Connect(function() label.TextTransparency = 0; edge.BackgroundColor3 = Iris._config.SliderGrabColor end)
            cell.MouseLeave:Connect(function() label.TextTransparency = 0.15; edge.BackgroundColor3 = Iris._config.BorderColor end)
            widgets.applyButtonClick(cell, function() controller.Jump(section) end)
            table.insert(controller.buttons, cell)
        end
    end
    connect(UserInputService.InputChanged, function(input)
        if not visible() then return end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local pointer = widgets.getMouseLocation()
            if inside(scroll, pointer) or (controller.open and inside(slot, pointer)) then
                if input.Position.Z < 0 then cancelHide(); controller.SetOpen(false)
                elseif input.Position.Z > 0 and scroll.CanvasPosition.Y <= 1 then controller.SetOpen(true); releaseLater() end
            end
        elseif input == touch then
            local delta = input.Position.Y - touchY
            if delta < -6 then controller.SetOpen(false)
            elseif touchAtTop and delta >= 22 then controller.SetOpen(true) end
        end
    end)
    connect(UserInputService.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch or not visible() then return end
        local position = Vector2.new(input.Position.X, input.Position.Y) - widgets.GuiOffset
        if inside(scroll, position) then touch = input; touchY = input.Position.Y; touchAtTop = scroll.CanvasPosition.Y <= 1; cancelHide() end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input == touch then touch = nil; controller.SetOpen(false) end
    end)
    connect(slot.MouseEnter, cancelHide)
    connect(slot.MouseLeave, releaseLater)
    connect(scroll:GetPropertyChangedSignal("CanvasPosition"), function()
        if controller.open and scroll.CanvasPosition.Y > 1 then cancelHide(); controller.SetOpen(false) end
    end)
    connect(slot:GetPropertyChangedSignal("AbsoluteSize"), function()
        local section = jumpAnchor
        if not section or controller.destroyed or not section.Instance.Parent then return end
        task.defer(function()
            if controller.destroyed or jumpAnchor ~= section or not section.Instance.Parent then return end
            local offset = section.Instance.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
            scroll.CanvasPosition = Vector2.new(0, math.clamp(offset, 0, math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)))
            window.state.scrollDistance.value = scroll.CanvasPosition.Y
        end)
    end)
    function controller.Destroy(alreadyDestroying)
        if controller.destroyed then return end
        controller.destroyed = true; cancelHide()
        if slotTween then slotTween:Cancel() end
        if panelTween then panelTween:Cancel() end
        for _, connection in ipairs(controller.connections) do connection:Disconnect() end
        table.clear(controller.connections)
        if not alreadyDestroying then slot:Destroy() end
    end
    -- Iris.Shutdown destroys the root directly, without calling every widget's Discard.
    connect(slot.Destroying, function() controller.Destroy(true) end)
    return controller
end
