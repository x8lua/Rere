# Rere beta error and crash handler

Rere displays a compact error notice for recoverable failures. The running
instance is preserved. Only critical failures shut down the session and show
a centered crash report containing **This session has terminated.**

Both surfaces pick from the same [15 crash cards](../lib/CrashCards.lua).
Every card has **copy error**, including the code, version, UTC time and original
error/traceback. The playful card code is not a diagnosis of the actual cause.
If the executor has no clipboard API, the button shows **clipboard unavailable**.

## Recoverable errors

`Rere.ReportError(err)` shows a small, non-modal notice. It stays open until Close
is clicked; it has no timeout. Repeated reports of the same failing source line
update its occurrence count and retain its original card. Different errors are
queued, with up to 32 waiting reports so a flood cannot allocate unlimited UI.

The **Don't remind me for this error again** checkbox mutes that error for the
current library session. It leaves the current notice and application open.
Unticking restores reminders. Closing a muted notice keeps it muted.
Other errors and critical failures remain visible. Reloading starts a new session.

```lua
local ok, err = xpcall(update, debug.traceback)
if not ok then Rere.ReportError(err) end
```

Repeating a feature error never makes it critical merely because of its count.
No unrelated Roblox or executor errors are monitored.

## Critical failures

Use `Rere.ReportError(err, true)` or `Rere.ShowFatalError(err)` only when the
consumer knows the whole application cannot continue, such as failed startup.

For renderer failures, Rere restores Window/End, ID and config stacks and
continues with the other callbacks and next frame. State and input callbacks
are isolated so one failed control does not stop every other control.

Automatic termination requires at least three failed frames and five continuous
seconds with neither a successful render callback nor a visible interactive
widget in the current frame. A recovered usable frame resets the timer.
An incompatible GUI parent that cannot display any UI is immediately critical.
This is a UI availability check; feature-specific failures must be classified
by the consumer when they affect the entire application.

```lua
Rere.ConfigureCrashHandler({
    OnTerminate = function(reason)
        app.Stop() -- disconnect features, restore hooks, destroy consumer UI
    end,
    UnusableSeconds = 5,
})
```

Rere calls Shutdown first, then OnTerminate once, then creates an independent
crash popup outside the consumer's UI host. Shutdown is idempotent.
Critical failures cannot be muted. `Rere.DismissCrash()` dismisses both types
of report without changing the per-error mute choices.

## Optional critical actions

The card data preserves the extra captions supplied for each card. Only
configured critical actions are shown:

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

OnRestart handles the four restart/retry cards. Code-specific Actions override
it. These callbacks are not used by recoverable notices. Restart never resumes
a terminated renderer. Failed actions leave the crash report open.
