# Commit Log

This file tracks meaningful project changes by task. Each Codex task should append a new entry before committing.

## Format

### YYYY-MM-DD - task-name

#### Summary
- ...

#### Files Changed
- ...

#### Verification
- ...

#### Next Recommended Task
- ...

### 2026-06-14 - docs: add project documentation foundation

#### Summary
- Added the top-level documentation foundation requested for future Codex tasks.
- Kept the MVP design summary concise and contributor-facing.
- Documented the current technical architecture, content schema, controls, and smallest fun loop.

#### Files Changed
- `README.md`
- `docs/GDD_MVP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/CONTENT_SCHEMA.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Confirmed all five required documentation files exist.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- No conflict markers, `TODO`, or `FIXME` markers found in `README.md` or `docs/`.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Make the Lantern Lily -> Light -> Saintmoth -> Shield loop fully playable and verify it in Godot.

### 2026-06-16 - mvp: apply placeholder sprites

#### Summary
- Replaced field polygon placeholders for the player, Saintmoth, and Drifter with imported Kenney `Sprite2D` placeholders.
- Added temporary garden grid icons for current garden piece ids using imported Tiny Town tiles.
- Documented that these visual assignments are development placeholders and should become data-driven through `visual_asset` later.

#### Files Changed
- `game/scenes/debug/first_fun_test.tscn`
- `game/scenes/enemies/drifter.tscn`
- `game/scripts/ui/garden_grid_panel.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed no `Polygon2D` placeholders remain in the first fun test scene or Drifter scene.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Move temporary visual placeholder paths into data-driven `visual_asset` fields and add a small visual asset resolver.

### 2026-06-16 - mvp: add manual garden placement

#### Summary
- Changed reward selection from automatic first-empty placement to pending manual placement.
- Added keyboard placement cursor controls, confirm, cancel, and non-mutating placement validation.
- Added visual Garden panel placement highlighting for valid and invalid target cells.

#### Files Changed
- `game/scripts/core/reward_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/ui/garden_grid_panel.gd`
- `game/scripts/ui/debug_hud.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed reward placement no longer calls `GardenManager.place_piece_in_first_empty_cell()` from `RewardController`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add reusable garden adjacency query helpers so placement can affect production, consumption, copying, and protection.

### 2026-06-16 - mvp: add garden cell selection state

#### Summary
- Added explicit GardenManager selected-cell helpers and a `selected_cell_changed` signal.
- Updated player Pulse to select the Heart Tile through the GardenManager API instead of direct variable assignment.
- Updated the visual Garden panel to highlight the selected cell separately from pending placement.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/player/player_controller.gd`
- `game/scripts/ui/garden_grid_panel.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed direct assignment to `GardenManager.selected_cell` is no longer used outside `GardenManager`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add reusable garden adjacency query helpers for placement-sensitive effects.

### 2026-06-16 - architecture: add garden adjacency queries

#### Summary
- Added read-only GardenManager query helpers for orthogonal/diagonal neighbors, opposite cells, adjacency checks, and category/tag filtering.
- Kept effect application unchanged; helpers are groundwork for placement-sensitive Flora, Fauna, and Object behavior.
- Documented the helper API and current ownership.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add generic effect primitives to `GardenEffectResolver` without wiring every garden piece at once.

### 2026-06-16 - architecture: expand garden effect primitives

#### Summary
- Added generic `GardenEffectResolver` support for current MVP action names beyond Light production and Saintmoth shield.
- Added resource consumption, resource storage, enemy damage request, helper spawn request, repeat/copy/move outputs, production modifier outputs, and marker effects for adjacent protection and Flora connection.
- Routed known generic resolver actions through `GardenManager` so future piece triggers can use them.

#### Files Changed
- `game/scripts/garden/garden_effect_resolver.gd`
- `game/scripts/garden/garden_manager.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/CONTENT_SCHEMA.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add lightweight resource routing/provenance improvements so placement can influence who consumes or modifies produced resources.

### 2026-06-16 - architecture: add resource provenance batches

#### Summary
- Replaced single last-source resource provenance with per-resource source batches.
- Recorded origin cell, origin piece, chain context, and adjacent occupied/category cells when resources are produced.
- Consuming effects now inherit source context for Bloomchain causality and consume source batches after successful resource spends.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed Lantern Lily, Saintmoth, and Bellflower trigger data still supports the first causal Bloomchain path.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Implement Flora triggers beyond Lantern Lily/Bellflower by routing player damage and enemy death garden events.

### 2026-06-16 - mvp: route blood rose damage event

#### Summary
- Added an actual player-damaged combat event after health damage is applied.
- Routed actual player health damage in the first fun test to the existing Blood Rose garden event.
- Added debug feedback for Blood Rose and Gravecap trigger messages.
- Documented current Flora functionality and the remaining Gravecap dependency on enemy death events.

#### Files Changed
- `game/scripts/combat/combat_events.gd`
- `game/scripts/player/player_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git diff --check` passed.
- Parsed all current JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed Blood Rose trigger data still listens for `player_damaged_or_close_kill`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add enemy health/death events so Gravecap can produce Rot and enemy-facing Object effects can matter.

### 2026-06-14 - architecture: add content validation pass

#### Summary
- Added `ContentDatabase.validation_errors` and a non-blocking validation pass during `load_all()`.
- Validates garden piece required fields, allowed categories, and trigger `id`/`event`/`action` fields.
- Reports duplicate ids in indexed collections through the same validation error path.

#### Files Changed
- `game/scripts/data/content_database.gd`
- `docs/CONTENT_SCHEMA.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed all MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Ran a PowerShell mirror of the garden piece validation rules against `mvp_garden_pieces.json`; it reported 0 errors.
- Confirmed validation storage, duplicate-id reporting, and garden-piece validation references exist in `ContentDatabase` and docs.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Surface content validation errors in a debug/editor-facing view if needed.

### 2026-06-14 - architecture: make rewards data driven

#### Summary
- Removed hardcoded default gameplay reward choices from `RewardChoicePanel`.
- Added `RewardChoicePanel.set_rewards(piece_ids)` so the panel displays controller-provided rewards.
- Updated `RewardController` to resolve the current room's reward pool from `ContentDatabase` and choose the first three available rewards.
- Updated `FirstFunTest` to request rewards by room id when the room controller reports reward readiness.

#### Files Changed
- `game/scripts/ui/reward_choice_panel.gd`
- `game/scripts/core/reward_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/CONTENT_SCHEMA.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed all MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed the old hardcoded reward list is no longer present in gameplay scripts.
- Simulated Meadow reward lookup from `mvp_rooms.json` and `mvp_reward_pools.json` with existing starting garden pieces skipped; the first three rewards are `gravecap`, `blood_rose`, and `bellflower`.
- Confirmed `FirstFunTest` now requests rewards through `RewardController.show_rewards_for_room(room_id)`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add validation for room `reward_pool` ids and reward pool `choices` once content validation expands beyond garden pieces.

### 2026-06-14 - mvp: add visible shield feedback

#### Summary
- Added a placeholder player shield ring that appears when shield is active and hides when shield reaches 0.
- Kept shield state in `PlayerController` and moved shield presentation into `PlayerVisualFeedback`.
- Updated the first fun test scene to attach the visual feedback node to the player.
- Added manual test checks for visible shield feedback.

#### Files Changed
- `game/scenes/debug/first_fun_test.tscn`
- `game/scripts/player/player_controller.gd`
- `game/scripts/player/player_visual_feedback.gd`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed all MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed `first_fun_test.tscn` references `PlayerVisualFeedback` under the `Player` node.
- Confirmed `PlayerVisualFeedback` listens to `shield_changed`, draws a placeholder ring, hides at 0 shield, and pulses on shield gain.
- Confirmed manual tests now check visible shield appearance and disappearance.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add a lightweight player damage flash or shield-hit pulse once combat feedback needs more clarity.

### 2026-06-14 - architecture: add system guardrails

#### Summary
- Confirmed obsolete interval production helpers are no longer present in `GardenManager`.
- Added a concise code guardrail at the remaining `GardenManager` trigger application bridge.
- Updated architecture docs to clarify where new effects, interval timing, UI wiring, combat events, and reward choices belong.
- Corrected stale reward responsibility notes after the data-driven reward refactor.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed all MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed `produce_from_intervals` is not present and `GardenManager` no longer owns interval processing.
- Confirmed stale hardcoded reward responsibility text was removed from architecture docs.
- Confirmed `where.exe godot` could not find Godot in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Continue extracting low-level trigger request application out of `GardenManager` when ready.

### 2026-06-14 - mvp: add basic garden grid ui

#### Summary
- Added a temporary `GardenGridPanel` scene and script showing the 3x3 garden visually.
- Displays empty cells, piece names, simple category colors, and a distinct Heart Tile.
- Added signal-driven refreshes for grid reset, placement, removal, and trigger flash feedback.
- Instanced the panel in the first fun test while preserving existing debug text rows.

#### Files Changed
- `game/scenes/ui/garden_grid_panel.tscn`
- `game/scripts/ui/garden_grid_panel.gd`
- `game/scenes/debug/first_fun_test.tscn`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/ARCHITECTURE_MAP.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed all MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed `first_fun_test.tscn` instances `res://game/scenes/ui/garden_grid_panel.tscn`.
- Confirmed the panel connects to `GardenManager` grid reset, placement, removal, and trigger signals.
- Confirmed manual tests now cover the visual 3x3 grid, Heart Tile, placement updates, and trigger feedback.
- `where.exe godot` could not find Godot in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Validate the visual garden panel in Godot and tune its placement/size if it overlaps on target windows.

### 2026-06-15 - data: split content json files

#### Summary
- Replaced master MVP collection JSON files with one JSON object file per garden piece, resource, enemy, room, and reward pool.
- Updated `ContentDatabase` to scan content directories recursively and index JSON entries by stable `id`.
- Kept legacy collection-shaped JSON support in the loader for compatibility, but documented that future content should be added as individual files.
- Updated active and database documentation to describe the new per-file content workflow.

#### Files Changed
- `game/scripts/data/content_database.gd`
- `game/data/garden_pieces/*.json`
- `game/data/resources/*.json`
- `game/data/enemies/*.json`
- `game/data/rooms/*.json`
- `game/data/rewards/*.json`
- `docs/CONTENT_SCHEMA.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/database/CONTENT_SCHEMA.md`
- `docs/database/CODEBASE_INDEX.md`
- `docs/database/systems/content_database.md`
- `docs/database/AI_AGENT_GUIDE.md`
- `docs/database/systems/run_room_system.md`
- `docs/database/systems/companion_system.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed every JSON file under `game/data` with PowerShell `ConvertFrom-Json`.
- Confirmed expected split counts: 12 garden pieces, 4 resources, 4 enemies, 5 rooms, and 4 reward pools.
- Ran a content split validation pass for duplicate ids, id/filename mismatches, garden piece required fields, allowed categories, and trigger `id`/`event`/`action`; it reported 0 errors.
- Confirmed old master MVP JSON files were removed from `game/data`.
- Confirmed stale active references to old master JSON paths are gone; remaining matches are historical commit log text only.
- `where.exe godot` could not find Godot in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add validation for room reward pools, reward choices, resource ids, and enemy ids now that content can scale file-by-file.

### 2026-06-16 - assets: add kenney placeholder packs

#### Summary
- Imported Kenney Tiny Town and Kenney Roguelike/RPG Pack under `game/art/external/kenney/`.
- Added an external asset README with source URLs, CC0 license notes, and placeholder usage rules.
- Documented that Sprout Lands and Cozy Farm were not imported because their free/paid licenses are not repo-redistribution friendly.
- Updated technical and database docs to list the imported external placeholder assets.

#### Files Changed
- `game/art/external/kenney/`
- `docs/TECHNICAL_DESIGN.md`
- `docs/database/CODEBASE_INDEX.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Confirmed 141 PNG files were imported under `game/art/external/kenney/`.
- Confirmed both imported packs include `License.txt` files stating Creative Commons Zero, CC0, and personal/commercial use.
- Confirmed representative PNG files resolve to Git LFS through `git check-attr filter`.
- Confirmed `git lfs version` reports Git LFS is installed.
- Parsed all current `game/data` JSON files with PowerShell `ConvertFrom-Json`.
- `where.exe godot` could not find Godot in PATH, so editor-level import validation was not run.

#### Next Recommended Task
- Map a small subset of imported placeholder sprites to player, Drifter, Saintmoth, garden pieces, and room floor visuals through scenes or `visual_asset` data fields.

### 2026-06-14 - architecture: add garden effect resolver scaffold

#### Summary
- Added `GardenEffectResolver` as an autoload scaffold for future generic effect resolution.
- Documented the intended effect request/result shapes in the resolver script.
- Updated architecture and technical docs to show the resolver exists but does not own current gameplay behavior yet.

#### Files Changed
- `project.godot`
- `game/scripts/garden/garden_effect_resolver.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `project.godot`, `garden_effect_resolver.gd`, and docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `GardenEffectResolver` is registered as an autoload.
- Confirmed no gameplay code calls `GardenEffectResolver` yet.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Route resource production through `GardenEffectResolver` without changing player-facing behavior.

### 2026-06-14 - architecture: route resource production through effect resolver

#### Summary
- Moved `produce_resource` action application from `GardenManager` into `GardenEffectResolver`.
- Kept GardenManager responsible for trigger success bookkeeping, resource provenance, Bloomchain recording, and follow-up dispatch.
- Left Saintmoth shield spending in `GardenManager` for a later focused combat effect refactor.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/garden/garden_effect_resolver.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only GardenManager, GardenEffectResolver, and the requested docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `GardenManager` no longer contains `_apply_produce_resource()` or direct `GardenResources.add()` calls.
- Confirmed `GardenResources.add()` for `produce_resource` now exists in `GardenEffectResolver`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Route `grant_player_shield` through a combat-facing effect path such as `CombatEvents` without changing the first fun test behavior.

### 2026-06-14 - architecture: add combat events bus

#### Summary
- Added `CombatEvents` as a generic autoload signal bus for combat-facing effect requests.
- Defined initial player shield, player damage, enemy damage, and helper spawn request signals.
- Documented that no gameplay is routed through the bus yet.

#### Files Changed
- `project.godot`
- `game/scripts/combat/combat_events.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `project.godot`, the new combat script folder, and the requested docs files changed.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `CombatEvents` is registered as an autoload in `project.godot`.
- Confirmed no existing gameplay scripts reference `CombatEvents` yet.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Route Saintmoth shield requests through `CombatEvents` without changing successful or failed Pulse behavior.

### 2026-06-14 - architecture: route shield through combat events

#### Summary
- Implemented `grant_player_shield` in `GardenEffectResolver`.
- Routed successful player shield requests through `CombatEvents.player_shield_requested`.
- Moved shield application into `PlayerController` and removed direct FirstFunTest Saintmoth-to-player shield wiring.
- Kept `CompanionController` listening to successful Saintmoth triggers for mood feedback only.

#### Files Changed
- `game/scripts/garden/garden_effect_resolver.gd`
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/companion/companion_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `game/scripts/player/player_controller.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the shield routing scripts and requested docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `FirstFunTest` no longer connects Saintmoth directly to `PlayerController.add_shield()`.
- Confirmed `CompanionController` no longer emits `shield_requested`.
- Confirmed `GardenEffectResolver` now owns the `GardenResources.spend()` call for `grant_player_shield` and emits `CombatEvents.player_shield_requested`.
- Confirmed `PlayerController` listens for `CombatEvents.player_shield_requested`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Extract debug event display from `FirstFunTest` into a dedicated temporary `DebugHUD`.

### 2026-06-14 - architecture: extract garden tick system

#### Summary
- Added `GardenTickSystem` as the owner of garden interval cooldown timers.
- Moved interval processing, timer key generation, and stale timer clearing out of `GardenManager`.
- Added a garden cell snapshot API on `GardenManager` and switched the first fun test to call `GardenTickSystem.process_intervals(delta)`.

#### Files Changed
- `project.godot`
- `game/scripts/garden/garden_tick_system.gd`
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `project.godot`, GardenTickSystem, GardenManager, first fun test, and requested docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `FirstFunTest` now calls `GardenTickSystem.process_intervals(delta)`.
- Confirmed `GardenManager` no longer contains `_interval_timers`, `process_intervals()`, `produce_from_intervals()`, `_get_interval_timer_key()`, or `_clear_interval_timers_for_cell()`.
- Confirmed interval timer storage and cell timer clearing now live in `GardenTickSystem`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Extract debug event display from `FirstFunTest` into a dedicated temporary `DebugHUD`.

### 2026-06-14 - architecture: extract garden trigger system

#### Summary
- Added `GardenTriggerSystem` as the owner of event-to-trigger lookup.
- Routed Pulse and global follow-up events through `GardenTriggerSystem`.
- Updated `GardenTickSystem` to request interval trigger matches from `GardenTriggerSystem`.
- Kept `GardenManager` responsible for low-level trigger application and effect bookkeeping.

#### Files Changed
- `project.godot`
- `game/scripts/garden/garden_trigger_system.gd`
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/garden/garden_tick_system.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `project.godot`, GardenTriggerSystem, GardenManager, GardenTickSystem, and requested docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `GardenManager` no longer contains the old `_trigger_piece_with_context()`, `_trigger_event_for_all_pieces()`, or `trigger_piece_with_trigger()` trigger matching helpers.
- Confirmed trigger-array lookup now lives in `GardenTriggerSystem.get_matching_triggers()`.
- Confirmed `GardenTickSystem` uses `GardenTriggerSystem.get_matching_triggers(piece_id, "on_interval")`.
- Confirmed `GardenManager.trigger_piece()` delegates to `GardenTriggerSystem.trigger_cell_event()` and follow-up events delegate to `GardenTriggerSystem.trigger_global_event()`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Extract debug event display from `FirstFunTest` into a dedicated temporary `DebugHUD`.

### 2026-06-14 - architecture: finalize bloomchains on chain finish

#### Summary
- Moved Bloomchain journal recording to `finish_chain()`.
- Kept step signals immediate while delaying `chain_finished` until final chain length is known.
- Preserved chain timeout, soft cap, and repeated-piece protection.
- Updated debug and manual test wording from immediate recording to finalization.

#### Files Changed
- `game/scripts/garden/bloomchain_manager.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/MANUAL_TESTS.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only BloomchainManager, first fun test, and requested docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `JournalManager.record_bloomchain()` is only called from `Bloomchains.finish_chain()`.
- Confirmed causal chains no longer journal immediately at length 3.
- Confirmed soft cap and repeated-piece protection still call `finish_chain()`.
- Confirmed first fun test still listens to `chain_finished` and now labels the event as finalized.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Extract debug event display from `FirstFunTest` into a dedicated temporary `DebugHUD`.

### 2026-06-14 - architecture: extract debug hud

#### Summary
- Added a temporary `DebugHUD` scene and script for the first fun test.
- Moved debug label composition, capped event log, room info display, status text, and last Bloomchain text out of `FirstFunTest`.
- Updated the first fun test scene to instance `DebugHUD`.
- Kept gameplay behavior unchanged; FirstFunTest now forwards high-level events and status to the HUD.

#### Files Changed
- `game/scripts/ui/debug_hud.gd`
- `game/scenes/ui/debug_hud.tscn`
- `game/scenes/debug/first_fun_test.tscn`
- `game/scripts/core/first_fun_test.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only DebugHUD, first fun test, and requested docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `game/scenes/debug/first_fun_test.tscn` now instances `res://game/scenes/ui/debug_hud.tscn`.
- Confirmed `FirstFunTest` no longer owns `debug_label`, `event_log`, `_add_event()`, `debug_message`, or `_last_bloomchain`.
- Confirmed `DebugHUD` owns the capped event log, label text composition, room info, status text, player display, garden rows, and last Bloomchain text.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Move reward choice flow out of `FirstFunTest` into a small reward controller scaffold.

### 2026-06-14 - architecture: extract reward controller

#### Summary
- Added a temporary `RewardController` for reward availability, panel show/hide, selection handling, first-empty-cell placement, and reward result signals.
- Kept hardcoded reward choices in `RewardChoicePanel`.
- Removed detailed reward placement logic from `FirstFunTest`.

#### Files Changed
- `game/scripts/core/reward_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `game/scripts/ui/reward_choice_panel.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only RewardController, FirstFunTest, RewardChoicePanel, and requested docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `FirstFunTest` no longer connects directly to `RewardChoicePanel.reward_selected`.
- Confirmed `FirstFunTest` no longer calls `GardenManager.place_piece_in_first_empty_cell()`.
- Confirmed `RewardController` owns reward availability, panel show/hide, selected reward handling, first-empty-cell placement, and reward result signals.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Move room objective ownership out of `FirstFunTest` into a small room controller node or scene-facing coordinator.

### 2026-06-14 - architecture: extract room flow responsibilities

#### Summary
- Expanded `SimpleRoomController` to own the temporary 30-second survival objective, reward-ready state, and objective text.
- Added room started, room completed, and reward ready signals.
- Updated `FirstFunTest` to react to room reward readiness and reward-claimed results instead of owning room reward state.
- Preserved the current reward-after-survival flow and player-defeat stop behavior.

#### Files Changed
- `game/scripts/core/simple_room_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- Ran `git diff --check`; no whitespace errors reported.
- Parsed MVP JSON data files with PowerShell `ConvertFrom-Json`.
- Confirmed `FirstFunTest` no longer owns survival duration, reward-ready state, or room objective text formatting.
- Confirmed `SimpleRoomController` owns the default 30-second duration, reward-ready state, objective text, and room/reward signals.
- Confirmed player defeat stops room progression through `SimpleRoomController.stop()`.
- Godot CLI was not available in PATH, so the scene was not launched from the command line.

#### Next Recommended Task
- Extract first fun test startup/setup wiring into a small coordinator or keep hardening the room/reward debug loop with manual validation.

### 2026-06-14 - architecture: document current responsibilities

#### Summary
- Reworked the architecture map around the required current runtime flow, current file responsibilities, responsibility problems, target responsibilities, refactor rules, and do-not-do-yet boundaries.
- Documented the current Space-to-Saintmoth-shield path, causal Bloomchain path, and temporary room/reward flow.
- Updated the technical design summary link to point readers to the architecture map for responsibility boundaries.

#### Files Changed
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `docs/ARCHITECTURE_MAP.md`, `docs/TECHNICAL_DESIGN.md`, and `docs/COMMIT_LOG.md` modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `docs/ARCHITECTURE_MAP.md` includes all required sections.
- Confirmed the current Space-to-Saintmoth-shield flow is documented.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Extract garden interval ticking from `GardenManager` into a dedicated `GardenTickSystem` scaffold.

### 2026-06-14 - architecture: document current responsibilities

#### Summary
- Added an architecture map documenting current responsibilities and target system boundaries.
- Captured the standing project rules for focused tasks, documentation updates, and end-of-task workflow.
- Linked the technical design to the new architecture map.

#### Files Changed
- `docs/ARCHITECTURE_MAP.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `docs/ARCHITECTURE_MAP.md`, `docs/TECHNICAL_DESIGN.md`, and `docs/COMMIT_LOG.md` changed.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `docs/ARCHITECTURE_MAP.md` documents current and target responsibilities for the requested systems.
- Confirmed `docs/TECHNICAL_DESIGN.md` links to the architecture map.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Extract garden interval ticking from `GardenManager` into a dedicated `GardenTickSystem` scaffold.

### 2026-06-14 - docs: add manual MVP test checklist

#### Summary
- Added a repeatable manual MVP test checklist for the first fun loop, enemy pressure, garden placement, and Bloomchain behavior.
- Linked the checklist from the README.
- Kept the change documentation-only.

#### Files Changed
- `docs/MANUAL_TESTS.md`
- `README.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `README.md`, `docs/COMMIT_LOG.md`, and new `docs/MANUAL_TESTS.md` changed.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed README links to `docs/MANUAL_TESTS.md`.
- Confirmed the manual checklist covers first fun loop, enemy pressure, garden placement, and Bloomchain checks.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Run the manual MVP checklist in Godot and record any failures as focused follow-up tasks.

### 2026-06-14 - mvp: add minimal room completion loop

#### Summary
- Added a simple 30-second survival room objective to the first fun test.
- Delayed the reward choice panel until the room timer completes.
- Called `RunManager.complete_current_room()` after the player selects and places a reward.

#### Files Changed
- `game/scripts/core/first_fun_test.gd`
- `game/scripts/core/run_manager.gd`
- `game/scripts/core/simple_room_controller.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only first fun test, RunManager, SimpleRoomController, and docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed reward panel is hidden at room start and shown only after the 30-second survival timer completes.
- Confirmed reward placement calls `RunManager.complete_current_room()`.
- Confirmed debug UI shows current room id and completed room count.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add visible Bloomchain path feedback between garden cells.

### 2026-06-14 - mvp: add first causal bloomchain

#### Summary
- Added minimal causal Bloomchain context using runtime `chain_id` data instead of relying only on timing.
- Connected Lantern Lily Light production to Saintmoth Light spending, then to Bellflower's `garden_woke` Echo trigger.
- Added first fun test debug output for completed Bloomchains.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/garden/bloomchain_manager.gd`
- `game/data/garden_pieces/mvp_garden_pieces.json`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/CONTENT_SCHEMA.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the requested GardenManager, BloomchainManager, MVP garden data, first fun test, and docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed Saintmoth failed Pulse still exits before `piece_triggered` and Bloomchain recording.
- Confirmed Bellflower uses `garden_woke` and Saintmoth dispatches that event only after a successful shield trigger.
- Confirmed the first fun test listens for completed chains and shows the latest Bloomchain in debug output.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add visible Bloomchain path feedback between garden cells.

### 2026-06-14 - mvp: add reward choice scaffold

#### Summary
- Added a temporary reward choice panel with three hardcoded MVP choices: Gravecap, Bellflower, and Grave Bell.
- Wired the first fun test to show the panel, accept button or 1/2/3 selection, and auto-place the chosen piece into the first empty non-heart garden cell.
- Added a small GardenManager helper for first-empty-cell placement.

#### Files Changed
- `game/scripts/ui/reward_choice_panel.gd`
- `game/scenes/ui/reward_choice_panel.tscn`
- `game/scripts/core/first_fun_test.gd`
- `game/scripts/garden/garden_manager.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the requested reward panel, first fun test, GardenManager, and docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed reward ids `gravecap`, `bellflower`, and `grave_bell` exist in MVP garden piece data.
- Confirmed the first fun test instances `RewardChoicePanel` and connects its `reward_selected` signal.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add a simple room-clear trigger that reveals the reward panel after a short survival beat.

### 2026-06-14 - mvp: improve first fun test feedback

#### Summary
- Added a capped first fun test event log for Lantern Lily production, Saintmoth Light requirements, Light consumption, shield gain, and Drifter damage feedback.
- Connected the debug UI to existing resource, garden trigger, shield, and health signals.
- Documented the debug UI as temporary readability instrumentation.

#### Files Changed
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `first_fun_test.gd`, `docs/TECHNICAL_DESIGN.md`, and `docs/COMMIT_LOG.md` modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed the debug log is capped at 6 lines.
- Confirmed the event log uses existing resource, garden trigger, shield, and health signals.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add visible non-text shield feedback to the player in the first fun test scene.

### 2026-06-14 - mvp: add drifter enemy pressure

#### Summary
- Added a simple Drifter enemy scene and script for gentle first fun test pressure.
- Instanced one Drifter in the first fun test scene and assigned it to chase the player.
- Updated the debug UI to show health, shield, Drifter pressure status, and defeat state.

#### Files Changed
- `game/scenes/enemies/drifter.tscn`
- `game/scripts/enemies/drifter_enemy.gd`
- `game/scenes/debug/first_fun_test.tscn`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the requested Drifter scene/script, first fun test scene/script, and docs files modified or added.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed the Drifter instance targets `../Player` in the first fun test scene.
- Confirmed Drifter contact damage calls `PlayerController.take_damage()`, preserving shield-before-health behavior.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add visible shield feedback to the first fun test scene.

### 2026-06-14 - mvp: clarify saintmoth shield effect path

#### Summary
- Made GardenManager trigger application report success or failure explicitly.
- Ensured failed Saintmoth shield pulses do not emit `piece_triggered`, update `last_trigger`, or record Bloomchain steps.
- Documented the current shield signal path and the future need for a centralized combat effect resolver.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/companion/companion_controller.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the requested GardenManager, CompanionController, first fun test, and docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `GardenManager._apply_trigger()` now returns success and only emits `piece_triggered` on success.
- Confirmed `CompanionController` receives shield requests only through the successful Saintmoth trigger signal path.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Add visible shield feedback to the first fun test scene.

### 2026-06-14 - mvp: implement garden interval ticking

#### Summary
- Moved interval production timing out of the first fun test debug scene and into `GardenManager`.
- Added per-cell/per-trigger cooldown tracking for JSON `on_interval` triggers.
- Kept Lantern Lily producing 1 Light every 5 seconds through its existing JSON trigger.

#### Files Changed
- `game/scripts/garden/garden_manager.gd`
- `game/scripts/core/first_fun_test.gd`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only the requested GardenManager, first fun test, and docs files modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Confirmed `_produce_timer` was removed from `first_fun_test.gd`.
- Confirmed interval ticking is now called through `GardenManager.process_intervals(delta)`.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.

#### Next Recommended Task
- Make Saintmoth shield feedback clearer in the first fun test scene.

### 2026-06-14 - chore: expand git hygiene

#### Summary
- Expanded repository ignores for Godot cache/import folders, exports, logs, temporary files, backups, and OS junk.
- Added missing Git LFS patterns for likely binary asset types.
- Documented Git LFS expectations for future art and audio assets.

#### Files Changed
- `.gitignore`
- `.gitattributes`
- `docs/TECHNICAL_DESIGN.md`
- `docs/COMMIT_LOG.md`

#### Verification
- `git status` showed only `.gitignore`, `.gitattributes`, `docs/TECHNICAL_DESIGN.md`, and `docs/COMMIT_LOG.md` modified.
- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- Conflict-marker scan found no merge markers in the changed files; the only `TODO`/`FIXME` text is a historical verification sentence in this commit log.
- Godot CLI was not available in PATH, so editor-level validation was not run.

#### Next Recommended Task
- Make the Lantern Lily -> Light -> Saintmoth -> Shield loop fully playable and verify it in Godot.
