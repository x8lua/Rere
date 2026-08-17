# Auto Parry Debugger

`examples/auto_parry_debug.lua` is a complete executor example. It loads the Rere bundle, installs the Gakuran auto-parry controller, and opens a four-tab diagnostics window.

## Quick start

1. Run the complete Lua file in an executor connected to the target client.
2. Confirm the `Auto Parry Debugger` window appears.
3. Watch `Dashboard > Triggers` while another player attacks nearby.
4. Tune `Radius`, `Hold time`, `Timing scale`, `Parry lead`, and lock smoothness under `Controls`.
5. Press `H` to toggle the controller without closing the window.
6. Press `G` to lock the visible opponent nearest the cursor.

The file is self-contained and does not require inserting a ModuleScript into the game. Re-running it first stops the previous `_G.__CodexAutoParry` instance, preventing duplicate listeners.

## Runtime pipeline

### Detection

At startup, the controller scans every `Animation` below `ReplicatedStorage.Animations.Combat`. Exact names `1stM1`, `2ndM1`, `3rdM1`, and `4thM1` are classified as M1 attacks; exact name `M2` is classified as M2. The current game contains 65 matching animations across its combat-style folders. `DescendantAdded` keeps the ID map current when another matching animation appears. Walking and unrelated animations are excluded by construction. It then checks:

- local and target Humanoids are alive;
- both characters have a `HumanoidRootPart`;
- target distance is within `Radius`;
- local `Ragdoll`, `Downed`, `GrappleWinnerStun`, and `CantAnything` attributes are not active.

Facing is intentionally not required. An attacker can begin an allowlisted attack while facing away and turn toward the target during the windup; the animation itself remains the authoritative attack signal.

### Block action

The script resolves `ReplicatedStorage.CombatSystemClient.Combat.<CombatType>.Block`, with `Base` fallback. It mirrors the game's physical `F` handler: for the configured hold time it retries `Block()` once per scheduler step and refreshes `_G.__GakuranAcCombatInputCreditAt["Block.Activated"]`, then calls `Unblock()`. A pulse is accepted only when the game sets `Character.Blocking` to `true`.

When an incoming M1/M2 is detected, the controller also invokes the local M1 module's `Hold("Stop")`, matching the native block-input path. This stops continuing an M1 chain, but an already active attack may remain uncancellable until its recovery state ends.

### Rapid punches, heavy timing, and observability

M1 and M2 use the per-class values in the combat windup table. At `1x` speed, Basic M1 is `0.352s` and Basic M2 is `0.537s`; the other classes use their own combo values. Runtime start delay is `max(0, windup / track.Speed * TimingScale - ParryLead)`. The default `ParryLead` is `0.15s`, which gives the `0.132s` Striker M1 #4 finisher immediate block activation. The block window also includes the lead, so an early block remains active through the calculated hit time. All attacks share one block pulse: a new rapid punch extends `BlockingUntil`, so an older timer cannot release block during a newer attack. Every accepted detection increments `TriggerCount` and records combat style, attack name, target, distance, speed, and delay.

| Class | M1 #1 | M1 #2 | M1 #3 | M1 #4 | M2 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ali | 0.292 | 0.382 | 0.432 | 0.232 | 0.542 |
| Basic | 0.352 | 0.352 | 0.352 | 0.352 | 0.537 |
| Boxing | 0.352 | 0.352 | 0.352 | 0.392 | 0.442 |
| Capoeira | 0.362 | 0.442 | 0.362 | 0.292 | 0.462 |
| Hakari | 0.362 | 0.382 | 0.292 | 0.392 | 0.362 |
| Karate | 0.2895 | 0.327 | 0.402 | 0.477 | 0.4995 |
| Kure | 0.332 | 0.332 | 0.332 | 0.332 | 0.312 |
| MuayThai | 0.312 | 0.312 | 0.312 | 0.312 | 0.612 |
| Slugger | 0.512 | 0.462 | 0.462 | 0.382 | 0.832 |
| Striker | 0.362 | 0.362 | 0.242 | 0.132 | 0.462 |
| WingChun | 0.312 | 0.312 | 0.312 | 0.712 | 0.537 |
| Wrestling | 0.372 | 0.382 | 0.372 | 0.362 | 0.537 |

## Debug page

## Target lock

Press `G` to project each live opponent's `HumanoidRootPart` onto the viewport and lock the player nearest the cursor. While locked, auto-parry ignores all other players. The camera eases toward the locked target every frame; `Lock smoothness` controls that easing, where a lower value moves more gradually and a higher value follows more tightly. Press `G` again to select a different cursor-nearest target, or use `Clear target lock`. The lock clears automatically if the target leaves or becomes unavailable.

### Dashboard

Shows enabled state, detection trigger count, accepted and rejected block counts, listener count, last block state, last rejection reason, last target, last animation ID, last error, player, and place ID. A trigger confirms detection; only an accepted block confirms the game entered its blocking state.

### Controls

`Enabled` mirrors the controller state. `Radius` ranges from 2 to 30 studs. `Hold time` ranges from 0.05 to 0.60 seconds and controls the post-start block duration; the lead is added so early blocks cover the hit timestamp. `Timing scale` defaults to `1.0x`; lower values react earlier and higher values react later. `Parry lead` defaults to `0.15s`; increase it if the log still shows `Stunned=true` at the scheduled block. `Lock smoothness` defaults to `10`; lower values make camera tracking gentler and higher values make it tighter. `Stop and disconnect` calls `controller.Stop()`, disconnects all listeners, and releases block.

### Event log

The filter is case-insensitive and matches timestamps, event types, player names, and animation IDs. `PARRY #N` entries confirm an accepted reaction; `ERROR` entries identify module lookup or block invocation failures; `TOGGLE` and `STOP` entries confirm lifecycle changes.

### Diagnostics

The page repeats the detection, block, and rollback stages in execution order so a visible symptom can be mapped to the responsible stage.

## Troubleshooting matrix

| Symptom | Check | Adjustment |
| --- | --- | --- |
| Window does not appear | Executor supports `loadstring`/`load` and `game:HttpGet` | Use an executor with both APIs or load the bundled source directly |
| Listener count is zero | Other characters have loaded `Humanoid.Animator` instances | Wait for respawn or rejoin; `CharacterAdded` is handled automatically |
| Trigger count stays zero | Target is outside radius or using an unlisted animation | Increase radius temporarily and inspect target animation IDs |
| Triggers rise but accepted blocks do not | The game is rejecting block because of equip, stun, cooldown, guard break, or another combat state | Read `Last block state`; compare with a manual `F` block in the same state |
| Walking triggers a reaction | Running source predates folder-based classification | Reload the current example; only exact `1stM1`-`4thM1` and `M2` names are accepted |
| Block errors appear | Combat type folder or `Block` module is missing | Read `Last error` and inspect `PlayerData.CombatType` |
| Pulses are rejected with `Stunned=true` | Block started at or after hitbox release | Increase `Parry lead`; the default is 0.15 seconds |
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
