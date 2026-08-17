---
description: "Complete examples for building Rere executor interfaces."
icon: code
---

# Examples

## Official files

* [Basic executor](../examples/executor_basic.lua)
* [Slider example](../examples/slider.lua)
* [Settings example](../examples/settings_demo.lua)
* [Feature demo](../examples/feature_demo.lua)

## Full element example

```lua
local compiler = loadstring or load
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.25/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

local selected = Rere.State("Dark")
local enabled = Rere.State(true)

Rere:Connect(function()
    Rere.Window({"Every element"})
        Rere.Text({"Rere " .. Rere:GetVersion()})
        Rere.MenuBar()
            Rere.Menu({"File"})
                Rere.MenuItem({"Save"})
            Rere.End()
        Rere.End()
        Rere.TabBar()
            Rere.Tab({"Controls"})
                Rere.Checkbox({"Enabled"}, {isChecked = enabled})
                Rere.ComboArray({"Theme"}, {index = selected}, {"Dark", "Light", "System"})
                Rere.SliderNum({"Amount", 1, 0, 100})
                Rere.InputText({"Name"})
                Rere.Button({"Apply"})
            Rere.End()
        Rere.End()
    Rere.End()
end)
```
