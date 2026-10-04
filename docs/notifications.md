# RereNotify: animated notifications

RereNotify is a standalone Roblox client notification library. It uses Rere-style dark gray panels, thin borders, Arial titles and body text, muted status colors, and slide/fade animations. It returns a library object; loading it alone does not display anything. It does not require Rere or Iris to be loaded.

## Quick start

Run this on the Roblox client in an executor that supports `loadstring` and `game:HttpGet`:

```lua
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/src/RereNotify.luau")
local RereNotify = assert(loadstring(source, "=RereNotify"))()
local notifications = RereNotify.new({Position = "Center", Width = 360})

notifications:Notify({
    Title = "Configuration saved",
    Text = "Your layout and preferences are ready for next time.",
    Kind = "Success",
    Duration = 4,
})
```

`main` follows the latest published code. For a fixed version, replace `main` in the URL with a commit SHA that contains this library. The existing `v0.1.25` tag predates RereNotify.

For offline loading, save `src/RereNotify.luau` as `RereNotify.luau` in your executor Workspace folder:

```lua
local RereNotify = assert(loadstring(readfile("RereNotify.luau"), "=RereNotify"))()
```

## Placement

| Position | Appearance |
| --- | --- |
| `"Center"` | Horizontally centered at 35% of viewport height, above the midpoint. No X close button. Multiple cards stack around this point. |
| `"BottomRight"` | Bottom-right corner with an X close button. This is the default. |

```lua
local center = RereNotify.new({Position = "Center", Width = 360, MaxVisible = 3})
local corner = RereNotify.new({Position = "BottomRight", Width = 320, Padding = 22})
```

Center cards slide upward into view and fade upward when closed. Bottom-right cards slide in from the right and fade toward the right. Actions, expiry, and programmatic dismissal work in both modes. Width is restricted to fit the viewport. Very tall stacks can extend beyond the top or bottom in Center mode; use a small `MaxVisible` such as 1–3.

## Notification fields

```lua
local notice = notifications:Notify({
    Title = "Update available",
    Text = "A new build is ready to review.",
    Kind = "Info",
    Duration = 8,
    ActionText = "Review update",
    OnAction = function()
        print("Open your update page here")
    end,
    OnClose = function(reason)
        print("Closed:", reason)
    end,
})
```

| Field | Default | Meaning |
| --- | --- | --- |
| `Title` | `"Notification"` | Title, limited to 90 characters. |
| `Text` | `""` | Message, limited to 420 characters; visible body height is capped. |
| `Kind` | `"Info"` | `Info`, `Success`, `Warning`, or `Error`. Unknown kinds use the Info appearance. |
| `Duration` | Manager duration | Seconds, from 0 to 300. `0` stays until closed. |
| `ActionText` | `"Open"` | Button label, limited to 50 characters. |
| `OnAction` | None | Supplying a function shows the action button. The card closes before the callback runs. |
| `OnClose` | None | Optional callback receiving the close reason. |

You can also pass a string: `notifications:Notify("Configuration saved.")`.

Hovering a card pauses its timer by default. The thin bottom line displays remaining lifetime. Queued cards receive their full duration when displayed. Up to 32 cards can wait; adding another closes the oldest queued card.

For a persistent Center notification, provide an action or retain its handle so it can be dismissed; Center has no X.

## Update and dismiss

```lua
notice:Update({Title = "Download complete", Text = "Ready to install.", Duration = 6})
notice:Dismiss()
print(notice:IsClosed())

notifications:Clear()   -- close visible and queued notifications
notifications:Destroy() -- also remove the GUI, disconnect listeners, cancel tweens
```

`Update` supports `Title`, `Text`, and `Duration`. Calling it restarts the lifetime. It does not change kind, actions, or placement. Updates to a closed card do nothing.

Close reasons are `expired`, `dismissed`, `action`, `cleared`, and `queue_limit`. Destroying the manager closes its remaining cards with `cleared`. Do not call `Notify` after `Destroy`; create a new manager instead.

## Constructor options

| Option | Default | Accepted value |
| --- | --- | --- |
| `Parent` | Local player's `PlayerGui` | GUI parent instance. |
| `Name` | `"RereNotifications"` | ScreenGui name. Names do not replace existing managers. |
| `Position` | `"BottomRight"` | `"Center"` or `"BottomRight"`. |
| `Width` | 320 | 240–480 pixels, then restricted by viewport width. |
| `MaxVisible` | 4 | 1–8 visible cards, also limited by available height. |
| `Gap` | 8 | 2–24 pixels between cards. |
| `Padding` | 20 | 8–48 pixels of viewport padding. |
| `Duration` | 4.5 | Default notification lifetime, 0–300 seconds. |
| `Animated` | `true` | Set `false` for immediate placement and removal. |
| `PauseOnHover` | `true` | Set `false` to keep timers running while hovered. |
| `DisplayOrder` | 100000 | ScreenGui display order, 1–1000000. |

The GUI survives respawn. Center mode ignores Roblox's top GUI inset. Constructor options are applied when creating a manager; recreate it to change placement.

## Rerun and unload cleanup

Create the manager once, outside the Rere/Iris render callback. Call `Notify` only when an event occurs, such as a button click or successful save. Calling it every frame would continually fill the queue.

Destroy the previous manager before rerunning:

```lua
local env = getgenv()
if env.MyNotifications then env.MyNotifications:Destroy() end
env.MyNotifications = RereNotify.new({Position = "Center"})

-- Call this when your script unloads:
-- env.MyNotifications:Destroy()
-- env.MyNotifications = nil
```

For Real MCP `live_reload`, register the manager with the provided cleanup state:

```lua
local cleanupState = getfenv().STATE
if type(cleanupState) == "table" then
    cleanupState.onCleanup(function() notifications:Destroy() end)
end
```

## Ready-to-run demos

Center:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/examples/notifications-center.luau"))()
```

Bottom-right:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/examples/notifications.luau"))()
```

The demos replace their previous manager on rerun and stay visible for 30 seconds. Center includes a “Got it” action. Bottom-right shows success, update, and warning examples. The update action is illustrative; connect your own update page through `OnAction`.
