# Auto Parry Debugger

`examples/auto_parry_debug.lua` is a complete executor example. It loads the Rere bundle, installs the Gakuran auto-parry controller, and opens a four-tab diagnostics window.

## Quick start

1. Run the complete Lua file in an executor connected to the target client.
2. Confirm the `Auto Parry Debugger` window appears.
3. Watch `Dashboard > Triggers` while another player attacks nearby.
4. Tune `Radius`, `Hold time`, and `Heavy delay` under `Controls`.
5. Press `H` to toggle the controller without closing the window.

The file is self-contained and does not require inserting a ModuleScript into the game. Re-running it first stops the previous `_G.__CodexAutoParry` instance, preventing duplicate listeners.

## Runtime pipeline

### Detection

The controller subscribes to each other player's `Humanoid.Animator.AnimationPlayed` signal and accepts only these known attack IDs: `83491849294956`, `89420531853362`, `83730275893449`, `106980660082799`, and heavy punch `78888626472394`. Walking and unrelated Action-priority animations are excluded by construction. It then checks:

- local and target Humanoids are alive;
- both characters have a `HumanoidRootPart`;
- target distance is within `Radius`;
- target look vector faces the local character; and
- local `Ragdoll`, `Downed`, `GrappleWinnerStun`, and `CantAnything` attributes are not active.

### Block action

The script resolves `ReplicatedStorage.CombatSystemClient.Combat.<CombatType>.Block`, with `Base` fallback. It mirrors the game's physical `F` handler: for the configured hold time it retries `Block()` once per scheduler step and refreshes `_G.__GakuranAcCombatInputCreditAt["Block.Activated"]`, then calls `Unblock()`. A pulse is accepted only when the game sets `Character.Blocking` to `true`.

### Rapid punches, heavy timing, and observability

Normal punches begin blocking immediately. Heavy punch waits `0.40` seconds after its animation begins. All punches share one block pulse: a new rapid punch extends `BlockingUntil`, so an older timer cannot release block during a newer attack. Every accepted detection increments `TriggerCount` and records attack type, target, distance, and delay.

## Debug page

### Dashboard

Shows enabled state, detection trigger count, accepted and rejected block counts, listener count, last block state, last target, last animation ID, last error, player, and place ID. A trigger confirms detection; only an accepted block confirms the game entered its blocking state.

### Controls

`Enabled` mirrors the controller state. `Radius` ranges from 2 to 30 studs. `Hold time` ranges from 0.05 to 0.60 seconds and controls how far every rapid punch extends the shared pulse. `Heavy delay` defaults to 0.40 seconds. `Stop and disconnect` calls `controller.Stop()`, disconnects all listeners, and releases block.

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
| Triggers rise but accepted blocks do not | The game is rejecting block because of equip, stun, cooldown, guard break, or another combat state | Read `Last block state`; compare with a manual `F` block in the same state |
| Walking triggers a reaction | Running source predates the exact animation allowlist | Reload the current example; only the five documented IDs are accepted |
| Block errors appear | Combat type folder or `Block` module is missing | Read `Last error` and inspect `PlayerData.CombatType` |
| Rapid punches interrupt each other | Running source predates the shared block pulse | Reload the current example and confirm `BLOCK extended` appears in the log |
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
- Accepted blocks increments and `Last block state` reads `Accepted` when the game enters `Character.Blocking`.
- Event log records `PARRY #...` with target, distance, and animation ID.
- Stop and disconnect leaves the player unblocked and listener count at zero.
