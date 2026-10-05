# Rere beta crash handler

Rere beta shuts down a failed UI instance and opens an independent crash window.
The window does not run the damaged immediate-mode renderer. It randomly picks
one of the 15 entries in [CrashCards.lua](../lib/CrashCards.lua) once per crash.

Every card has a **copy error** button. The report includes the card code, library
version, UTC time and original error/traceback. Card codes are playful labels;
they do not diagnose the actual cause. The original error is the diagnostic.
If the executor has no clipboard API, the button shows **clipboard unavailable**.

## Consumer cleanup

Rere owns its UI, keybind listeners, widget animations and connections. Game
features belong to the consumer, which must register its own cleanup:

```lua
Rere.ConfigureCrashHandler({
    OnTerminate = function(reason)
        app.Stop() -- disconnect features, restore hooks, destroy consumer UI
    end,
    WindowSeconds = 2,
    RepeatThreshold = 3,
    TotalThreshold = 6,
})
```

Rere calls Shutdown first, then OnTerminate once, then opens the crash popup in
PlayerGui, outside the consumer's UI host. Shutdown is idempotent and leaves the
report visible. Close dismisses the report. Rerunning a consumer can call
`Rere.DismissCrash()` on its previous instance.

## External callback errors

Fatal renderer/callback errors stop Rere immediately. For external callbacks
that can recover from occasional failures, report each error:

```lua
local ok, err = xpcall(update, debug.traceback)
if not ok then
    if Rere.ReportError(err) then return end
    warn(err)
end
```

ReportError returns true when the instance has crashed. Defaults stop after
three identical reports within two seconds, or six total reports within two
seconds. Old reports expire. It does not listen to unrelated Roblox errors.
Manual-cycle consumers continue to use Internal._cycle; it now catches errors
from the renderer and exits after shutdown.

## Optional actions

The card data preserves the extra action captions supplied for each card.
Only configured actions are shown, so buttons never pretend to restart a
terminated consumer:

```lua
Rere.ConfigureCrashHandler({
    OnTerminate = app.Stop,
    OnRestart = function()
        -- Load a NEW consumer/library instance here.
    end,
    Actions = {
        ["0xCRY_IN_CORNER"] = function(code, report)
            Rere.DismissCrash()
        end,
    },
})
```

OnRestart is used for the four restart/retry cards. Actions keyed by card code
override that callback and can implement the other playful captions.
Restart never resumes the failed renderer. A failed action keeps the report
open and adds its error.
