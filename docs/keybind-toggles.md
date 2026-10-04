# Native Toggle and Keybinds

`Rere.Toggle` is a native widget with a keybind button to the left of its checkbox.
Existing `Rere.Checkbox` calls keep their existing behavior.

```lua
local enabled = Rere.State(false)
local key = Rere.State("None")

Rere:Connect(function()
    Rere.Window({"Settings"})
    Rere.SetNextWidgetID("settings/auto-parry")
    local toggle = Rere.Toggle({"Auto Parry"}, {
        isChecked = enabled,
        keybind = key,
    })
    if toggle.keybindChanged() then print(key.value) end
    Rere.End()
end)
```

Click the keybind button, then press a key. Escape clears the binding. Store keys
as KeyCode names (`"K"`, `"RightShift"`, `"None"`). Both states may be omitted;
Rere will create them. Use a stable widget ID for dynamic lists.

Duplicate assignments open the library's Keybind Conflict window. Move keybind
clears the previous owners and applies the new binding; Cancel preserves the old
bindings. Escape cancels a pending conflict. Ambiguous duplicate bindings loaded
directly from a config do not activate several actions.

Bindings remain active after tab changes, widget disposal, and hiding the window.
Register actions at startup if they must work before their toggle is first drawn:

```lua
local unregister = Rere.RegisterKeybind(key, function()
    enabled:set(not enabled.value)
end, "Auto Parry")

-- Reserve a key for an action such as hiding the UI.
Rere.RegisterKeybind(hideKey, function()
    opened:set(not opened.value)
end, "Hide UI")
Rere.BeginKeybindCapture(hideKey)
```

`RegisterKeybind` returns an unregister function; call it when removing a feature
permanently. Registrations are cleared by `Rere.Shutdown()` and do not stack input
listeners across reloads. Changing the bound State updates the button and action.

Optional integration callbacks:

```lua
Rere.ConfigureKeybinds({
    CanTrigger = function() return not gameMenuOpen end,
    OnCaptureChanged = function(stateIdOrNil) end,
    OnConflictChanged = function(conflictOrNil) end,
    OnTriggered = function(stateId) end,
})
```

`CanTrigger` filters shortcut activation, not key capture. Shortcuts are ignored
while typing in a TextBox, during capture, during conflict confirmation, or when
Roblox marks the input as processed. Use `IsCapturingKeybind()` and
`HasKeybindConflict()` to pause conflicting game helpers. Listen to the states'
`onChange` callbacks to save configuration or update your feature logic.
