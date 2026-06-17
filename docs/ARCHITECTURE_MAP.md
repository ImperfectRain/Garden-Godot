# Architecture Map

This document records the current architecture before refactoring. Use it to keep future Codex tasks aligned on file ownership, temporary prototype wiring, and target responsibilities.

## Current Runtime Flow

Current Saintmoth shield flow:

1. Player presses Space.
2. `PlayerController` calls `GardenManager.pulse_selected()`.
3. `GardenManager` delegates the Heart Tile `on_pulse` event to `GardenTriggerSystem`.
4. `GardenTriggerSystem` finds Saintmoth's matching `on_pulse` trigger.
5. `GardenTriggerSystem` asks `GardenManager` to apply the trigger request.
6. `GardenManager` sends the `grant_player_shield` request to `GardenEffectResolver`.
7. `GardenEffectResolver` validates the resource id, cost, and shield amount.
8. `GardenEffectResolver` spends Light through `GardenResources`.
9. If the spend succeeds, `GardenEffectResolver` emits `CombatEvents.player_shield_requested`.
10. `PlayerController` receives the combat event and calls `add_shield()`.
11. `GardenManager` emits `piece_triggered`, records the Bloomchain step, and dispatches follow-up events only after the resolver succeeds.
12. `CompanionController` hears the successful Saintmoth trigger and updates mood only.

Current causal Bloomchain flow:

1. `FirstFunTest` calls `GardenTickSystem.process_intervals(delta)`.
2. `GardenTickSystem` reads the garden cell snapshot from `GardenManager`.
3. `GardenTickSystem` asks `GardenTriggerSystem` for matching `on_interval` triggers.
4. `GardenTickSystem` advances the Lantern Lily interval trigger cooldown.
5. When the cooldown is reached, `GardenTickSystem` asks `GardenManager` to apply the interval trigger request.
6. `GardenManager` sends the `produce_resource` request to `GardenEffectResolver`.
7. `GardenEffectResolver` validates the resource id and amount, then adds Light through `GardenResources`.
8. `GardenManager` stores resource provenance for that Light after the successful effect result.
9. Saintmoth spends Light on a successful Pulse and reuses the chain context.
10. Saintmoth dispatches the `garden_woke` follow-up event.
11. `GardenTriggerSystem` dispatches `garden_woke` to matching garden pieces.
12. Bellflower reacts to `garden_woke` and produces Echo.
13. `Bloomchains` records each step as it happens.
14. When the chain finishes through timeout, cap, repeated-piece protection, or explicit finish, `Bloomchains` records the final chain in `JournalManager` if it has length 3 or more.

Current room/reward flow:

1. `FirstFunTest` starts `RunManager`.
2. `FirstFunTest` starts `SimpleRoomController` with the current room id.
3. `SimpleRoomController` owns the 30-second survival timer and objective text.
4. `FirstFunTest` updates `DebugHUD` with room status and event messages.
5. When the timer completes, `SimpleRoomController` emits `reward_ready`.
6. `FirstFunTest` asks `RewardController` to show rewards.
7. `RewardController` resolves the room's `reward_pool` through `ContentDatabase`.
8. `RewardController` gives the first three available reward ids to `RewardChoicePanel`.
9. `RewardChoicePanel` emits a selected piece id.
10. `RewardController` hides the reward panel and starts pending manual placement for the selected piece.
11. `FirstFunTest` forwards placement input to `RewardController`.
12. `RewardController` moves the placement cursor, confirms placement, or cancels back to reward choice.
13. `GardenGridPanel` displays the pending placement cell and whether it is valid.
14. `RewardController` asks `GardenManager` to place the piece only after the player confirms a valid cell.
15. `RewardController` emits reward claimed or failed.
16. `FirstFunTest` completes the room after a successful reward claim.
17. `DebugHUD` owns the temporary text display refresh and event log.
18. `GardenGridPanel` owns the temporary visual 3x3 garden display.

## Current Files and Responsibilities

### `game/scripts/data/content_database.gd`

- Loads JSON content from `game/data`.
- Indexes garden pieces, resources, enemies, rooms, and reward pools.
- Provides lookup helpers for data consumers.

### `game/scripts/garden/garden_manager.gd`

- Owns garden grid state, Heart Tile placement, cell lookup, and placement validation.
- Owns current garden selected cell state and emits selection changes.
- Owns read-only adjacency query helpers for current placement-sensitive effect work.
- Currently also owns low-level trigger application, resource source-batch provenance, follow-up event handoff, and legacy first-empty-cell helper behavior.
- Provides `get_all_cells()` so systems can read garden state without mutating it.
- Delegates `produce_resource` action application to `GardenEffectResolver`.

### `game/scripts/garden/garden_tick_system.gd`

- Autoload for interval and cooldown ticking.
- Owns interval timer storage, timer key generation, and per-cell timer clearing.
- Observes `GardenManager.grid_reset`, `piece_placed`, and `piece_removed` to clear stale timers.
- Reads placed piece data from `GardenManager.get_all_cells()` and interval trigger matches from `GardenTriggerSystem`.
- Asks `GardenManager` to apply interval triggers when cooldowns complete.

### `game/scripts/garden/garden_trigger_system.gd`

- Autoload for event-to-trigger lookup.
- Finds triggers on a single garden cell for a named event.
- Dispatches global garden events to all matching placed pieces.
- Uses `ContentDatabase` for trigger data and `GardenManager` for cell occupancy and low-level trigger application.

### `game/scripts/garden/garden_effect_resolver.gd`

- Autoload for generic effect action application.
- Currently resolves `produce_resource` requests by validating resource data and adding resources through `GardenResources`.
- Currently resolves `grant_player_shield` requests by spending the configured resource cost and emitting a generic player shield request through `CombatEvents`.
- Recognizes additional generic primitives for consumption, storage, enemy damage requests, helper spawn requests, repeats, resource movement, output copying, production modification, adjacent protection, and flora connection markers.
- Emits `effect_resolved` or `effect_failed` for result observers.
- Does not own UI display, piece-specific trigger lookup, or final enemy/helper implementation.

### `game/scripts/combat/combat_events.gd`

- Autoload scaffold for player/enemy-facing combat effect requests.
- Defines generic signals for player shield, player damage, enemy damage, and helper spawning.
- Routes current player shield requests from `GardenEffectResolver` to interested combat receivers.
- Exists to replace scene-specific combat wiring in focused steps.

### `game/scripts/garden/bloomchain_manager.gd`

- Records temporal and causal trigger chains.
- Tracks largest chain this run.
- Emits chain signals for debug display.
- Emits step signals immediately.
- Records journal Bloomchains when chains finish, not when they first reach length 3.

### `game/scripts/garden/resource_manager.gd`

- Tracks global MVP resource totals for Light, Rot, Blood, and Echo.
- Emits resource changed, spent, and failed signals.

### `game/scripts/companion/companion_controller.gd`

- Follows the player.
- Listens for successful Saintmoth triggers.
- Updates companion mood after Saintmoth shield triggers.
- Does not apply player shield.

### `game/scripts/player/player_controller.gd`

- Owns player movement.
- Handles health and shield state.
- Calls `GardenManager.pulse_selected()` when Pulse is pressed.
- Listens for `CombatEvents.player_shield_requested` and applies shield.
- Applies damage with shield-before-health behavior.

### `game/scripts/core/run_manager.gd`

- Owns run lifecycle, planned room order, current room index, run reset, and run summary.

### `game/scripts/core/simple_room_controller.gd`

- Owns the temporary first-fun-test survival timer.
- Owns reward-ready state for the temporary room.
- Emits room started, room completed, and reward ready signals.
- Provides room objective text for debug display.
- Can be stopped when the player is defeated.

### `game/scripts/core/reward_controller.gd`

- Owns temporary reward availability for the first fun test.
- Shows and hides the reward panel through a small API.
- Receives selected reward ids from `RewardChoicePanel`.
- Owns pending reward placement state, placement cursor movement, confirm/cancel handling, and final placement requests.
- Places selected rewards through `GardenManager.place_piece()` only after player confirmation.
- Emits `reward_claimed` or `reward_failed` results.

### `game/scripts/ui/reward_choice_panel.gd`

- Presents reward choices supplied by `RewardController`.
- Displays name, category, and simple description.
- Emits `reward_selected`.
- Does not place rewards or decide whether a reward is currently available.

### `game/scripts/ui/garden_grid_panel.gd`

- Displays the temporary visual 3x3 garden grid.
- Observes placement, trigger, and selection signals from `GardenManager`.
- Shows selected-cell and pending-placement highlights.
- Uses temporary hardcoded placeholder icon paths until `visual_asset` resolution is data-driven.

### `game/scripts/ui/debug_hud.gd`

- Owns the temporary first fun test debug label.
- Owns the capped event log, room status text, last Bloomchain text, and display refresh.
- Reads player state and debug global singletons for display only.
- Does not own gameplay rules.

### `game/scripts/ui/garden_grid_panel.gd`

- Owns the temporary visual 3x3 garden grid display.
- Shows empty cells, placed pieces, simple category distinction, and the Heart Tile.
- Listens to garden placement/reset/trigger signals and refreshes display state.
- Does not own placement, trigger, or garden effect rules.

### `game/scripts/core/first_fun_test.gd`

- Temporary debug scene glue.
- Starts the run and room controller.
- Starts the reward flow when the survival room completes.
- Completes the room after `RewardController` reports a successful reward claim.
- Sends high-level status, room info, Bloomchain, and event messages to `DebugHUD`.

## Responsibility Problems

- `GardenManager` owns grid state, low-level trigger application, resource provenance, follow-up event handoff, and reward placement helpers.
- `GardenTickSystem` owns interval ticking, but it still asks `GardenManager` to apply completed triggers.
- `GardenTriggerSystem` owns event-to-trigger lookup, but `GardenManager` still owns low-level trigger application and follow-up event handoff.
- Effect resolution is partially migrated: `produce_resource` and `grant_player_shield` live in `GardenEffectResolver`, while unsupported actions still fail.
- `first_fun_test.gd` owns run start and prototype wiring.
- `SimpleRoomController` owns temporary room timing, reward readiness, and objective text.
- `RewardController` owns temporary reward availability, reward pool lookup, reward panel show/hide, selection handling, and first-empty-cell placement.
- `DebugHUD` owns temporary debug UI, display refresh, room status text, and event log.
- `GardenGridPanel` owns temporary garden display state and trigger feedback.
- `Bloomchains` records chains and directly calls `JournalManager`.
- Resource provenance is global per resource type rather than per produced resource unit.
- `DebugHUD` is still temporary and debug-only, but it now owns the first fun test display text and event log.

## Target Responsibilities

### `GardenManager`

- Own grid state, placement, cell lookup, and garden-level events only.
- Avoid directly applying gameplay effects long-term.
- New effect actions belong in `GardenEffectResolver`, not in `GardenManager`.

### `GardenTickSystem`

- Own interval and cooldown ticking for garden pieces.
- Read timing from content data.
- Produce trigger requests instead of applying effects directly.
- Do not spend resources, grant shields, damage enemies, or mutate gameplay effects here.
- Current implementation owns timers, asks `GardenTriggerSystem` for interval matches, and delegates completed trigger application back to `GardenManager`.

### `GardenTriggerSystem`

- Own event-to-trigger lookup.
- Build trigger requests from garden events and content data.
- Avoid applying effects directly.
- Current implementation dispatches matching triggers to `GardenManager.apply_trigger_request()`.

### `GardenEffectResolver`

- Own generic action application for data-defined effects.
- Emit effect results for resources, combat, spawning, chain tracking, and UI consumers.
- Avoid knowing about specific debug scenes.
- Do not call `FirstFunTest`, `DebugHUD`, reward panels, or other UI scenes directly.
- Currently owns `produce_resource` and `grant_player_shield`; future tasks should move one additional action at a time.

### `CombatEvents`

- Route player/enemy-facing effects such as shield, damage, healing, spawning, and knockback.
- Continue replacing scene-specific combat wiring.
- Stay generic; avoid Saintmoth-specific, Drifter-specific, or debug-scene-specific behavior.

### `Bloomchains`

- Record causal trigger/effect chains.
- Emit chain results.
- Avoid directly hardcoding journal persistence long-term.
- Current implementation still calls `JournalManager` directly, but only at chain finish.

### `RunManager`

- Own run lifecycle only.
- Avoid room objectives, reward timing, enemy waves, and debug presentation.

### `RoomController`

- Own room objective state and reward timing.
- Current implementation is `SimpleRoomController`, which owns the temporary survival timer and reward-ready signal.

### `RewardController`

- Own reward selection flow and reward pool resolution.
- Keep reward presentation separate in `RewardChoicePanel`.
- Current implementation owns reward availability and placement, but hardcoded choices remain in `RewardChoicePanel`.

### `RewardChoicePanel`

- Own reward presentation and player selection input.
- Avoid deciding placement rules or reward pools long-term.

### `DebugHUD`

- Own temporary debug display and event log.
- Observe system signals instead of owning gameplay rules.
- Current implementation receives high-level updates from `FirstFunTest` and reads debug-only singleton state for display.

### `GardenGridPanel`

- Own temporary visual garden display.
- Observe garden state and trigger signals.
- Avoid owning placement rules, reward rules, trigger lookup, or effect logic.

### `FirstFunTest`

- Remain temporary debug scene glue only.
- Wire prototype presentation, not permanent gameplay rules.
- Do not add reusable gameplay mechanics here; create or extend a system instead.
- Forward display state to `DebugHUD` instead of composing HUD text directly.
- Start reward flow through `RewardController` instead of placing rewards directly.
- React to room and reward result signals instead of owning their internal state.

## Refactor Rules

- Preserve current playable behavior unless a task explicitly changes it.
- Move one responsibility at a time.
- Keep commits focused on one refactor step.
- Add scaffolds before moving behavior when that lowers risk.
- Keep data definitions stable unless the task is explicitly schema/content work.
- Update `docs/TECHNICAL_DESIGN.md`, `docs/ARCHITECTURE_MAP.md`, `docs/CONTENT_SCHEMA.md`, `docs/MANUAL_TESTS.md`, and `docs/COMMIT_LOG.md` when relevant.
- Prefer generic systems that can support future Flora, Fauna, Objects, companions, enemies, rooms, and effects.
- Do not hardcode a mechanic to a specific piece id unless the task explicitly says it is temporary debug wiring.
- Do not reintroduce scene-specific combat effect application; route combat-facing effects through `CombatEvents`.
- Do not reintroduce scene-owned reward choices; route rewards through room data and reward pools.

## Do Not Do Yet

- Do not add new garden pieces.
- Do not add new companions.
- Do not add bosses, biomes, procedural generation, art polish, or additional resources.
- Do not build a polished reward UI or drag-and-drop garden placement yet.
- Do not replace the whole prototype scene in one refactor.
- Do not move multiple architecture responsibilities in a single task.
- Do not remove the current first fun test until an equivalent test scene exists.
