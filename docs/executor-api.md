# Executor API

Rere preserves Iris's immediate-mode API. Call `Rere.Init()` once, then declare widgets inside a callback registered through `Rere:Connect`.

## Window and Widgets

```lua
Rere:Connect(function()
    Rere.Window({"Inspector"})
        Rere.Text({"Connected"})
        local enabled = Rere.Checkbox({"Enabled"}, {isChecked = Rere.State(true)})
        Rere.SliderNum({"Opacity", 0, 1})
        Rere.InputText({"Filter"})
    Rere.End()
end)
```

## States

Create persistent values with `Rere.State` and pass them through widget state tables.

```lua
local counter = Rere.State(0)

Rere:Connect(function()
    Rere.Window({"Counter"})
        if Rere.Button({"Increment"}).clicked() then
            counter:set(counter:get() + 1)
        end
        Rere.Text({"Count: " .. counter:get()})
    Rere.End()
end)
```

The original Iris API details remain available in the bundled source and are attributed under the MIT license.

## Slider

```lua
local volume = Rere.State(50)

Rere:Connect(function()
    Rere.Window({"Slider example"})
        Rere.Text({"Volume: " .. volume:get() .. "%"})
        Rere.SliderNum({"Volume", 1, 0, 100, "%d%%"}, {
            number = volume,
        })
    Rere.End()
end)
```

The complete script is in [`examples/slider.lua`](../examples/slider.lua).
