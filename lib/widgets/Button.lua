local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local abstractButton = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["Size"] = 2,
            ["Disabled"] = 3,
            ["DisabledReason"] = 4,
        },
        Events = {
            ["clicked"] = {
                ["Init"] = function(thisWidget: Types.Widget & Types.Clicked)
                    local clickedGuiObject = thisWidget.Instance :: GuiButton
                    thisWidget.lastClickedTick = -1

                    widgets.applyButtonClick(clickedGuiObject, function()
                        local args = thisWidget.arguments or {}
                        local disabled = args.Disabled == true or args[3] == true
                        if not disabled then
                            thisWidget.lastClickedTick = Iris._cycleTick + 1
                        end
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget & Types.Clicked)
                    local args = thisWidget.arguments or {}
                    local disabled = args.Disabled == true or args[3] == true
                    if disabled then
                        return false
                    end
                    return thisWidget.lastClickedTick == Iris._cycleTick
                end,
            },
            ["declined"] = {
                ["Init"] = function(thisWidget: Types.Widget)
                    local clickedGuiObject = thisWidget.Instance :: GuiButton
                    thisWidget.lastDeclinedTick = -1

                    widgets.applyButtonClick(clickedGuiObject, function()
                        local args = thisWidget.arguments or {}
                        local disabled = args.Disabled == true or args[3] == true
                        if disabled then
                            thisWidget.lastDeclinedTick = Iris._cycleTick + 1
                        end
                    end)
                end,
                ["Get"] = function(thisWidget: Types.Widget)
                    local args = thisWidget.arguments or {}
                    local disabled = args.Disabled == true or args[3] == true
                    if not disabled then
                        return false
                    end
                    return thisWidget.lastDeclinedTick == Iris._cycleTick
                end,
            },
            ["rightClicked"] = widgets.EVENTS.rightClick(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["doubleClicked"] = widgets.EVENTS.doubleClick(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["ctrlClicked"] = widgets.EVENTS.ctrlClick(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(_thisWidget: Types.Button)
            local Button = Instance.new("TextButton")
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromOffset(0, 0)
            Button.BackgroundColor3 = Iris._config.ButtonColor
            Button.BackgroundTransparency = Iris._config.ButtonTransparency
            Button.AutoButtonColor = false

            widgets.applyTextStyle(Button)
            Button.TextXAlignment = Enum.TextXAlignment.Center

            widgets.applyFrameStyle(Button)

            widgets.applyMouseEnter(Button, function()
                local args = _thisWidget.arguments or {}
                local disabled = args.Disabled == true or args[3] == true
                if disabled then return end
                Button.BackgroundColor3 = Iris._config.ButtonHoveredColor
                Button.BackgroundTransparency = Iris._config.ButtonHoveredTransparency
            end)

            widgets.applyMouseLeave(Button, function()
                local args = _thisWidget.arguments or {}
                local disabled = args.Disabled == true or args[3] == true
                if disabled then
                    Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                    Button.BackgroundTransparency = 0.2
                    return
                end
                Button.BackgroundColor3 = Iris._config.ButtonColor
                Button.BackgroundTransparency = Iris._config.ButtonTransparency
            end)

            widgets.applyInputBegan(Button, function(input: InputObject)
                local args = _thisWidget.arguments or {}
                local disabled = args.Disabled == true or args[3] == true
                if disabled then return end
                if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                    return
                end
                Button.BackgroundColor3 = Iris._config.ButtonActiveColor
                Button.BackgroundTransparency = Iris._config.ButtonActiveTransparency
            end)

            widgets.applyInputEnded(Button, function(input: InputObject)
                local args = _thisWidget.arguments or {}
                local disabled = args.Disabled == true or args[3] == true
                if disabled then
                    Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                    Button.BackgroundTransparency = 0.2
                    return
                end
                if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
                    return
                end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Button.BackgroundColor3 = Iris._config.ButtonHoveredColor
                    Button.BackgroundTransparency = Iris._config.ButtonHoveredTransparency
                else
                    Button.BackgroundColor3 = Iris._config.ButtonColor
                    Button.BackgroundTransparency = Iris._config.ButtonTransparency
                end
            end)

            Button.SelectionImageObject = Iris.SelectionImageObject

            return Button
        end,
        Update = function(thisWidget: Types.Button)
            local Button = thisWidget.Instance :: TextButton
            local args = thisWidget.arguments or {}
            local disabled = args.Disabled == true or args[3] == true

            Button.Text = args.Text or args[1] or "Button"
            Button.Size = args.Size or args[2] or UDim2.fromOffset(0, 0)

            if disabled then
                Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
                Button.BackgroundTransparency = 0.2
                Button.TextColor3 = Color3.fromRGB(80, 80, 85)
                Button.AutoButtonColor = false
            else
                Button.BackgroundColor3 = Iris._config.ButtonColor
                Button.BackgroundTransparency = Iris._config.ButtonTransparency
                Button.TextColor3 = Iris._config.TextColor
            end
        end,
        Discard = function(thisWidget: Types.Button)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass
    widgets.abstractButton = abstractButton

    --stylua: ignore
    Iris.WidgetConstructor("Button", widgets.extend(abstractButton, {
            Generate = function(thisWidget: Types.Button)
                local Button = abstractButton.Generate(thisWidget)
                Button.Name = "Iris_Button"

                return Button
            end,
        } :: Types.WidgetClass)
    )

    --stylua: ignore
    Iris.WidgetConstructor("SmallButton", widgets.extend(abstractButton, {
            Generate = function(thisWidget: Types.Button)
                local SmallButton = abstractButton.Generate(thisWidget)
                SmallButton.Name = "Iris_SmallButton"

                local uiPadding: UIPadding = SmallButton.UIPadding
                uiPadding.PaddingLeft = UDim.new(0, 2)
                uiPadding.PaddingRight = UDim.new(0, 2)
                uiPadding.PaddingTop = UDim.new(0, 0)
                uiPadding.PaddingBottom = UDim.new(0, 0)

                return SmallButton
            end,
        } :: Types.WidgetClass)
    )
end
