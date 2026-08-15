# Buttons and selection

| Constructor | State / event | Details |
| --- | --- | --- |
| `Button` | `.clicked()` | Standard action button. |
| `SmallButton` | `.clicked()` | Compact action button. |
| `Checkbox` | `isChecked` state | Toggle boolean state. |
| `RadioButton` | `index` state | Selects a matching `Index` value. |
| `Selectable` | `index` state | Selectable list row. |

```lua
local enabled = Rere.State(false)
if Rere.Button({"Save"}).clicked() then print("saved") end
Rere.Checkbox({"Enabled"}, {isChecked = enabled})
```

Supported interactive widgets can also expose `.hovered()`, `.rightClicked()`, and `.doubleClicked()`.