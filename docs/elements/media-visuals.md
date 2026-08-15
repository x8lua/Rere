# Images, progress, and plots

| Constructor | Details |
| --- | --- |
| `Image` | Displays an image asset. |
| `ImageButton` | Clickable image asset. |
| `ViewportFrame` | Displays a cloned 3D model or part using an optional camera. |
| `ProgressBar` | Renders a numeric progress state. |
| `PlotLines` | Renders a line plot. |
| `PlotHistogram` | Renders a histogram. |

```lua
local progress = Rere.State(0.65)
Rere.Image({Image = "rbxassetid://123"})
Rere.ProgressBar({"Loading"}, {progress = progress})
Rere.PlotLines({"Frame time"}, {values = {0.01, 0.02, 0.015, 0.03}})
```

## `ViewportFrame`

Arguments are positional: `Size`, `Camera`, `Model`, `BackgroundColor`, `BackgroundTransparency`, `Ambient`, `LightColor`, and `LightDirection`.

```lua
local model = workspace:FindFirstChild("PreviewModel")
local camera = Instance.new("Camera")
camera.CFrame = CFrame.lookAt(Vector3.new(6, 4, 6), Vector3.zero)

local viewport = Rere.ViewportFrame({
    UDim2.fromOffset(320, 220),
    camera,
    model,
    Color3.fromRGB(24, 24, 27),
    0,
})

-- Advanced access to the generated Roblox instance:
viewport.Instance.Ambient = Color3.fromRGB(180, 180, 180)
```

Rere clones the supplied camera and model so the original workspace objects are unchanged. If `Camera` is omitted, Rere creates one and frames the supplied model automatically.
