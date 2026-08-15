# Dropdowns and typed inputs

## Dropdown constructors

| Constructor | Details |
| --- | --- |
| `Combo` | Custom child dropdown. |
| `ComboArray` | Picks an entry from an array. |
| `ComboEnum` | Picks an enum member. |
| `InputEnum` | Enum input/dropdown. |

```lua
local quality = Rere.State("High")
Rere.ComboArray({"Quality"}, {index = quality}, {"Low", "Medium", "High", "Ultra"})
```

## Typed inputs
`InputText`, `InputNum`, `InputVector2`, `InputVector3`, `InputUDim`, `InputUDim2`, `InputRect`, `InputColor3`, and `InputColor4` edit matching Luau/Roblox values.

```lua
local username = Rere.State("")
local amount = Rere.State(10)
Rere.InputText({"Username", "Enter a name"}, {text = username})
Rere.InputNum({"Amount", 1, 0, 100}, {number = amount})
```