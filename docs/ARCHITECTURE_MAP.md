# Architecture Map

This document records the current architecture before refactoring. Use it to keep future Codex tasks aligned on file ownership, temporary prototype wiring, and target responsibilities.

## Current Runtime Flow

Current Saintmoth shield flow:

1. Player presses Space.
2. `PlayerController` calls `GardenManager.pulse_selected()`.
3. `GardenManager` finds the Saintmoth `on_pulse` trigger on the Heart Tile.
4. `GardenManager` spends Light through `GardenResources`.
5. If the spend succeeds, `GardenManager` emits `piece_triggered`.
6. `CompanionController` hears the Saintmoth trigger.
7. `CompanionController` emits `shield_requested`.
8. `FirstFunTest` connects `shield_requested` to `player.add_shield`.

Current causal Bloomchain flow:

1. Lantern Lily produces Light through an interval trigger.
2. `GardenManager` sends the `produce_resource` request to `GardenEffectResolver`.
3. `GardenEffectResolver` validates the resource id and amount, then adds Light through `GardenResources`.
4. `GardenManager` stores resource provenance for that Light after the successful effect result.
5. Saintmoth spends Light on a successful Pulse and reuses the chain context.
6. Saintmoth dispatches the `garden_woke` follow-up event.
7. Bellflower reacts to `garden_woke` and produces Echo.
8. `Bloomchains` records the causal chain and currently calls `JournalManager.record_bloomchain()` for chains of length 3 or more.

Current room/reward flow:

1. `FirstFunTest` starts `RunManager`.
2. `FirstFunTest` starts `SimpleRoomController` for a 30-second survival timer.
3. When the timer completes, `FirstFunTest` shows `RewardChoicePanel`.
4. `RewardChoicePanel` emits a selected piece id.
5. `FirstFunTest` asks `GardenManager` to place the piece in the first empty non-heart cell.
6. `FirstFunTest` calls `RunManager.complete_current_room()`.

## Current Files and Responsibilities

### `game/scripts/data/content_database.gd`

- Loads JSON content from `game/data`.
- Indexes garden pieces, resources, enemies, rooms, and reward pools.
- Provides lookup helpers for data consumers.

### `game/scripts/garden/garden_manager.gd`

- Owns garden grid state, Heart Tile placement, cell lookup, and placement validation.
- Currently also owns interval ticking, trigger lookup, shield cost spending, resource provenance, follow-up events, and first-empty-cell reward placement.
- Delegates `produce_resource` action application to `GardenEffectResolver`.

### `game/scripts/garden/garden_effect_resolver.gd`

- Autoload for generic effect action application.
- Currently resolves `produce_resource` requests by validating resource data and adding resources through `GardenResources`.
- Emits `effect_resolved` or `effect_failed` for result observers.
- Does not resolve shield, damage, healing, spawning, or other gameplay actions yet.

### `game/scripts/garden/bloomchain_manager.gd`

- Records temporal and causal trigger chains.
- Tracks largest chain this run.
- Emits chain signals for debug display.
- Currently records journal Bloomchains directly.

### `game/scripts/garden/resource_manager.gd`

- Tracks global MVP resource totals for Light, Rot, Blood, and Echo.
- Emits resource changed, spent, and failed signals.

### `game/scripts/companion/companion_controller.gd`

- Follows the player.
- Listens for successful Saintmoth triggers.
- Emits `shield_requested` after Saintmoth has paid its Light cost.

### `game/scripts/player/player_controller.gd`

- Owns player movement.
- Handles health and shield state.
- Calls `GardenManager.pulse_selected()` when Pulse is pressed.
- Applies damage with shield-before-health behavior.

### `game/scripts/core/run_manager.gd`

- Owns run lifecycle, planned room order, current room index, run reset, and run summary.

### `game/scripts/core/simple_room_controller.gd`

- Owns the temporary first-fun-test survival timer.
- Reports when the survival objective completes.

### `game/scripts/ui/reward_choice_panel.gd`

- Presents three hardcoded reward choices.
- Displays name, category, and simple description.
- Emits `reward_selected`.

### `game/scripts/core/first_fun_test.gd`

- Temporary debug scene glue.
- Starts the run and room timer.
- Wires Saintmoth shield requests to the player.
- Wires reward selection to garden placement.
- Owns debug UI text, event log, room status text, and prototype feedback.

## Responsibility Problems

- `GardenManager` owns grid state, ticking, trigger lookup, shield effect cost spending, resource provenance, follow-up events, and reward placement helpers.
- Effect resolution is partially migrated: `produce_resource` lives in `GardenEffectResolver`, while `grant_player_shield` still lives in `GardenManager`.
- `first_fun_test.gd` owns debug UI, room timing, rewards, run start, event log, and prototype wiring.
- `Bloomchains` records chains and directly calls `JournalManager`.
- Saintmoth shield behavior is still scene-wired through `FirstFunTest`.
- Reward choices are hardcoded in `RewardChoicePanel`.
- Resource provenance is global per resource type rather than per produced resource unit.
- Debug display is mixed into scene glue rather than isolated in a `DebugHUD`.

## Target Responsibilities

### `GardenManager`

- Own grid state, placement, cell lookup, and garden-level events only.
- Avoid directly applying gameplay effects long-term.

### `GardenTickSystem`

- Own interval and cooldown ticking for garden pieces.
- Read timing from content data.
- Produce trigger requests instead of applying effects directly.

### `GardenTriggerSystem`

- Own event-to-trigger lookup.
- Build trigger requests from garden events and content data.
- Avoid applying effects directly.

### `GardenEffectResolver`

- Own generic action application for data-defined effects.
- Emit effect results for resources, combat, spawning, chain tracking, and UI consumers.
- Avoid knowing about specific debug scenes.
- Currently owns `produce_resource`; future tasks should move one additional action at a time.

### `CombatEvents`

- Route player/enemy-facing effects such as shield, damage, healing, spawning, and knockback.
- Replace scene-specific Saintmoth shield wiring.

### `Bloomchains`

- Record causal trigger/effect chains.
- Emit chain results.
- Avoid directly hardcoding journal persistence long-term.

### `RunManager`

- Own run lifecycle only.
- Avoid room objectives, reward timing, enemy waves, and debug presentation.

### `RoomController`

- Own room objective state and reward timing.

### `RewardController`

- Own reward selection flow and reward pool resolution.
- Keep reward presentation separate in `RewardChoicePanel`.

### `RewardChoicePanel`

- Own reward presentation and player selection input.
- Avoid deciding placement rules or reward pools long-term.

### `DebugHUD`

- Own temporary debug display and event log.
- Observe system signals instead of owning gameplay rules.

### `FirstFunTest`

- Remain temporary debug scene glue only.
- Wire prototype presentation, not permanent gameplay rules.

## Refactor Rules

- Preserve current playable behavior unless a task explicitly changes it.
- Move one responsibility at a time.
- Keep commits focused on one refactor step.
- Add scaffolds before moving behavior when that lowers risk.
- Keep data definitions stable unless the task is explicitly schema/content work.
- Update `docs/TECHNICAL_DESIGN.md`, `docs/ARCHITECTURE_MAP.md`, `docs/CONTENT_SCHEMA.md`, `docs/MANUAL_TESTS.md`, and `docs/COMMIT_LOG.md` when relevant.
- Prefer generic systems that can support future Flora, Fauna, Objects, companions, enemies, rooms, and effects.

## Do Not Do Yet

- Do not add new garden pieces.
- Do not add new companions.
- Do not add bosses, biomes, procedural generation, art polish, or additional resources.
- Do not build a polished reward UI or drag-and-drop garden placement yet.
- Do not replace the whole prototype scene in one refactor.
- Do not move multiple architecture responsibilities in a single task.
- Do not remove the current first fun test until an equivalent test scene exists.
