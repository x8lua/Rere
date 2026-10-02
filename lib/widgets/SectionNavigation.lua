-- Hover over the content right edge to reveal floating diagonal section anchors.
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LABEL_ANGLE = -40
local REVEAL = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return function(Iris, widgets, window, tabBar, parent)
    local controller = {open = false, destroyed = false, sections = {}, connections = {}, buttons = {}}
    local scroll = window.ChildContainer
    local body = Instance.new("Frame")
    body.Name = "RereContentBody"
    body.Size = scroll.Size
    body.LayoutOrder = scroll.LayoutOrder
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.ClipsDescendants = true
    local flex = scroll:FindFirstChildWhichIsA("UIFlexItem")
    if flex then flex.Parent = body end
    body.Parent = parent
    scroll.Parent = body
    scroll.Position = UDim2.fromOffset(0, 0)
    local slot = Instance.new("Frame")
    slot.Name = "RereSectionNavigation"
    slot.AnchorPoint = Vector2.new(1, 0)
    slot.Position = UDim2.fromScale(1, 0)
    slot.Size = UDim2.new(0, 0, 1, 0)
    slot.BackgroundTransparency = 1
    slot.ZIndex = 5
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    slot.Visible = false
    slot.Parent = body
    local group = Instance.new("CanvasGroup")
    group.Name = "HoverReveal"
    group.Size = UDim2.fromScale(1, 1)
    group.BackgroundTransparency = 1
    group.GroupTransparency = 1
    group.ZIndex = 2
    group.Parent = slot
    local shadow = Instance.new("Frame")
    shadow.Name = "SoftBlackShadow"
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BorderSizePixel = 0
    shadow.Parent = group
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.96), NumberSequenceKeypoint.new(1, 0.68)})
    gradient.Parent = shadow
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "DiagonalSections"
    panel.Size = UDim2.fromScale(1, 1)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.CanvasSize = UDim2.new()
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.ScrollingDirection = Enum.ScrollingDirection.Y
    panel.ScrollBarThickness = 0
    panel.ScrollBarImageColor3 = Iris._config.SliderGrabColor
    panel.ElasticBehavior = Enum.ElasticBehavior.Never
    panel.ClipsDescendants = true
    panel.ZIndex = 2
    panel.Parent = group
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = panel
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 44)
    padding.Parent = panel
    controller.Slot, controller.Panel = slot, panel
    local longest = 80
    local fadeTween, slideTween
    local function available()
        return not controller.destroyed and #controller.sections > 0 and window.state.isOpened.value and window.state.isUncollapsed.value
    end
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(controller.connections, connection)
    end
    local function resize()
        if controller.destroyed then return end
        local scale = window.Instance.WindowButton.InterfaceScale.Scale
        local available = body.AbsoluteSize.X / scale
        local width = math.min(longest + 12, math.max(96, available * 0.4), 152)
        slot.Size = UDim2.new(0, width, 1, 0)
        scroll.Size = UDim2.fromScale(1, 1)
        local labelWidth = math.max(20, width - 12)
        local height = 23
        for _, cell in ipairs(controller.buttons) do
            cell.Size = UDim2.new(1, -3, 0, height)
            local textWidth = math.min(cell:GetAttribute("TextWidth"), labelWidth)
            local angle = math.rad(math.abs(LABEL_ANGLE))
            local rotatedWidth = textWidth * math.cos(angle) + 14 * math.sin(angle)
            cell.Label.Size = UDim2.fromOffset(textWidth, 14)
            cell.Label.Position = UDim2.new(1, -rotatedWidth / 2 - 3, 0, 8 + textWidth * math.sin(angle) / 2)
            if cell.LayoutOrder == 1 then
                padding.PaddingTop = UDim.new(0, 3)
            end
        end
    end
    function controller.SetOpen(value, immediate)
        if controller.destroyed then return end
        value = value and available()
        if value == controller.open and not immediate then return end
        controller.open = value
        if fadeTween then fadeTween:Cancel() end
        if slideTween then slideTween:Cancel() end
        resize()
        if immediate then
            group.GroupTransparency = value and 0 or 1
            group.Position = UDim2.fromOffset(value and 0 or 10, 0)
            slot.Visible = value
            return
        end
        slot.Visible = true
        fadeTween = TweenService:Create(group, REVEAL, {GroupTransparency = value and 0 or 1})
        slideTween = TweenService:Create(group, REVEAL, {Position = UDim2.fromOffset(value and 0 or 10, 0)})
        fadeTween.Completed:Once(function(state)
            if state == Enum.PlaybackState.Completed and not controller.destroyed and not controller.open then slot.Visible = false end
        end)
        fadeTween:Play(); slideTween:Play()
    end
    function controller.Jump(section)
        if controller.destroyed or not section.Instance.Parent then return end
        section.state.isUncollapsed:set(true)
        task.defer(function()
            if controller.destroyed or not section.Instance.Parent then return end
            local offset = section.Instance.AbsolutePosition.Y - scroll.AbsolutePosition.Y + scroll.CanvasPosition.Y
            scroll.CanvasPosition = Vector2.new(0, math.clamp(offset, 0, math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)))
            window.state.scrollDistance.value = scroll.CanvasPosition.Y
        end)
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
        for _, button in ipairs(controller.buttons) do button:Destroy() end
        table.clear(controller.buttons)
        controller.sections = sections
        panel.CanvasPosition = Vector2.zero
        longest = 80
        for index, section in ipairs(sections) do
            local text = section.arguments.Text or "Section"
            local textWidth = math.ceil(TextService:GetTextSize(text, 11, Enum.Font.ArialBold, Vector2.new(1000, 14)).X) + 2
            longest = math.max(longest, textWidth)
            local cell = Instance.new("TextButton")
            cell.Name = "Section_" .. index
            cell:SetAttribute("TextWidth", textWidth)
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
            label.BackgroundTransparency = 1
            label.FontFace = Font.fromEnum(Enum.Font.ArialBold)
            label.TextSize = 11
            label.TextColor3 = Iris._config.TextColor
            label.TextTransparency = 0.15
            label.Text = text
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Rotation = LABEL_ANGLE
            local outline = Instance.new("UIStroke")
            outline.Color = Color3.new(0, 0, 0)
            outline.Thickness = 1.5
            outline.Transparency = 0.4
            outline.Parent = label
            label.Parent = cell
            cell.MouseEnter:Connect(function() label.TextTransparency = 0; label.TextColor3 = Iris._config.SliderGrabActiveColor end)
            cell.MouseLeave:Connect(function() label.TextTransparency = 0.15; label.TextColor3 = Iris._config.TextColor end)
            widgets.applyButtonClick(cell, function() controller.Jump(section) end)
            table.insert(controller.buttons, cell)
        end
        resize()
        controller.SetOpen(false, true)
    end
    connect(body:GetPropertyChangedSignal("AbsoluteSize"), resize)
    connect(UserInputService.InputChanged, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement or not available() then return end
        local pointer = widgets.getMouseLocation()
        local origin = body.AbsolutePosition - widgets.GuiOffset
        local size = body.AbsoluteSize
        local width = controller.open and slot.AbsoluteSize.X or 22
        controller.SetOpen(pointer.X >= origin.X + size.X - width and pointer.X <= origin.X + size.X
            and pointer.Y >= origin.Y and pointer.Y <= origin.Y + size.Y)
    end)
    connect(UserInputService.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch or not available() then return end
        local pointer = Vector2.new(input.Position.X, input.Position.Y) - widgets.GuiOffset
        local origin = body.AbsolutePosition - widgets.GuiOffset
        local size = body.AbsoluteSize
        if pointer.X >= origin.X + size.X - 22 and pointer.X <= origin.X + size.X and pointer.Y >= origin.Y and pointer.Y <= origin.Y + size.Y then
            controller.SetOpen(not controller.open)
        elseif controller.open and pointer.X < origin.X + size.X - slot.AbsoluteSize.X then controller.SetOpen(false) end
    end)
    function controller.Destroy(alreadyDestroying)
        if controller.destroyed then return end
        controller.destroyed = true
        if fadeTween then fadeTween:Cancel() end
        if slideTween then slideTween:Cancel() end
        for _, connection in ipairs(controller.connections) do connection:Disconnect() end
        table.clear(controller.connections)
        if not alreadyDestroying then
            if scroll.Parent == body then
                scroll.Parent = parent
                scroll.Size = body.Size
                local ownedFlex = body:FindFirstChildWhichIsA("UIFlexItem")
                if ownedFlex then ownedFlex.Parent = scroll end
            end
            body:Destroy()
        end
    end
    connect(body.Destroying, function() controller.Destroy(true) end)
    return controller
end
