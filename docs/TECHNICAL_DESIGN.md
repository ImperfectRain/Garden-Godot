# Technical Design

## Current Architecture

The project uses Godot autoloads for small global systems that coordinate data, garden state, resources, run flow, and meta records.

See `docs/ARCHITECTURE_MAP.md` for the current runtime flow, known responsibility problems, target ownership boundaries, and refactor rules.

## Autoloads

- `ContentDatabase`: loads JSON content from `game/data`.
- `GardenResources`: tracks current Light, Rot, Blood, and Echo resource amounts.
- `GardenManager`: owns the 3x3 grid, Heart Tile placement, and garden trigger dispatch.
- `GardenEffectResolver`: resolves generic garden effect actions. It currently owns `produce_resource`; other actions still use temporary prototype paths.
- `CombatEvents`: scaffold signal bus for player/enemy-facing combat effect requests. It is registered but not used by gameplay yet.
- `Bloomchains`: records temporal trigger chains and tracks largest chain length.
- `JournalManager`: records discovered pieces, Bloomchains, run history, and Saintmoth bond.
- `RunManager`: starts and finishes runs and tracks the current planned room.

## Current Debug Scene

- `res://game/scenes/debug/first_fun_test.tscn`

This scene exists to test the smallest fun loop:

Lantern Lily -> Light -> Saintmoth -> Shield

The debug label is temporary readability instrumentation. It shows resources, health, shield, garden rows, and a small event log so the first fun test can be understood without reading code. The log is capped and currently exists only to validate that Lantern Lily production, Saintmoth Light consumption, shield gain, failed Pulse attempts, and Drifter damage are readable.

## Current Data Files

- `game/data/garden_pieces/mvp_garden_pieces.json`
- `game/data/resources/mvp_resources.json`
- `game/data/enemies/mvp_enemies.json`
- `game/data/rooms/mvp_rooms.json`
- `game/data/rewards/mvp_reward_pools.json`

## MVP Enemy Behavior

The first fun test includes one `Drifter` enemy from `res://game/scenes/enemies/drifter.tscn`. It is a slow `CharacterBody2D` that moves toward the player and applies contact damage through `PlayerController.take_damage()`.

Drifter damage is intentionally low-stress: it uses a short cooldown so contact does not instantly defeat the player. Because damage goes through `take_damage()`, shield absorbs damage before health, making Saintmoth's shield useful without requiring a full combat system yet.

## Temporary Room Loop

The first fun test now uses `game/scripts/core/simple_room_controller.gd` for a minimal survival room objective. The current room starts when `RunManager.start_run()` is called, then the player survives gentle Drifter pressure for 30 seconds.

When the timer completes, the reward choice panel appears. After the player chooses and places one reward, `RunManager.complete_current_room()` advances from the current planned room to the next room id. This is only a debug-room scaffold; it is not the final room system, room clear UI, enemy wave manager, or reward pacing.

## Reward Choice Scaffold

The first fun test includes a temporary reward panel at `res://game/scenes/ui/reward_choice_panel.tscn`. It shows three hardcoded MVP rewards, displays each piece's name, category, and simple description from `ContentDatabase`, and accepts either button clicks or keyboard keys 1/2/3.

Selection currently calls `GardenManager.place_piece_in_first_empty_cell(piece_id)` and auto-places the reward into the first empty non-heart garden cell. This is a scaffold for validating reward readability and garden placement; it is not the final room reward flow, drag-and-drop garden UI, or polished reward screen.

## Garden Interval Ticking

Garden interval production is owned by `GardenManager.process_intervals(delta)`. The method inspects placed garden pieces, reads each JSON trigger with `event == "on_interval"`, advances a per-cell/per-trigger cooldown timer, and applies the trigger when its `cooldown` is reached.

The current Lantern Lily trigger comes from `game/data/garden_pieces/mvp_garden_pieces.json` and produces 1 Light every 5 seconds. Debug scenes should call `GardenManager.process_intervals(delta)` instead of owning production timers.

## Garden Effect Resolution

`GardenEffectResolver` is the generic action resolver for data-defined garden effects. The first migrated action is `produce_resource`: `GardenManager` builds an effect request from the successful trigger context, `GardenEffectResolver` validates the resource id and amount, calls `GardenResources.add(resource_id, amount)`, and returns an effect result.

`GardenManager` still owns resource provenance, trigger success bookkeeping, `piece_triggered`, Bloomchain recording, and follow-up dispatch for now. `grant_player_shield` has not moved yet, so Saintmoth shield cost spending remains in `GardenManager` until a later combat-facing resolver step.

## Combat Event Bus

`CombatEvents` is a generic signal bus for combat-facing effects that need to target players, enemies, or helper spawns without binding gameplay systems to a specific scene. It currently exposes requests for player shield, player damage, enemy damage, and helper spawning.

No current gameplay routes through `CombatEvents` yet. Saintmoth shield still uses the existing `CompanionController.shield_requested` signal and `FirstFunTest` scene connection until a later task moves that behavior deliberately.

## Causal Bloomchain Detection

Bloomchains now support a minimal causal path instead of relying only on triggers happening near each other in time. `GardenManager` creates a `chain_id` when a successful trigger starts a resource source, stores that context per resource, and reuses it when a later trigger spends that resource. Successful triggers can also list `follow_up_events` in JSON; those events are dispatched immediately with the same chain context.

The first causal chain is:

1. Lantern Lily produces Light and starts a chain context.
2. Saintmoth spends that Light on Pulse and grants Shield.
3. Saintmoth's successful trigger dispatches `garden_woke`.
4. Bellflower reacts to `garden_woke` and produces Echo.

`Bloomchains` records steps by `chain_id`, prevents the same piece from triggering twice in one chain, caps chains at `SOFT_CHAIN_CAP`, and records chains of length 3+ through `JournalManager.record_bloomchain()`.

Known limitations:

- Resource source tracking is global per resource, not per individual resource unit.
- Causal follow-up events are simple string events, not a full effect graph.
- Visual chain paths are still debug text only.
- Temporal fallback tracking still exists for non-causal triggers, but first-fun-test Bloomchains should use causal context.

Future improvements should replace this with explicit effect results, per-resource provenance, grid path visualization, and a dedicated chain preview/playback layer.

## Saintmoth Shield Effect Path

Saintmoth's current shield behavior is intentionally simple and signal-based:

1. The player presses Pulse.
2. `PlayerController` asks `GardenManager` to pulse the Heart Tile.
3. `GardenManager._apply_trigger()` handles Saintmoth's `grant_player_shield` trigger.
4. `GardenManager` spends the Light cost first.
5. Only if the spend succeeds, `GardenManager` emits `piece_triggered` and records the Bloomchain step.
6. `CompanionController` listens for the successful Saintmoth trigger and emits `shield_requested`.
7. The first fun test scene connects `shield_requested` to `PlayerController.add_shield`.

This means a failed Pulse with fewer than 2 Light should not grant shield, update `last_trigger`, or create a Bloomchain trigger.

TODO: Replace the scene-specific shield connection with a centralized `EffectResolver`, `CombatEvents`, or equivalent combat effect application autoload once more effects need to target the player, enemies, or world.

## Git LFS Expectations

Likely binary art and audio assets should be tracked with Git LFS through `.gitattributes`. This includes common image, audio, pixel art, layered source, Krita, and Blender files such as `png`, `jpg`, `jpeg`, `webp`, `wav`, `ogg`, `mp3`, `aseprite`, `psd`, `kra`, and `blend`.

Keep placeholder scripts, scenes, JSON data, and documentation in normal Git. If automated exports are added later, review whether `export_presets.cfg` should remain ignored or become committed project configuration.

## Known Temporary Limitations

- Resources are global to the garden instead of stored per tile or per piece.
- Only a partial set of trigger effects is implemented in code; `produce_resource` is routed through `GardenEffectResolver`, while shield spending remains in `GardenManager`.
- Bloomchain causality is minimal and still lacks per-resource-unit provenance or visual path playback.
- Shield application is wired through the current debug scene and companion signal connection; `CombatEvents` exists but is not active yet.
