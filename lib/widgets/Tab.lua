local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.BetaMotion)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local TextService = game:GetService("TextService")
    local function styleTab(widget, animate)
        local tab = widget.Instance
        if rawget(widget, "BetaDiscarded") or not tab or not tab:FindFirstChild("TextLabel") then return end
        local active = widget.state and widget.state.isOpened and widget.state.isOpened.value == true
        local config = Iris._config
        Motion.Play(widget, "tabColor", tab, {
            BackgroundColor3 = active and config.TabActiveColor or config.TabColor,
            BackgroundTransparency = active and config.TabActiveTransparency or config.TabTransparency,
        }, 0.14, animate and config.BetaAnimations ~= false)
        tab.TextLabel.TextColor3 = config.TextColor
        Motion.Play(widget, "tabText", tab.TextLabel, {TextTransparency = active and config.TextTransparency or 0.15}, 0.16, animate and config.BetaAnimations ~= false)
        tab.TextLabel.FontFace = Font.fromEnum(active and Enum.Font.ArialBold or Enum.Font.Arial)
        tab.BetaEdge.BackgroundColor3 = config.SliderGrabColor
        tab.BetaEdge.Visible = active
        tab.BetaNumber.TextColor3 = config.TextColor
        tab.BetaNumber.TextTransparency = active and 0.25 or 0.5
        tab.BetaNumber.Text = string.format("%02d", widget.Index or 1)
        tab.BetaBorder.Color = config.TabActiveColor
        tab.BetaBorder.Transparency = active and 0.3 or 1
        tab.BetaJoin.BackgroundColor3 = config.TabActiveColor
        tab.BetaJoin.BackgroundTransparency = config.TabActiveTransparency
        tab.BetaJoin.Visible = active
    end
    local function reveal(widget)
        local bar = widget.parentWidget.Bar
        local x = widget.Instance.AbsolutePosition.X - bar.AbsolutePosition.X + bar.CanvasPosition.X
        local width = widget.Instance.AbsoluteSize.X
        local maximum = math.max(0, bar.AbsoluteCanvasSize.X - bar.AbsoluteWindowSize.X)
        if x < bar.CanvasPosition.X then
            bar.CanvasPosition = Vector2.new(math.clamp(x, 0, maximum), 0)
        elseif x + width > bar.CanvasPosition.X + bar.AbsoluteWindowSize.X then
            bar.CanvasPosition = Vector2.new(math.clamp(x + width - bar.AbsoluteWindowSize.X, 0, maximum), 0)
        end
    end

    local function openTab(TabBar: Types.TabBar, Index: number)
        for i, tab in TabBar.Tabs do
            tab.state.isOpened:set(i == Index)
        end
    end

    local function closeTab(TabBar: Types.TabBar, Index: number)
        local tab = TabBar.Tabs[Index]
        if tab then
            tab.state.isOpened:set(false)
        end
    end

    --stylua: ignore
    Iris.WidgetConstructor("TabBar", {
        hasState = true,
        hasChildren = true,
        Args = {},
        Events = {},
        Generate = function(thisWidget: Types.TabBar)
            local TabBar = Instance.new("Frame")
            TabBar.Name = "Iris_TabBar"
            TabBar.AutomaticSize = Enum.AutomaticSize.Y
            TabBar.Size = UDim2.fromScale(1, 0)
            TabBar.BackgroundColor3 = Iris._config.WindowBgColor:Lerp(Color3.new(1, 1, 1), 0.06)
            TabBar.BackgroundTransparency = 0
            TabBar.BorderSizePixel = 0

            widgets.UIListLayout(TabBar, Enum.FillDirection.Vertical, UDim.new(0, 0)).VerticalAlignment = Enum.VerticalAlignment.Bottom
            
            local Bar = Instance.new("ScrollingFrame")
            Bar.Name = "Bar"
            Bar.AutomaticSize = Enum.AutomaticSize.None
            Bar.Size = UDim2.new(1, 0, 0, 21)
            Bar.CanvasSize = UDim2.new()
            Bar.AutomaticCanvasSize = Enum.AutomaticSize.X
            Bar.ScrollingDirection = Enum.ScrollingDirection.X
            Bar.ScrollingEnabled = false
            Bar.ScrollBarThickness = 0
            Bar.ElasticBehavior = Enum.ElasticBehavior.Never
            Bar.ClipsDescendants = true
            Bar.BackgroundColor3 = Iris._config.MenubarBgColor
            Bar.BackgroundTransparency = 1
            Bar.BorderSizePixel = 0
            
            local layout = widgets.UIListLayout(Bar, Enum.FillDirection.Horizontal, UDim.new(0, 1))
            layout.VerticalAlignment = Enum.VerticalAlignment.Bottom

            local Rail = Instance.new("Frame")
            Rail.Name = "BetaRail"
            Rail.Size = UDim2.new(1, 0, 0, 21)
            Rail.BackgroundColor3 = TabBar.BackgroundColor3
            Rail.BackgroundTransparency = 0
            Rail.BorderSizePixel = 0
            Rail.Parent = TabBar
            -- Keep the scroll container on the widget for selection and overflow navigation.
            Rail.Visible = true
            Bar.Parent = Rail
            thisWidget.Bar = Bar
            local arrows = {}
            for index, direction in ipairs({-1, 1}) do
                local arrow = Instance.new("TextButton")
                arrow.Name = "BetaArrow" .. index
                arrow.AnchorPoint = Vector2.new(1, 0)
                arrow.Position = UDim2.new(1, index == 1 and -20 or 0, 0, 0)
                arrow.Size = UDim2.fromOffset(19, 20)
                arrow.BackgroundColor3 = Rail.BackgroundColor3
                arrow.BorderSizePixel = 0
                arrow.Text = direction == -1 and "<" or ">"
                arrow.FontFace = Font.fromEnum(Enum.Font.Arial)
                arrow.TextSize = 12
                arrow.TextColor3 = Iris._config.TextColor
                arrow.TextTransparency = 0.3
                arrow.AutoButtonColor = false
                arrow.Parent = Rail
                arrows[index] = arrow
                widgets.applyButtonClick(arrow, function()
                    local maximum = math.max(0, Bar.AbsoluteCanvasSize.X - Bar.AbsoluteWindowSize.X)
                    Bar.CanvasPosition = Vector2.new(math.clamp(Bar.CanvasPosition.X + direction * 140, 0, maximum), 0)
                end)
            end
            local function resizeRail()
                local overflow = layout.AbsoluteContentSize.X > Rail.AbsoluteSize.X
                Bar.Size = UDim2.new(1, overflow and -42 or 0, 0, 21)
                for _, arrow in ipairs(arrows) do arrow.Visible = overflow end
                if not overflow then Bar.CanvasPosition = Vector2.zero end
            end
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeRail)
            Rail:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeRail)
            resizeRail()

            local Underline = Instance.new("Frame")
            Underline.Name = "Underline"
            Underline.Size = UDim2.new(1, 0, 0, 1)
            Underline.BackgroundColor3 = Iris._config.BorderColor
            Underline.BackgroundTransparency = Iris._config.BorderTransparency
            Underline.BorderSizePixel = 0
            Underline.LayoutOrder = 1
            Underline.Visible = true

            Underline.Parent = TabBar

            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "TabContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0
            ChildContainer.LayoutOrder = 2
            ChildContainer.ClipsDescendants = true

            ChildContainer.Parent = TabBar

            thisWidget.ChildContainer = ChildContainer
            thisWidget.Tabs = {}

            return TabBar
        end,
        Update = function(thisWidget: Types.TabBar)
            local color = Iris._config.WindowBgColor:Lerp(Color3.new(1, 1, 1), 0.06)
            thisWidget.Instance.BackgroundColor3 = color
            local rail = thisWidget.Instance.BetaRail
            rail.BackgroundColor3 = color
            for _, child in ipairs(rail:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundColor3 = color end
            end
        end,
        ChildAdded = function(thisWidget: Types.TabBar, thisChild: Types.Tab)
            assert(thisChild.type == "Tab", "Only Iris.Tab can be parented to Iris.TabBar.")
            local TabBar = thisWidget.Instance :: Frame
            thisChild.ChildContainer.Parent = thisWidget.ChildContainer
            thisChild.Index = #thisWidget.Tabs + 1
            table.insert(thisWidget.Tabs, thisChild)
            thisChild.Instance.LayoutOrder = thisChild.Index
            thisChild.Instance.BetaNumber.Text = string.format("%02d", thisChild.Index)

            return thisWidget.Bar
        end,
        ChildDiscarded = function(thisWidget: Types.TabBar, thisChild: Types.Tab)
            local Index = table.find(thisWidget.Tabs, thisChild)
            if not Index then return end
            table.remove(thisWidget.Tabs, Index)

            for i = Index, #thisWidget.Tabs do
                thisWidget.Tabs[i].Index = i
            end

            if not rawget(thisWidget, "BetaDiscarded") and thisChild.state.isOpened.value then
                local nextTab = thisWidget.Tabs[math.min(Index, #thisWidget.Tabs)]
                if nextTab and not rawget(nextTab, "BetaDiscarded") and nextTab.Instance.Parent then
                    openTab(thisWidget, nextTab.Index)
                end
            end
        end,
        GenerateState = function(thisWidget: Types.Tab)
            if thisWidget.state.index == nil then
                thisWidget.state.index = Iris._widgetState(thisWidget, "index", 0)
            end
        end,
        UpdateState = function(_thisWidget: Types.Tab)
        end,
        Discard = function(thisWidget: Types.TabBar)
            thisWidget.BetaDiscarded = true
            for _, tab in thisWidget.Tabs do
                tab.BetaDiscarded = true
                Motion.Clear(tab)
            end
            local navigation = rawget(thisWidget, "BetaNavigation")
            if navigation then navigation.Destroy() end
            local tabBars = rawget(thisWidget.parentWidget, "BetaTabBars")
            if tabBars then
                tabBars[thisWidget.ID] = nil
            end
            thisWidget.ChildContainer:Destroy()
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)

    --stylua: ignore
    Iris.WidgetConstructor("Tab", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Text"] = 1,
            ["Hideable"] = 2,
        },
        Events = {
            ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["selected"] = {
                ["Init"] = function(_thisWidget: Types.Tab) end,
                ["Get"] = function(thisWidget: Types.Tab)
                    return thisWidget.lastSelectedTick == Iris._cycleTick
                end,
            },
            ["unselected"] = {
                ["Init"] = function(_thisWidget: Types.Tab) end,
                ["Get"] = function(thisWidget: Types.Tab)
                    return thisWidget.lastUnselectedTick == Iris._cycleTick
                end,
            },
            ["active"] = {
                ["Init"] = function(_thisWidget: Types.Tab) end,
                ["Get"] = function(thisWidget: Types.Tab)
                    return thisWidget.state.isOpened.value
                end,
            },
            ["opened"] = {
                ["Init"] = function(_thisWidget: Types.Tab) end,
                ["Get"] = function(thisWidget: Types.Tab)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end,
            },
            ["closed"] = {
                ["Init"] = function(_thisWidget: Types.Tab) end,
                ["Get"] = function(thisWidget: Types.Tab)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end,
            },
        },
        Generate = function(thisWidget: Types.Tab)
            local Tab = Instance.new("TextButton")
            Tab.Name = "Iris_Tab"
            Tab.AutomaticSize = Enum.AutomaticSize.None
            Tab.Size = UDim2.fromOffset(54, 20)
            Tab.BackgroundColor3 = Iris._config.TabColor
            Tab.BackgroundTransparency = 0
            Tab.BorderSizePixel = 0
            Tab.Text = ""
            Tab.AutoButtonColor = false

            local rounding = Instance.new("UICorner")
            rounding.CornerRadius = UDim.new(0, 2)
            rounding.Parent = Tab
            Tab.MouseEnter:Connect(function()
                Motion.Play(thisWidget, "tabColor", Tab, {BackgroundColor3 = Iris._config.TabHoveredColor,
                    BackgroundTransparency = Iris._config.TabHoveredTransparency}, 0.1, Iris._config.BetaAnimations ~= false)
                Motion.Play(thisWidget, "tabText", Tab.TextLabel, {TextTransparency = 0}, 0.1, Iris._config.BetaAnimations ~= false)
            end)
            Tab.MouseLeave:Connect(function() styleTab(thisWidget, true) end)
            widgets.applyButtonClick(Tab, function()
                openTab(thisWidget.parentWidget, thisWidget.Index)
                reveal(thisWidget)
            end)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.AutomaticSize = Enum.AutomaticSize.None
            TextLabel.Position = UDim2.fromOffset(14, 0)
            TextLabel.Size = UDim2.new(1, -19, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0

            widgets.applyTextStyle(TextLabel)
            TextLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
            TextLabel.TextSize = 12
            local number = Instance.new("TextLabel")
            number.Name = "BetaNumber"
            number.BackgroundTransparency = 1
            number.Position = UDim2.fromOffset(2, 0)
            number.Size = UDim2.fromOffset(10, 20)
            number.FontFace = Font.fromEnum(Enum.Font.Code)
            number.TextSize = 8
            number.Parent = Tab
            local edge = Instance.new("Frame")
            edge.Name = "BetaEdge"
            edge.Size = UDim2.new(1, -6, 0, 1)
            edge.Position = UDim2.fromOffset(3, 0)
            edge.BorderSizePixel = 0
            edge.Parent = Tab
            local border = Instance.new("UIStroke")
            border.Name = "BetaBorder"
            border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            border.Color = Iris._config.TabActiveColor
            border.Thickness = 1
            border.Parent = Tab
            local join = Instance.new("Frame")
            join.Name = "BetaJoin"
            join.Position = UDim2.new(0, 0, 1, -2)
            join.Size = UDim2.new(1, 0, 0, 3)
            join.BackgroundColor3 = Iris._config.TabActiveColor
            join.BorderSizePixel = 0
            join.Parent = Tab

            TextLabel.Parent = Tab

            local ButtonSize = 14

            local CloseButton = Instance.new("TextButton")
            CloseButton.Name = "CloseButton"
            CloseButton.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
            CloseButton.BackgroundTransparency = 1
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = ""
            CloseButton.AutoButtonColor = false
            CloseButton.AnchorPoint = Vector2.new(1, 0.5)
            CloseButton.Position = UDim2.new(1, -3, 0.5, 0)

            widgets.UICorner(CloseButton)
            widgets.applyButtonClick(CloseButton, function()
                thisWidget.state.isOpened:set(false)
                closeTab(thisWidget.parentWidget, thisWidget.Index)
            end)

            widgets.applyInteractionHighlights("Background", CloseButton, CloseButton, {
                Color = Iris._config.TabColor,
                Transparency = 1,
                HoveredColor = Iris._config.ButtonHoveredColor,
                HoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ActiveColor = Iris._config.ButtonActiveColor,
                ActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            CloseButton.Parent = Tab

            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.AnchorPoint = Vector2.new(0.5, 0.5)
            Icon.Position = UDim2.fromScale(0.5, 0.5)
            Icon.Size = UDim2.fromOffset(math.floor(0.7 * ButtonSize), math.floor(0.7 * ButtonSize))
            Icon.BackgroundTransparency = 1
            Icon.BorderSizePixel = 0
            Icon.Image = widgets.ICONS.MULTIPLICATION_SIGN
            Icon.ImageTransparency = 1

            widgets.applyInteractionHighlights("Image", Tab, Icon, {
                Color = Iris._config.TextColor,
                Transparency = 1,
                HoveredColor = Iris._config.TextColor,
                HoveredTransparency = Iris._config.TextTransparency,
                ActiveColor = Iris._config.TextColor,
                ActiveTransparency = Iris._config.TextTransparency,
            })
            Icon.Parent = CloseButton

            local ChildContainer = Instance.new("Frame")
            ChildContainer.Name = "TabContainer"
            ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
            ChildContainer.Size = UDim2.fromScale(1, 0)
            ChildContainer.BackgroundTransparency = 1
            ChildContainer.BorderSizePixel = 0
            
            ChildContainer.ClipsDescendants = true
            widgets.UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            widgets.UIPadding(ChildContainer, Vector2.new(0, Iris._config.ItemSpacing.Y)).PaddingBottom = UDim.new()

            thisWidget.ChildContainer = ChildContainer

            return Tab
        end,
        Update = function(thisWidget: Types.Tab)
            local Tab = thisWidget.Instance :: TextButton
            local TextLabel: TextLabel = Tab.TextLabel
            local CloseButton: TextButton = Tab.CloseButton

            TextLabel.Text = thisWidget.arguments.Text
            local width = TextService:GetTextSize(TextLabel.Text, 12, Enum.Font.ArialBold, Vector2.new(1000, 21)).X
            Tab.Size = UDim2.fromOffset(math.ceil(width) + 20 + (thisWidget.arguments.Hideable and 17 or 0), 20)
            TextLabel.Size = UDim2.new(1, -(thisWidget.arguments.Hideable and 36 or 19), 1, 0)
            styleTab(thisWidget)
            CloseButton.Visible = if thisWidget.arguments.Hideable == true then true else false
        end,
        ChildAdded = function(thisWidget: Types.Tab, _thisChild: Types.Widget)
            return thisWidget.ChildContainer
        end,
        GenerateState = function(thisWidget: Types.Tab)
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", thisWidget.Index == 1)
            end
        end,
        UpdateState = function(thisWidget: Types.Tab)
            local Tab = thisWidget.Instance :: TextButton
            local Container = thisWidget.ChildContainer :: Frame
            if rawget(thisWidget, "BetaDiscarded") or not Tab:FindFirstChild("TextLabel") or not Container.Parent then return end

            styleTab(thisWidget, true)
            Container.Visible = thisWidget.state.isOpened.value == true
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.Size = UDim2.fromScale(1, 0)
            if Container.Visible then
                local previous = rawget(thisWidget.parentWidget, "BetaLastSelected")
                thisWidget.parentWidget.BetaLastSelected = thisWidget.Index
                if not rawget(thisWidget, "BetaWasOpened") then
                    Motion.Cancel(thisWidget, "content")
                    local direction = previous and thisWidget.Index < previous and -1 or 1
                    Container.Position = UDim2.fromOffset(direction * 10, 4)
                    Motion.Play(thisWidget, "content", Container, {Position = UDim2.fromOffset(0, 0)}, 0.2, Iris._config.BetaAnimations ~= false)
                    Tab.BetaEdge.Size = UDim2.new(0, 0, 0, 1)
                    Motion.Play(thisWidget, "edge", Tab.BetaEdge, {Size = UDim2.new(1, -6, 0, 1)}, 0.2, Iris._config.BetaAnimations ~= false)
                end
                thisWidget.lastSelectedTick = Iris._cycleTick + 1
            else
                Motion.Cancel(thisWidget, "content")
                Motion.Cancel(thisWidget, "edge")
                Container.Position = UDim2.fromOffset(0, 0)
                thisWidget.lastUnselectedTick = Iris._cycleTick + 1
            end
            thisWidget.BetaWasOpened = Container.Visible
            local navigation = rawget(thisWidget.parentWidget, "BetaNavigation")
            if navigation then navigation.Refresh() end
        end,
        Discard = function(thisWidget: Types.Tab)
            thisWidget.BetaDiscarded = true
            Motion.Clear(thisWidget)
            
            thisWidget.Instance:Destroy()
            thisWidget.ChildContainer:Destroy()
            widgets.discardState(thisWidget)
        end
    } :: Types.WidgetClass)
end
