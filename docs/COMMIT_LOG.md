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
