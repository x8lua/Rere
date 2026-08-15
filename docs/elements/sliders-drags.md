# Sliders and drag inputs

Sliders follow the pointer across their track. Drag inputs support precise incremental adjustment.

| Slider constructors | Drag constructors |
| --- | --- |
| `SliderNum`, `SliderEnum` | `DragNum` |
| `SliderVector2`, `SliderVector3` | `DragVector2`, `DragVector3` |
| `SliderUDim`, `SliderUDim2`, `SliderRect` | `DragUDim`, `DragUDim2`, `DragRect` |

```lua
local volume = Rere.State(50)
Rere.SliderNum({"Volume", 1, 0, 100, "%d%%"}, {number = volume})
Rere.DragNum({"Fine tune", 0.1, 0, 100}, {number = volume})
```