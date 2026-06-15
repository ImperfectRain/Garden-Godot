# Technical Design

## Current Architecture

The project uses Godot autoloads for small global systems that coordinate data, garden state, resources, run flow, and meta records.

See `docs/ARCHITECTURE_MAP.md` for the current runtime flow, known responsibility problems, target ownership boundaries, and refactor rules.

## Autoloads

- `ContentDatabase`: loads JSON content from `game/data`.
- `GardenResources`: tracks current Light, Rot, Blood, and Echo resource amounts.
- `GardenManager`: owns the 3x3 grid, Heart Tile placement, and low-level trigger application.
- `GardenTickSystem`: owns interval cooldown timers and interval trigger ticking.
- `GardenTriggerSystem`: owns event-to-trigger lookup for cell and global garden events.
- `GardenEffectResolver`: resolves generic garden effect actions. It currently owns `produce_resource` and `grant_player_shield`; other actions still use temporary prototype paths.
- `CombatEvents`: signal bus for player/enemy-facing combat effect requests. It currently routes player shield requests.
- `Bloomchains`: records temporal trigger chains and tracks largest chain length.
- `JournalManager`: records discovered pieces, Bloomchains, run history, and Saintmoth bond.
- `RunManager`: starts and finishes runs and tracks the current planned room.

## Current Debug Scene

- `res://game/scenes/debug/first_fun_test.tscn`

This scene exists to test the smallest fun loop:

Lantern Lily -> Light -> Saintmoth -> Shield

The debug HUD is temporary readability instrumentation. It shows resources, health, shield, garden rows, room state, last Bloomchain, and a small event log so the first fun test can be understood without reading code. The log is capped and currently exists only to validate that Lantern Lily production, Saintmoth Light consumption, shield gain, failed Pulse attempts, Drifter damage, reward placement, and Bloomchain finalization are readable.

`DebugHUD` lives at `res://game/scenes/ui/debug_hud.tscn` with script `game/scripts/ui/debug_hud.gd`. It is intentionally debug-only and may read global singletons such as `GardenResources` and `GardenManager` for display. Gameplay rules should not move into this HUD.

## Current Data Files

- `game/data/garden_pieces/mvp_garden_pieces.json`
- `game/data/resources/mvp_resources.json`
- `game/data/enemies/mvp_enemies.json`
- `game/data/rooms/mvp_rooms.json`
- `game/data/rewards/mvp_reward_pools.json`

## Content Validation

`ContentDatabase.load_all()` validates loaded garden piece content and duplicate ids in indexed collections. Validation errors are stored in `ContentDatabase.validation_errors` and also emitted through `content_load_failed(path, reason)` so debug scenes or editor tooling can show problems clearly.

Garden piece validation currently checks required fields, allowed categories, and required trigger fields. This validation is intentionally non-blocking for parseable JSON so prototype content can still load while problems are reported. Invalid JSON roots still fail that file load and return an empty collection.

## MVP Enemy Behavior

The first fun test includes one `Drifter` enemy from `res://game/scenes/enemies/drifter.tscn`. It is a slow `CharacterBody2D` that moves toward the player and applies contact damage through `PlayerController.take_damage()`.

Drifter damage is intentionally low-stress: it uses a short cooldown so contact does not instantly defeat the player. Because damage goes through `take_damage()`, shield absorbs damage before health, making Saintmoth's shield useful without requiring a full combat system yet.

## Temporary Room Loop

The first fun test uses `game/scripts/core/simple_room_controller.gd` for a minimal survival room objective. `SimpleRoomController` owns the default 30-second survival duration, active/completed/reward-ready state, objective text, and room flow signals.

Current signal flow:

1. `FirstFunTest` starts the run through `RunManager.start_run()`.
2. `FirstFunTest` starts `SimpleRoomController` with the current room id.
3. `SimpleRoomController.process(delta)` advances the survival timer.
4. When the timer completes, `SimpleRoomController` emits `reward_ready(room_id)`.
5. `FirstFunTest` responds by asking `RewardController` to show rewards.
6. After `RewardController` emits `reward_claimed`, `FirstFunTest` calls `RunManager.complete_current_room()`.

Player defeat calls `SimpleRoomController.stop()`, preventing the room timer from reaching reward readiness. This remains a debug-room scaffold; it is not the final room system, room clear UI, enemy wave manager, or reward pacing.

## Reward Choice Scaffold

The first fun test includes a temporary reward panel at `res://game/scenes/ui/reward_choice_panel.tscn`. It displays the reward ids it is given, looks up each piece's name, category, and simple description from `ContentDatabase`, and accepts either button clicks or keyboard keys 1/2/3.

`RewardController` lives at `game/scripts/core/reward_controller.gd`. It tracks whether a reward is currently available, resolves the current room's `reward_pool` through `ContentDatabase.get_room(room_id)` and `ContentDatabase.get_reward_pool(pool_id)`, passes reward ids to `RewardChoicePanel.set_rewards(piece_ids)`, receives selected reward ids, places the reward through `GardenManager.place_piece_in_first_empty_cell(piece_id)`, and emits reward claim or failure results back to the scene.

For now, reward selection uses the first three available piece ids from the room's pool, skipping pieces already placed in the garden. This keeps the Meadow room data-driven through `general_garden_piece` while still offering useful new pieces. This is a scaffold for validating reward readability and garden placement; it is not the final room reward flow, weighted reward resolver, drag-and-drop garden UI, or polished reward screen.

## Debug HUD

`DebugHUD` owns the temporary debug label, capped event log, room status text, last Bloomchain text, and display refresh. `FirstFunTest` should call high-level HUD methods such as `set_status()`, `add_event()`, `set_room_info()`, `set_last_bloomchain()`, and `refresh()` instead of assembling debug text directly.

The HUD may read current resources and garden rows from global singletons for debug display only. Do not use it as a gameplay dependency.

## Garden Interval Ticking

Garden interval production is owned by `GardenTickSystem.process_intervals(delta)`. The system inspects placed garden pieces through `GardenManager.get_all_cells()`, asks `GardenTriggerSystem` for JSON triggers with `event == "on_interval"`, advances a per-cell/per-trigger cooldown timer, and asks `GardenManager` to apply the trigger when its `cooldown` is reached.

The current Lantern Lily trigger comes from `game/data/garden_pieces/mvp_garden_pieces.json` and produces 1 Light every 5 seconds. Debug scenes should call `GardenTickSystem.process_intervals(delta)` instead of owning production timers.

`GardenTickSystem` owns the interval timer dictionary, timer key generation, and stale timer clearing. It resets timers on `GardenManager.grid_reset` and clears a cell's timers when `GardenManager.piece_placed` or `GardenManager.piece_removed` fires.

## Garden Trigger Lookup

`GardenTriggerSystem` owns event-to-trigger lookup. `trigger_cell_event(cell, event_name, context)` finds matching triggers for the piece in one cell. `trigger_global_event(event_name, context)` checks every placed piece and dispatches matching triggers. `get_matching_triggers(piece_id, event_name)` is the shared lookup helper used by both direct cell events and interval ticking.

`GardenManager` still owns low-level trigger application through `apply_trigger_request(cell, piece_id, trigger, context)`, including effect request construction, success bookkeeping, Bloomchain recording, resource provenance, and follow-up event handoff. This keeps the extraction focused; a later task can move trigger request construction and follow-up ownership further out of `GardenManager`.

## Garden Effect Resolution

`GardenEffectResolver` is the generic action resolver for data-defined garden effects. For `produce_resource`, `GardenManager` builds an effect request from the successful trigger context, `GardenEffectResolver` validates the resource id and amount, calls `GardenResources.add(resource_id, amount)`, and returns an effect result.

For `grant_player_shield`, `GardenEffectResolver` validates the resource id, cost, and shield amount, spends the resource through `GardenResources.spend()`, and emits `CombatEvents.player_shield_requested`. `GardenManager` still owns resource provenance, trigger success bookkeeping, `piece_triggered`, Bloomchain recording, and follow-up dispatch for now.

## Combat Event Bus

`CombatEvents` is a generic signal bus for combat-facing effects that need to target players, enemies, or helper spawns without binding gameplay systems to a specific scene. It currently exposes requests for player shield, player damage, enemy damage, and helper spawning.

Player shield requests now route through `CombatEvents.player_shield_requested`. `PlayerController` listens for that signal and applies shield with `add_shield(amount)`. Player damage, enemy damage, and helper spawning are still scaffold-only signals.

## Causal Bloomchain Detection

Bloomchains now support a minimal causal path instead of relying only on triggers happening near each other in time. `GardenManager` creates a `chain_id` when a successful trigger starts a resource source, stores that context per resource, and reuses it when a later trigger spends that resource. Successful triggers can also list `follow_up_events` in JSON; those events are dispatched immediately with the same chain context.

The first causal chain is:

1. Lantern Lily produces Light and starts a chain context.
2. Saintmoth spends that Light on Pulse and grants Shield.
3. Saintmoth's successful trigger dispatches `garden_woke`.
4. Bellflower reacts to `garden_woke` and produces Echo.

`Bloomchains` records steps by `chain_id`, prevents the same piece from triggering twice in one chain, and caps chains at `SOFT_CHAIN_CAP`. Step events can emit immediately through `chain_step_added`, but `JournalManager.record_bloomchain()` and `chain_finished` happen only when the chain finishes through timeout, cap, repeated-piece protection, or an explicit finish.

This finish-time recording means a future chain longer than 3 records its final length instead of only the first 3 steps.

Known limitations:

- Resource source tracking is global per resource, not per individual resource unit.
- Causal follow-up events are simple string events, not a full effect graph.
- A chain that times out before reaching 3 steps is finalized without journal recording.
- Visual chain paths are still debug text only.
- Temporal fallback tracking still exists for non-causal triggers, but first-fun-test Bloomchains should use causal context.

Future improvements should replace this with explicit effect results, per-resource provenance, grid path visualization, and a dedicated chain preview/playback layer.

## Saintmoth Shield Effect Path

Saintmoth's current shield behavior is intentionally simple and signal-based:

1. The player presses Pulse.
2. `PlayerController` asks `GardenManager` to pulse the Heart Tile.
3. `GardenManager._apply_trigger()` builds a generic `grant_player_shield` effect request.
4. `GardenEffectResolver` spends the Light cost and emits `CombatEvents.player_shield_requested`.
5. `PlayerController` receives the combat event and calls `add_shield(amount)`.
6. Only if the resolver succeeds, `GardenManager` emits `piece_triggered` and records the Bloomchain step.
7. `CompanionController` listens for the successful Saintmoth trigger and updates mood.

This means a failed Pulse with fewer than 2 Light should not grant shield, update `last_trigger`, or create a Bloomchain trigger.

TODO: Route future player damage, enemy damage, healing, helper spawning, and other combat-facing actions through `GardenEffectResolver` and `CombatEvents` one action at a time.

## Git LFS Expectations

Likely binary art and audio assets should be tracked with Git LFS through `.gitattributes`. This includes common image, audio, pixel art, layered source, Krita, and Blender files such as `png`, `jpg`, `jpeg`, `webp`, `wav`, `ogg`, `mp3`, `aseprite`, `psd`, `kra`, and `blend`.

Keep placeholder scripts, scenes, JSON data, and documentation in normal Git. If automated exports are added later, review whether `export_presets.cfg` should remain ignored or become committed project configuration.

## Known Temporary Limitations

- Resources are global to the garden instead of stored per tile or per piece.
- Only a partial set of trigger effects is implemented in code; `produce_resource` and `grant_player_shield` are routed through `GardenEffectResolver`.
- Interval ticking has moved to `GardenTickSystem`, and event-to-trigger lookup has moved to `GardenTriggerSystem`; completed trigger application still routes through `GardenManager`.
- Room objective timing has moved to `SimpleRoomController`, but `FirstFunTest` still wires room-ready and reward-claimed outcomes.
- Bloomchain causality is minimal and still lacks per-resource-unit provenance or visual path playback.
- Shield application now routes through `CombatEvents`, but other combat-facing effects are still not implemented.
