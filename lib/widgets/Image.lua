local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local abstractImage = {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Image"] = 1,
            ["Size"] = 2,
            ["Rect"] = 3,
            ["ScaleType"] = 4,
            ["ResampleMode"] = 5,
            ["TileSize"] = 6,
            ["SliceCenter"] = 7,
            ["SliceScale"] = 8,
        },
        Discard = function(thisWidget: Types.Image)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass

    --stylua: ignore
    Iris.WidgetConstructor("Image", widgets.extend(abstractImage, {
            Events = {
                ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
            },
            Generate = function(_thisWidget: Types.Image)
                local Image = Instance.new("ImageLabel")
                Image.Name = "Iris_Image"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Iris._config.ImageColor
                Image.ImageTransparency = Iris._config.ImageTransparency

                widgets.applyFrameStyle(Image, true)

                return Image
            end,
            Update = function(thisWidget: Types.Image)
                local Image = thisWidget.Instance :: ImageLabel
    
                Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
                Image.Size = thisWidget.arguments.Size
                if thisWidget.arguments.ScaleType then
                    Image.ScaleType = thisWidget.arguments.ScaleType
                    if thisWidget.arguments.ScaleType == Enum.ScaleType.Tile and thisWidget.arguments.TileSize then
                        Image.TileSize = thisWidget.arguments.TileSize
                    elseif thisWidget.arguments.ScaleType == Enum.ScaleType.Slice then
                        if thisWidget.arguments.SliceCenter then
                            Image.SliceCenter = thisWidget.arguments.SliceCenter
                        end
                        if thisWidget.arguments.SliceScale then
                            Image.SliceScale = thisWidget.arguments.SliceScale
                        end
                    end
                end
    
                if thisWidget.arguments.Rect then
                    Image.ImageRectOffset = thisWidget.arguments.Rect.Min
                    Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
                end
    
                if thisWidget.arguments.ResampleMode then
                    Image.ResampleMode = thisWidget.arguments.ResampleMode
                end
            end,
        } :: Types.WidgetClass)
    )

    --stylua: ignore
    Iris.WidgetConstructor("ImageButton", widgets.extend(abstractImage, {
            Events = {
                ["clicked"] = widgets.EVENTS.click(function(thisWidget: Types.Widget)
                    return thisWidget.Instance
                end),
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
            Generate = function(_thisWidget: Types.ImageButton)
                local Button = Instance.new("ImageButton")
                Button.Name = "Iris_ImageButton"
                Button.AutomaticSize = Enum.AutomaticSize.XY
                Button.BackgroundColor3 = Iris._config.FrameBgColor
                Button.BackgroundTransparency = Iris._config.FrameBgTransparency
                Button.BorderSizePixel = 0
                Button.Image = ""
                Button.ImageTransparency = 1
                Button.AutoButtonColor = false
                
                widgets.applyFrameStyle(Button, true)
                widgets.UIPadding(Button, Vector2.new(Iris._config.ImageBorderSize, Iris._config.ImageBorderSize))
                
                local Image = Instance.new("ImageLabel")
                Image.Name = "ImageLabel"
                Image.BackgroundTransparency = 1
                Image.BorderSizePixel = 0
                Image.ImageColor3 = Iris._config.ImageColor
                Image.ImageTransparency = Iris._config.ImageTransparency
                Image.Parent = Button

                widgets.applyInteractionHighlights("Background", Button, Button, {
                    Color = Iris._config.FrameBgColor,
                    Transparency = Iris._config.FrameBgTransparency,
                    HoveredColor = Iris._config.FrameBgHoveredColor,
                    HoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                    ActiveColor = Iris._config.FrameBgActiveColor,
                    ActiveTransparency = Iris._config.FrameBgActiveTransparency,
                })

                return Button
            end,
            Update = function(thisWidget: Types.ImageButton)
                local Button = thisWidget.Instance :: TextButton
                local Image: ImageLabel = Button.ImageLabel
    
                Image.Image = thisWidget.arguments.Image or widgets.ICONS.UNKNOWN_TEXTURE
                Image.Size = thisWidget.arguments.Size
                if thisWidget.arguments.ScaleType then
                    Image.ScaleType = thisWidget.arguments.ScaleType
                    if thisWidget.arguments.ScaleType == Enum.ScaleType.Tile and thisWidget.arguments.TileSize then
                        Image.TileSize = thisWidget.arguments.TileSize
                    elseif thisWidget.arguments.ScaleType == Enum.ScaleType.Slice then
                        if thisWidget.arguments.SliceCenter then
                            Image.SliceCenter = thisWidget.arguments.SliceCenter
                        end
                        if thisWidget.arguments.SliceScale then
                            Image.SliceScale = thisWidget.arguments.SliceScale
                        end
                    end
                end
    
                if thisWidget.arguments.Rect then
                    Image.ImageRectOffset = thisWidget.arguments.Rect.Min
                    Image.ImageRectSize = Vector2.new(thisWidget.arguments.Rect.Width, thisWidget.arguments.Rect.Height)
                end
    
                if thisWidget.arguments.ResampleMode then
                    Image.ResampleMode = thisWidget.arguments.ResampleMode
                end
            end,
        } :: Types.WidgetClass)
        )

    Iris.WidgetConstructor("ViewportFrame", {
        hasState = false,
        hasChildren = false,
        Args = {
            ["Size"] = 1,
            ["Camera"] = 2,
            ["Model"] = 3,
            ["BackgroundColor"] = 4,
            ["BackgroundTransparency"] = 5,
            ["Ambient"] = 6,
            ["LightColor"] = 7,
            ["LightDirection"] = 8,
        },
        Events = {
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(_thisWidget: Types.ViewportFrame)
            local Viewport = Instance.new("ViewportFrame")
            Viewport.Name = "Iris_ViewportFrame"
            Viewport.BorderSizePixel = 0
            Viewport.ClipsDescendants = true
            widgets.applyFrameStyle(Viewport, true)
            return Viewport
        end,
        Update = function(thisWidget: Types.ViewportFrame)
            local Viewport = thisWidget.Instance :: ViewportFrame
            local arguments = thisWidget.arguments

            Viewport.Size = arguments.Size or UDim2.fromOffset(240, 180)
            Viewport.BackgroundColor3 = arguments.BackgroundColor or Iris._config.FrameBgColor
            Viewport.BackgroundTransparency = arguments.BackgroundTransparency
                or Iris._config.FrameBgTransparency
            Viewport.Ambient = arguments.Ambient or Color3.fromRGB(200, 200, 200)
            Viewport.LightColor = arguments.LightColor or Color3.new(1, 1, 1)
            Viewport.LightDirection = arguments.LightDirection or Vector3.new(-1, -1, -1)

            for _, child in Viewport:GetChildren() do
                if child:GetAttribute("RereViewportContent") then
                    child:Destroy()
                end
            end

            local model = arguments.Model
            local worldModel
            if model then
                worldModel = Instance.new("WorldModel")
                worldModel.Name = "WorldModel"
                worldModel:SetAttribute("RereViewportContent", true)
                local clone = model:Clone()
                if clone:IsA("WorldModel") then
                    for _, child in clone:GetChildren() do
                        child.Parent = worldModel
                    end
                    clone:Destroy()
                else
                    clone.Parent = worldModel
                end
                worldModel.Parent = Viewport
            end

            local camera = arguments.Camera
            if camera or worldModel then
                local cameraClone = camera and camera:Clone() or Instance.new("Camera")
                cameraClone.Name = "Camera"
                cameraClone:SetAttribute("RereViewportContent", true)
                cameraClone.Parent = Viewport

                if not camera and worldModel then
                    local center, size = worldModel:GetBoundingBox()
                    local radius = math.max(size.X, size.Y, size.Z, 1)
                    local target = center.Position
                    cameraClone.CFrame = CFrame.lookAt(target + Vector3.new(radius, radius * 0.65, radius), target)
                end

                Viewport.CurrentCamera = cameraClone
            else
                Viewport.CurrentCamera = nil
            end
        end,
        Discard = function(thisWidget: Types.ViewportFrame)
            thisWidget.Instance:Destroy()
        end,
    } :: Types.WidgetClass)
end
