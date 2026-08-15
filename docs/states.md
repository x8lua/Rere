---
description: "Use Rere State objects, events, and immediate-mode updates correctly."
icon: rotate
---

# States and events

## State basics

```lua
local count = Rere.State(0)
Rere.Text({"Count: " .. tostring(count:get())})
Rere.Button({"Increase"})
if Rere.Button({"Increase"}).clicked() then
    count:set(count:get() + 1)
end
```

The common state fields are `number`, `index`, `text`, `color`, `isChecked`, `isOpened`, `isUncollapsed`, `size`, `position`, `progress`, and `scrollDistance`.

## Events

Events are queried on the widget returned by the constructor:

```lua
local button = Rere.Button({"Apply"})
if button.clicked() then print("clicked") end
if button.hovered() then print("hovered") end
```

Common events include `clicked`, `rightClicked`, `doubleClicked`, `hovered`, `opened`, `closed`, `changed`, `checked`, `unchecked`, `selected`, and `unselected` depending on the element.

## Immediate-mode rules

1. Create state outside `Rere:Connect` so it persists.
2. Declare the same widget structure each cycle.
3. Use `Rere.End()` for every parent element.
4. Read state with `get()` and mutate it with `set()`.
