local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.BetaMotion)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local function animateOpening(widget, height)
        local container = widget.ChildContainer
        local generation = widget.BetaMotionGeneration
        if not widget.BetaOpening or not container.Parent then return end
        if math.abs((rawget(widget, "BetaSectionTargetHeight") or -1) - height) < 0.5 then return end
        widget.BetaSectionTargetHeight = height
        Motion.Play(widget, "section", container, {Size = UDim2.new(1, 0, 0, height)}, 0.18, true, function()
            if widget.BetaMotionGeneration ~= generation or not container.Parent then return end
            -- A cached height can start immediately; finish only once new children have laid out.
            if container.UIListLayout.AbsoluteContentSize.Y <= 0 then
                widget.BetaSectionTargetHeight = nil
                return
            end
            local measured = Motion.ContentHeight(container)
            if math.abs(measured - height) >= 0.5 then
                animateOpening(widget, measured)
                return
            end
            widget.BetaExpandedHeight = measured
            widget.BetaOpening = false
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Size = UDim2.fromScale(1, 0)
        end)
    end
    local function queueSectionLayout(widget)
        if rawget(widget, "BetaLayoutQueued") then return end
        widget.BetaLayoutQueued = true
        task.defer(function()
            widget.BetaLayoutQueued = false
            local container = widget.ChildContainer
            local states = rawget(widget, "state")
            if not container.Parent or not states or not states.isUncollapsed.value then return end
            if container.UIListLayout.AbsoluteContentSize.Y <= 0 then return end
            local height = Motion.ContentHeight(container)
            widget.BetaExpandedHeight = height
            if rawget(widget, "BetaOpening") then animateOpening(widget, height) end
        end)
    end
    local function watchSectionLayout(widget)
        widget.BetaLayoutConnection = widget.ChildContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            queueSectionLayout(widget)
        end)
    end

    local abstractTree = {
        hasState = true,
        hasChildren = true,
        Events = {
            ["collapsed"] = {
                ["Init"] = function(_thisWidget: Types.CollapsingHeader) end,
                ["Get"] = function(thisWidget: Types.CollapsingHeader)
                    return thisWidget.lastCollapsedTick == Iris._cycleTick
                end,
            },
            ["uncollapsed"] = {
                ["Init"] = function(_thisWidget: Types.CollapsingHeader) end,
                ["Get"] = function(thisWidget: Types.CollapsingHeader)
                    return thisWidget.lastUncollapsedTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget)
                return thisWidget.Instance
            end),
        },
        Discard = function(thisWidget: Types.CollapsingHeader)
            local layoutConnection = rawget(thisWidget, "BetaLayoutConnection")
            if layoutConnection then layoutConnection:Disconnect() end
            Motion.Clear(thisWidget)
            local tab = rawget(thisWidget, "BetaSectionTab")
            if tab then
                local sections = rawget(tab, "BetaSections")
                if sections then sections[thisWidget.ID] = nil end
                local navigation = rawget(tab.parentWidget, "BetaNavigation")
                if navigation then navigation.Refresh() end
            end
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        ChildAdded = function(thisWidget: Types.CollapsingHeader, _thisChild: Types.Widget)
            local ChildContainer = thisWidget.ChildContainer :: Frame

            if thisWidget.state.isUncollapsed.value then ChildContainer.Visible = true end
            queueSectionLayout(thisWidget)

            return ChildContainer
        end,
        UpdateState = function(thisWidget: Types.CollapsingHeader)
            local isUncollapsed = thisWidget.state.isUncollapsed.value
            local Tree = thisWidget.Instance :: Frame
            local ChildContainer = thisWidget.ChildContainer :: Frame
            local Header = Tree.Header :: Frame
            local Button = Header.Button :: TextButton
            local ArrowRotationFrame: Frame = Button.ArrowRotationFrame
            local Arrow: ImageLabel = ArrowRotationFrame.Arrow
            local ArrowGlyph: TextLabel = ArrowRotationFrame.ArrowGlyph
            local TargetRotation = if isUncollapsed then 90 else 0
            local PreviousRotation = ArrowGlyph:GetAttribute("TargetRotation")
            if PreviousRotation == nil then
                ArrowGlyph:SetAttribute("TargetRotation", TargetRotation)
                ArrowGlyph.Rotation = TargetRotation
            elseif PreviousRotation ~= TargetRotation then
                ArrowGlyph:SetAttribute("TargetRotation", TargetRotation)
                Motion.Play(thisWidget, "arrow", ArrowGlyph, {Rotation = TargetRotation}, 0.16, Iris._config.BetaAnimations ~= false)
            end
            if isUncollapsed then
                thisWidget.lastUncollapsedTick = Iris._cycleTick + 1
            else
                thisWidget.lastCollapsedTick = Iris._cycleTick + 1
            end

            local previous = rawget(thisWidget, "BetaWasUncollapsed")
            thisWidget.BetaWasUncollapsed = isUncollapsed
            if previous == isUncollapsed then return end
            Motion.Cancel(thisWidget, "section")
            thisWidget.BetaOpening = false
            thisWidget.BetaSectionTargetHeight = nil
            thisWidget.BetaMotionGeneration = (rawget(thisWidget, "BetaMotionGeneration") or 0) + 1
            local generation = thisWidget.BetaMotionGeneration
            local enabled = Iris._config.BetaAnimations ~= false
            if not enabled or previous == nil then
                ChildContainer.Visible = isUncollapsed
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.Size = UDim2.fromScale(1, 0)
                return
            end
            -- Freeze the current height while the immediate-mode render adds/removes children.
            local height = ChildContainer.Size.Y.Offset
            if ChildContainer.AutomaticSize == Enum.AutomaticSize.Y then
                height = Motion.ContentHeight(ChildContainer)
                if previous and ChildContainer.UIListLayout.AbsoluteContentSize.Y > 0 then
                    thisWidget.BetaExpandedHeight = height
                end
            end
            ChildContainer.AutomaticSize = Enum.AutomaticSize.None
            ChildContainer.Size = UDim2.new(1, 0, 0, height)
            ChildContainer.Visible = true
            if isUncollapsed then
                thisWidget.BetaOpening = true
                Button.TextLabel.TextTransparency = 0.45
                Motion.Play(thisWidget, "sectionTitle", Button.TextLabel, {TextTransparency = Iris._config.TextTransparency}, 0.2, true)
                local cachedHeight = rawget(thisWidget, "BetaExpandedHeight")
                if cachedHeight and cachedHeight > 0 then animateOpening(thisWidget, cachedHeight) end
                queueSectionLayout(thisWidget)
            else
                Motion.Cancel(thisWidget, "sectionTitle")
                Button.TextLabel.TextTransparency = Iris._config.TextTransparency
                Motion.Play(thisWidget, "section", ChildContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.16, true, function()
                    if thisWidget.BetaMotionGeneration ~= generation or not ChildContainer.Parent then return end
                    ChildContainer.Visible = false
                    ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                    ChildContainer.Size = UDim2.fromScale(1, 0)
                end)
            end
        end,
        GenerateState = function(thisWidget: Types.CollapsingHeader)
            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", thisWidget.arguments.DefaultOpen or false)
            end
        end,
    } :: Types.WidgetClass

    --stylua: ignore
    Iris.WidgetConstructor(
        "Tree",
        widgets.extend(abstractTree, {
            Args = {
                ["Text"] = 1,
                ["SpanAvailWidth"] = 2,
                ["NoIndent"] = 3,
                ["DefaultOpen"] = 4,
            },
            Generate = function(thisWidget: Types.Tree)
                local Tree = Instance.new("Frame")
                Tree.Name = "Iris_Tree"
                Tree.AutomaticSize = Enum.AutomaticSize.Y
                Tree.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
                Tree.BackgroundTransparency = 1
                Tree.BorderSizePixel = 0

                widgets.UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer = Instance.new("Frame")
                ChildContainer.Name = "TreeContainer"
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                ChildContainer.ClipsDescendants = true

                widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
                widgets.UIPadding(ChildContainer, Vector2.zero).PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

                ChildContainer.Parent = Tree

                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.Size = UDim2.fromScale(1, 0)
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = Tree

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.BackgroundTransparency = 1
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false

                widgets.applyInteractionHighlights("Background", Button, Header, {
                    Color = Color3.fromRGB(0, 0, 0),
                    Transparency = 1,
                    HoveredColor = Iris._config.HeaderHoveredColor,
                    HoveredTransparency = Iris._config.HeaderHoveredTransparency,
                    ActiveColor = Iris._config.HeaderActiveColor,
                    ActiveTransparency = Iris._config.HeaderActiveTransparency,
                })

                widgets.UIPadding(Button, Vector2.zero).PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
                widgets.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.FramePadding.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                Button.Parent = Header

                local ArrowRotationFrame = Instance.new("Frame")
                ArrowRotationFrame.Name = "ArrowRotationFrame"
                ArrowRotationFrame.Size = UDim2.fromOffset(Iris._config.TextSize, math.floor(Iris._config.TextSize * 0.7))
                ArrowRotationFrame.BackgroundTransparency = 1
                ArrowRotationFrame.BorderSizePixel = 0
                ArrowRotationFrame.Parent = Button
                local Arrow = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
                Arrow.Position = UDim2.fromScale(0.5, 0.5)
                Arrow.Size = UDim2.fromScale(1, 1)
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Iris._config.TextColor
                Arrow.ImageTransparency = Iris._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = ArrowRotationFrame

                local ArrowGlyph = Instance.new("TextLabel")
                ArrowGlyph.Name = "ArrowGlyph"
                ArrowGlyph.AnchorPoint = Vector2.new(0.5, 0.5)
                ArrowGlyph.Position = UDim2.fromScale(0.5, 0.5)
                ArrowGlyph.Size = UDim2.fromScale(1, 1)
                ArrowGlyph.BackgroundTransparency = 1
                ArrowGlyph.BorderSizePixel = 0
                ArrowGlyph.Text = "▶"
                ArrowGlyph.TextColor3 = Iris._config.TextColor
                ArrowGlyph.TextTransparency = Iris._config.TextTransparency
                ArrowGlyph.TextSize = Iris._config.TextSize
                ArrowGlyph.FontFace = Iris._config.TextFont
                ArrowGlyph.Parent = ArrowRotationFrame
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                widgets.UIPadding(TextLabel, Vector2.zero).PaddingRight = UDim.new(0, 21)
                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                widgets.applyButtonClick(Button, function()
                    thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
                end)

                thisWidget.ChildContainer = ChildContainer
                watchSectionLayout(thisWidget)
                return Tree
            end,
            Update = function(thisWidget: Types.Tree)
                local Tree = thisWidget.Instance :: Frame
                local ChildContainer = thisWidget.ChildContainer :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel
                local Padding: UIPadding = ChildContainer.UIPadding

                TextLabel.Text = thisWidget.arguments.Text or "Tree"
                if thisWidget.arguments.SpanAvailWidth then
                    Button.AutomaticSize = Enum.AutomaticSize.Y
                    Button.Size = UDim2.fromScale(1, 0)
                else
                    Button.AutomaticSize = Enum.AutomaticSize.XY
                    Button.Size = UDim2.fromScale(0, 0)
                end

                if thisWidget.arguments.NoIndent then
                    Padding.PaddingLeft = UDim.new(0, 0)
                else
                    Padding.PaddingLeft = UDim.new(0, Iris._config.IndentSpacing)
                end
            end,
        })
    )

    --stylua: ignore
    Iris.WidgetConstructor(
        "CollapsingHeader",
        widgets.extend(abstractTree, {
            Args = {
                ["Text"] = 1,
                ["DefaultOpen"] = 2
            },
            Generate = function(thisWidget: Types.CollapsingHeader)
                local CollapsingHeader = Instance.new("Frame")
                CollapsingHeader.Name = "Iris_CollapsingHeader"
                CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y
                CollapsingHeader.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
                CollapsingHeader.BackgroundTransparency = 1
                CollapsingHeader.BorderSizePixel = 0

                widgets.UIListLayout(CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))

                local ChildContainer = Instance.new("Frame")
                ChildContainer.Name = "CollapsingHeaderContainer"
                ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
                ChildContainer.Size = UDim2.fromScale(1, 0)
                ChildContainer.BackgroundTransparency = 1
                ChildContainer.BorderSizePixel = 0
                ChildContainer.LayoutOrder = 1
                ChildContainer.Visible = false
                ChildContainer.ClipsDescendants = true

                widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
                widgets.UIPadding(ChildContainer, Vector2.zero).PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

                ChildContainer.Parent = CollapsingHeader

                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.AutomaticSize = Enum.AutomaticSize.Y
                Header.Size = UDim2.fromScale(1, 0)
                Header.BackgroundTransparency = 1
                Header.BorderSizePixel = 0
                Header.Parent = CollapsingHeader

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.AutomaticSize = Enum.AutomaticSize.Y
                Button.Size = UDim2.fromScale(1, 0)
                Button.BackgroundColor3 = Iris._config.HeaderColor
                Button.BackgroundTransparency = Iris._config.HeaderTransparency
                Button.BorderSizePixel = 0
                Button.Text = ""
                Button.AutoButtonColor = false
                Button.ClipsDescendants = true

                widgets.UIPadding(Button, Iris._config.FramePadding) -- we add a custom padding because it extends on both sides
                widgets.applyFrameStyle(Button, true)
                widgets.UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, 2 * Iris._config.FramePadding.X)).VerticalAlignment = Enum.VerticalAlignment.Center

                widgets.applyInteractionHighlights("Background", Button, Button, {
                    Color = Iris._config.HeaderColor,
                    Transparency = Iris._config.HeaderTransparency,
                    HoveredColor = Iris._config.HeaderHoveredColor,
                    HoveredTransparency = Iris._config.HeaderHoveredTransparency,
                    ActiveColor = Iris._config.HeaderActiveColor,
                    ActiveTransparency = Iris._config.HeaderActiveTransparency,
                })

                Button.Parent = Header

                local ArrowRotationFrame = Instance.new("Frame")
                ArrowRotationFrame.Name = "ArrowRotationFrame"
                ArrowRotationFrame.Size = UDim2.fromOffset(Iris._config.TextSize, math.ceil(Iris._config.TextSize * 0.8))
                ArrowRotationFrame.BackgroundTransparency = 1
                ArrowRotationFrame.BorderSizePixel = 0
                ArrowRotationFrame.Parent = Button
                local Arrow = Instance.new("ImageLabel")
                Arrow.Name = "Arrow"
                Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
                Arrow.Position = UDim2.fromScale(0.5, 0.5)
                Arrow.Size = UDim2.fromScale(1, 1)
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.ImageColor3 = Iris._config.TextColor
                Arrow.ImageTransparency = Iris._config.TextTransparency
                Arrow.ScaleType = Enum.ScaleType.Fit

                Arrow.Parent = ArrowRotationFrame

                local ArrowGlyph = Instance.new("TextLabel")
                ArrowGlyph.Name = "ArrowGlyph"
                ArrowGlyph.AnchorPoint = Vector2.new(0.5, 0.5)
                ArrowGlyph.Position = UDim2.fromScale(0.5, 0.5)
                ArrowGlyph.Size = UDim2.fromScale(1, 1)
                ArrowGlyph.BackgroundTransparency = 1
                ArrowGlyph.BorderSizePixel = 0
                ArrowGlyph.Text = "▶"
                ArrowGlyph.TextColor3 = Iris._config.TextColor
                ArrowGlyph.TextTransparency = Iris._config.TextTransparency
                ArrowGlyph.TextSize = Iris._config.TextSize
                ArrowGlyph.FontFace = Iris._config.TextFont
                ArrowGlyph.Parent = ArrowRotationFrame
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "TextLabel"
                TextLabel.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel.Size = UDim2.fromOffset(0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderSizePixel = 0

                widgets.UIPadding(TextLabel, Vector2.zero).PaddingRight = UDim.new(0, 21)
                widgets.applyTextStyle(TextLabel)

                TextLabel.Parent = Button

                widgets.applyButtonClick(Button, function()
                    thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
                end)

                thisWidget.ChildContainer = ChildContainer
                watchSectionLayout(thisWidget)
                return CollapsingHeader
            end,
            Update = function(thisWidget: Types.CollapsingHeader)
                local Tree = thisWidget.Instance :: Frame
                local Header = Tree.Header :: Frame
                local Button = Header.Button :: TextButton
                local TextLabel: TextLabel = Button.TextLabel

                TextLabel.Text = thisWidget.arguments.Text or "Collapsing Header"
                -- Direct headers are section anchors; nested headers stay within their section.
                local tab = thisWidget.parentWidget
                if tab.type == "Tab" then
                    tab.BetaSections = rawget(tab, "BetaSections") or {}
                    tab.BetaSections[thisWidget.ID] = thisWidget
                    thisWidget.BetaSectionTab = tab
                    local navigation = rawget(tab.parentWidget, "BetaNavigation")
                    if navigation then navigation.Refresh() end
                end
            end,
        })
    )
end
