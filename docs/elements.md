---
description: "Rere executor UI element index."
icon: puzzle-piece
---

# Elements

Each entry below is a documented Rere constructor. Choose a category for signatures, states, events, nesting rules, and runnable patterns.

| Section | Includes |
| --- | --- |
| [Windows and layout](elements/windows-layout.md) | `Window`, `Tooltip`, text, separators, indentation, grouping |
| [Buttons and selection](elements/buttons-selection.md) | buttons, checkbox, radio buttons, selectable |
| [Menus, tabs, and sections](elements/navigation.md) | menu bar, menus, tabs, trees, collapsing headers |
| [Dropdowns and inputs](elements/inputs.md) | combos, typed inputs, color/value editors |
| [Sliders and drags](elements/sliders-drags.md) | numeric, enum, vector, UDim, and rect controls |
| [Images, plots, and progress](elements/media-visuals.md) | images, image buttons, progress bars, plots |
| [Tables and columns](elements/tables.md) | tables, rows, columns, headers, widths |

## Constructor pattern

```lua
local value = Rere.State(defaultValue)
local widget = Rere.ElementName({"Label", optionalArguments}, {field = value})
if widget.clicked and widget.clicked() then
    print("event")
end
```

Use `Rere.End()` once for every container you open. See [States and events](states.md) for persistent values and event helpers.