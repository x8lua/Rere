---
description: "Complete Rere element catalog with constructor signatures and runnable patterns."
icon: puzzle-piece
---

# Every element

Every constructor below is available on the `Rere` table in the executor bundle. Most constructors accept an argument array, an optional state table, or both.

## Windows and hierarchy

| Element | Use | Example |
| --- | --- | --- |
| `Window` | Movable, resizable root window | `Rere.Window({"Title"})` |
| `Tooltip` | Hover tooltip content | `Rere.Tooltip({"Help text"})` |
| `Root` | Internal root widget | Usually created by `Rere.Init()` |
| `End` | Closes the current parent | `Rere.End()` |

```lua
Rere.Window({"Tools"})
    Rere.Text({"Window content"})
Rere.End()
```

## Text and layout

| Element | Purpose |
| --- | --- |
| `Text` | Plain text |
| `TextWrapped` | Wrapped text |
| `TextColored` | Text with a color argument |
| `Separator` | Horizontal separator |
| `SeparatorText` | Separator with a caption |
| `Indent` | Indented child layout |
| `SameLine` | Places the next element on the same row |
| `Group` | Groups children without a visible frame |

```lua
Rere.Text({"Normal"})
Rere.TextWrapped({"Long text that can wrap inside the available width."})
Rere.SeparatorText({"Details"})
Rere.Indent()
    Rere.Text({"Indented"})
Rere.End()
```

## Buttons and selection

| Element | Example |
| --- | --- |
| `Button` | `Rere.Button({"Save"})` |
| `SmallButton` | `Rere.SmallButton({"Reset"})` |
| `Checkbox` | `Rere.Checkbox({"Enabled"}, {isChecked = enabled})` |
| `RadioButton` | `Rere.RadioButton({"Mode A"}, {index = mode}, {Index = "A"})` |
| `Selectable` | `Rere.Selectable({"Option"}, {index = selected})` |

Buttons expose events such as `.clicked()`, `.hovered()`, `.rightClicked()`, and `.doubleClicked()` where supported.

## Menus

| Element | Use |
| --- | --- |
| `MenuBar` | Horizontal menu container |
| `Menu` | Menu dropdown |
| `MenuItem` | Clickable menu item |
| `MenuToggle` | Checkable menu item |

```lua
Rere.MenuBar()
    Rere.Menu({"File"})
        if Rere.MenuItem({"Save"}).clicked() then
            print("save")
        end
    Rere.End()
Rere.End()
```

## Tabs, trees, and sections

| Element | Use |
| --- | --- |
| `TabBar` | Page navigation container |
| `Tab` | A page inside a tab bar |
| `Tree` | Expandable nested section |
| `CollapsingHeader` | Expandable header section |

```lua
Rere.TabBar()
    Rere.Tab({"Dashboard"})
        Rere.Text({"Dashboard page"})
    Rere.End()
    Rere.Tab({"Settings"})
        Rere.CollapsingHeader({"Graphics"})
            Rere.Text({"Graphics settings"})
        Rere.End()
    Rere.End()
Rere.End()
```

## Dropdowns

| Element | Use |
| --- | --- |
| `Combo` | Custom child dropdown |
| `ComboArray` | Dropdown from an array |
| `ComboEnum` | Dropdown from an enum |
| `InputEnum` | Enum input/dropdown |

```lua
local quality = Rere.State("High")
Rere.ComboArray({"Quality"}, {index = quality}, {"Low", "Medium", "High", "Ultra"})
```

`Tree` and `CollapsingHeader` are also expandable dropdown-style sections:

```lua
Rere.CollapsingHeader({"Advanced"})
    Rere.Text({"Advanced options"})
Rere.End()
```

Dropdown arrows rotate from right (`0°`) to down (`90°`) and open/close transitions use `0.1s`.

## Text and typed inputs

`InputText`, `InputNum`, `InputVector2`, `InputVector3`, `InputUDim`, `InputUDim2`, `InputRect`, `InputColor3`, and `InputColor4` edit their matching Roblox values.

```lua
local username = Rere.State("")
local amount = Rere.State(10)
Rere.InputText({"Username", "Enter a name"}, {text = username})
Rere.InputNum({"Amount", 1, 0, 100}, {number = amount})
```

## Sliders and drag inputs

Slider constructors: `SliderNum`, `SliderEnum`, `SliderVector2`, `SliderVector3`, `SliderUDim`, `SliderUDim2`, and `SliderRect`.

Drag constructors: `DragNum`, `DragVector2`, `DragVector3`, `DragUDim`, `DragUDim2`, and `DragRect`.

```lua
local volume = Rere.State(50)
Rere.SliderNum({"Volume", 1, 0, 100, "%d%%"}, {number = volume})
Rere.DragNum({"Fine tune", 0.1, 0, 100}, {number = volume})
```

## Images

| Element | Example |
| --- | --- |
| `Image` | `Rere.Image({Image = "rbxassetid://123"})` |
| `ImageButton` | `Rere.ImageButton({Image = "rbxassetid://123"})` |

## Progress and plots

| Element | Use |
| --- | --- |
| `ProgressBar` | Displays progress |
| `PlotLines` | Line plot |
| `PlotHistogram` | Histogram plot |

```lua
local progress = Rere.State(0.65)
Rere.ProgressBar({"Loading"}, {progress = progress})
Rere.PlotLines({"Frame time"}, {values = {0.01, 0.02, 0.015, 0.03}})
```

## Tables and columns

| Element | Use |
| --- | --- |
| `Table` | Multi-column layout |
| `NextColumn` | Moves to the next column |
| `NextRow` | Moves to the next row |
| `SetColumnIndex` | Selects a column |
| `SetRowIndex` | Selects a row |
| `NextHeaderColumn` | Moves through table headers |
| `SetHeaderColumnIndex` | Selects a header column |
| `SetColumnWidth` | Sets a column width |

```lua
Rere.Table({"Stats", 2})
    Rere.Text({"Name"})
    Rere.NextColumn()
    Rere.Text({"Value"})
    Rere.NextRow()
    Rere.Text({"Coins"})
    Rere.NextColumn()
    Rere.Text({"100"})
Rere.End()
```
