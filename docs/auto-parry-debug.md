# Auto Parry Debugger

`examples/auto_parry_debug.lua` is a complete executor example. It loads the Rere bundle, installs the Gakuran auto-parry controller, and opens a four-tab diagnostics window.

## Quick start

1. Run the complete Lua file in an executor connected to the target client.
2. Confirm the `Auto Parry Debugger` window appears.
3. Watch `Dashboard > Triggers` while another player attacks nearby.
4. Tune `Radius`, `Hold time`, and `Cooldown` under `Controls`.
5. Press `H` to toggle the controller without closing the window.

The file is self-contained and does not require inserting a ModuleScript into the game. Re-running it first stops the previous `_G.__CodexAutoParry` instance, preventing duplicate listeners.

## Runtime pipeline

### Detection

The controller subscribes to each other player's `Humanoid.Animator.AnimationPlayed` signal. It accepts `Action` through `Action4`, ignores locomotion names (`idle`, `walk`, `run`, `jump`, `fall`, `land`, `swim`, `climb`, `sit`, and `dash`), and then checks:

- local and target Humanoids are alive;
- both characters have a `HumanoidRootPart`;
- target distance is within `Radius`;
- target look vector faces the local character; and
- local `Ragdoll`, `Downed`, `GrappleWinnerStun`, and `CantAnything` attributes are not active.

### Block action

The script resolves `ReplicatedStorage.CombatSystemClient.Combat.<CombatType>.Block`, with `Base` fallback. It writes `_G.__GakuranAcCombatInputCreditAt["Block.Activated"]`, calls `Block()`, waits `Hold time`, and calls `Unblock()`.

### Debouncing and observability

`Cooldown` prevents duplicate `AnimationPlayed` events from stacking. Every accepted trigger increments `TriggerCount` and writes a timestamped record containing target, distance, and animation ID. The event log retains 40 records and displays up to 25 matching records.

## Debug page

### Dashboard

Shows enabled state, trigger count, listener count, last target, last animation ID, last error, player, and place ID.

### Controls

`Enabled` mirrors the controller state. `Radius` ranges from 2 to 30 studs. `Hold time` ranges from 0.05 to 0.60 seconds. `Cooldown` ranges from 0.05 to 0.80 seconds. `Stop and disconnect` calls `controller.Stop()`, disconnects all listeners, and releases block.

### Event log

The filter is case-insensitive and matches timestamps, event types, player names, and animation IDs. `PARRY #N` entries confirm an accepted reaction; `ERROR` entries identify module lookup or block invocation failures; `TOGGLE` and `STOP` entries confirm lifecycle changes.

### Diagnostics

The page repeats the detection, block, and rollback stages in execution order so a visible symptom can be mapped to the responsible stage.

## Troubleshooting matrix

| Symptom | Check | Adjustment |
| --- | --- | --- |
| Window does not appear | Executor supports `loadstring`/`load` and `game:HttpGet` | Use an executor with both APIs or load the bundled source directly |
| Listener count is zero | Other characters have loaded `Humanoid.Animator` instances | Wait for respawn or rejoin; `CharacterAdded` is handled automatically |
| Trigger count stays zero | Target is outside radius, facing away, or using non-Action priority | Increase radius temporarily and inspect target animation IDs |
| Too many triggers | A movement animation has a different name | Add its lowercase name to `ignored` in the example |
| Block errors appear | Combat type folder or `Block` module is missing | Read `Last error` and inspect `PlayerData.CombatType` |
| Reaction is late | The animation event is close to the hit frame | Lower `Cooldown` and tune `Hold time` between 0.10 and 0.30 seconds |
| Controller remains active | Listeners were not disconnected | Press `H` or run `_G.__CodexAutoParry.Stop()` |

## Rollback

```lua
_G.__CodexAutoParry.Stop()
```

Rollback disables the controller, disconnects player and animation listeners, and calls `Unblock()`. The live Rere window can remain open for inspection after rollback; its status and listener count will reflect the stopped controller.

## Verification checklist

- Dashboard status is `ENABLED`.
- Listener count is greater than zero when other characters are present.
- Trigger count increments during nearby Action-priority attacks.
- Event log records `PARRY #...` with target, distance, and animation ID.
- Stop and disconnect leaves the player unblocked and listener count at zero.
