---
description: "Fix common executor errors and stale UI instances."
icon: wrench
---

# Troubleshooting

## The version label is old

Do not hardcode a version string. Use:

```lua
Rere.Text({"Rere v" .. Rere:GetVersion()})
```

Pin the URL to `v0.1.24` and re-execute the script.

## Duplicate windows appear

Old `Rere:Connect` callbacks are still running. Execute `Rere.Shutdown()` before loading another copy, then run the new script once.

## A widget is missing

Check that the constructor is inside the correct parent and that every parent has a matching `Rere.End()`.

## Dropdown arrows or animation look stale

Use `v0.1.24` or newer. Combo arrows rotate right (`0°`) to down (`90°`), and opening and closing use `0.1s` transitions.

## `attempt to call a nil value`

Use the executor loader pattern:

```lua
local compiler = loadstring or load
local Rere = assert(compiler(game:HttpGet(URL)))()
```

Do not call the raw HTTP response as a function.
