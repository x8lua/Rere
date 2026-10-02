-- Compact fixed section anchors along the content area's right edge.
local TextService = game:GetService("TextService")
local LABEL_ANGLE = -12

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
    slot.BackgroundColor3 = Iris._config.WindowBgColor:Lerp(Color3.new(1, 1, 1), 0.04)
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    slot.Visible = false
    slot.Parent = body
    local panel = Instance.new("ScrollingFrame")
    panel.Name = "DiagonalSections"
    panel.Size = UDim2.fromScale(1, 1)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.CanvasSize = UDim2.new()
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.ScrollingDirection = Enum.ScrollingDirection.Y
    panel.ScrollBarThickness = 2
    panel.ScrollBarImageColor3 = Iris._config.SliderGrabColor
    panel.ElasticBehavior = Enum.ElasticBehavior.Never
    panel.ClipsDescendants = true
    panel.Parent = slot
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.Parent = panel
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = panel
    local border = Instance.new("Frame")
    border.Size = UDim2.new(0, 1, 1, 0)
    border.BackgroundColor3 = Iris._config.BorderColor
    border.BackgroundTransparency = 0.4
    border.BorderSizePixel = 0
    border.Parent = slot
    controller.Slot, controller.Panel = slot, panel
    local longest = 80
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(controller.connections, connection)
    end
    local function resize()
        if controller.destroyed then return end
        local scale = window.Instance.WindowButton.InterfaceScale.Scale
        local available = body.AbsoluteSize.X / scale
        local width = controller.open and math.min(longest + 12, math.max(72, available * 0.32), 152) or 0
        slot.Size = UDim2.new(0, width, 1, 0)
        scroll.Size = UDim2.new(1, -width, 1, 0)
        local labelWidth = math.max(20, width - 12)
        local height = math.ceil(labelWidth * math.sin(math.rad(math.abs(LABEL_ANGLE))) + 14) + 4
        for _, cell in ipairs(controller.buttons) do
            cell.Size = UDim2.new(1, -3, 0, height)
            cell.Label.Size = UDim2.fromOffset(labelWidth, 14)
        end
    end
    function controller.SetOpen(value)
        if controller.destroyed then return end
        controller.open = value and #controller.sections > 0 and window.state.isOpened.value and window.state.isUncollapsed.value
        slot.Visible = controller.open
        resize()
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
            label.Parent = cell
            cell.MouseEnter:Connect(function() label.TextTransparency = 0; cell.BackgroundTransparency = 0; cell.BackgroundColor3 = Iris._config.TabHoveredColor end)
            cell.MouseLeave:Connect(function() label.TextTransparency = 0.15; cell.BackgroundTransparency = 1 end)
            widgets.applyButtonClick(cell, function() controller.Jump(section) end)
            table.insert(controller.buttons, cell)
        end
        controller.SetOpen(true)
    end
    connect(body:GetPropertyChangedSignal("AbsoluteSize"), resize)
    function controller.Destroy(alreadyDestroying)
        if controller.destroyed then return end
        controller.destroyed = true
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
