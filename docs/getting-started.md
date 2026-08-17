---
description: "Load Rere from an executor and create your first window."
icon: rocket
---

# Executor setup

Rere is designed for an executor. It is not a Roblox Studio ModuleScript package.

{% stepper %}
{% step %}
## Choose a pinned release

Use the immutable raw bundle URL:

```lua
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.25/src/Rere.lua")
```
{% endstep %}

{% step %}
## Compile and initialize

Executors expose either `loadstring` or `load`:

```lua
local compiler = loadstring or load
local Rere = assert(compiler(source))()
Rere.Init()
```
{% endstep %}

{% step %}
## Render every cycle

Immediate-mode widgets are declared inside `Rere:Connect`. Parent widgets must be closed with `Rere.End()`.

```lua
Rere:Connect(function()
    Rere.Window({"My window"})
        Rere.Text({"Hello from Rere"})
    Rere.End()
end)
```
{% endstep %}
{% endstepper %}

{% hint style="warning" %}
Do not call `Rere:Connect` before `Rere.Init()`. Do not use `require(game.ReplicatedStorage...)` in an executor.
{% endhint %}

## Cleanup

Call `Rere.Shutdown()` before loading a replacement copy in the same client. This prevents multiple connected render loops and duplicate windows.
