---
description: "A practical first Rere UI with tabs, state, input, and a dropdown."
icon: bolt
---

# Quickstart

```lua
local compiler = loadstring or load
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.25/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

local enabled = Rere.State(true)
local choice = Rere.State("Dark")

Rere:Connect(function()
    Rere.Window({"Rere quickstart"})
        Rere.TabBar()
            Rere.Tab({"Controls"})
                Rere.Text({"Version: " .. Rere:GetVersion()})
                Rere.Checkbox({"Enabled"}, {isChecked = enabled})
                Rere.ComboArray({"Theme"}, {index = choice}, {"Dark", "Light", "System"})
                if Rere.Button({"Print state"}).clicked() then
                    print(enabled:get(), choice:get())
                end
            Rere.End()
        Rere.End()
    Rere.End()
end)
```

`State` objects bridge UI values and your executor code. Read a value with `state:get()` and update it with `state:set(value)`.
