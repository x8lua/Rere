# Images, progress, and plots

| Constructor | Details |
| --- | --- |
| `Image` | Displays an image asset. |
| `ImageButton` | Clickable image asset. |
| `ProgressBar` | Renders a numeric progress state. |
| `PlotLines` | Renders a line plot. |
| `PlotHistogram` | Renders a histogram. |

```lua
local progress = Rere.State(0.65)
Rere.Image({Image = "rbxassetid://123"})
Rere.ProgressBar({"Loading"}, {progress = progress})
Rere.PlotLines({"Frame time"}, {values = {0.01, 0.02, 0.015, 0.03}})
```