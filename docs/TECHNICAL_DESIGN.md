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

- `game/data/garden_pieces/*.json`
- `game/data/resources/*.json`
- `game/data/enemies/*.json`
- `game/data/rooms/*.json`
- `game/data/rewards/*.json`

Each content entry is stored as its own JSON object file named after its stable id. `ContentDatabase` scans these directories recursively, indexes entries by `id`, and reports duplicate ids. Future content should be added by creating a new JSON file in the appropriate folder rather than editing a master MVP collection file.

## Architecture Guardrails

- `GardenManager` owns grid state and current trigger bookkeeping; new gameplay action mechanics should go in `GardenEffectResolver`.
- `GardenTickSystem` owns cooldown timing only; it should not spend resources, grant shields, damage enemies, or apply other gameplay effects directly.
- `GardenEffectResolver` applies data-defined effects and may emit generic system events, but it should not know about `FirstFunTest`, `DebugHUD`, reward panels, or other UI scenes.
- `FirstFunTest` is debug-only scene glue. It may wire prototype systems together, but reusable gameplay rules should move into focused systems.
- Reward choices should come from room data and reward pools, not scene or panel hardcoding.

## Content Validation

`ContentDatabase.load_all()` validates loaded garden piece content and duplicate ids discovered while scanning content directories. Validation errors are stored in `ContentDatabase.validation_errors` and also emitted through `content_load_failed(path, reason)` so debug scenes or editor tooling can show problems clearly.

Garden piece validation currently checks required fields, allowed categories, and required trigger fields. This validation is intentionally non-blocking for parseable JSON so prototype content can still load while problems are reported. Invalid JSON roots still fail that file load and return an empty collection.

## MVP Enemy Behavior

The first fun test includes one `Drifter` enemy from `res://game/scenes/enemies/drifter.tscn`. It is a slow `CharacterBody2D` that moves toward the player and applies contact damage through `PlayerController.take_damage()`.

Drifter damage is intentionally low-stress: it uses a short cooldown so contact does not instantly defeat the player. Because damage goes through `take_damage()`, shield absorbs damage before health, making Saintmoth's shield useful without requiring a full combat system yet.

`FirstFunTest` currently spawns one fresh Drifter whenever a room starts. This is debug-scene enemy setup only; the final expedition flow should replace it with room encounter data and a focused enemy/wave controller.

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

## Garden Grid Panel

`GardenGridPanel` lives at `res://game/scenes/ui/garden_grid_panel.tscn` with script `game/scripts/ui/garden_grid_panel.gd`. It is a temporary prototype UI that shows the current 3x3 garden as cells with text labels, simple category colors, and a distinct Heart Tile.

The panel listens to `GardenManager.grid_reset`, `piece_placed`, `piece_removed`, and `piece_triggered`. Placement signals refresh the grid, and trigger signals briefly flash the triggered cell with an event marker. The text debug rows still exist for now; this panel is only the first readable visual garden UI, not the final garden screen.

## Garden Inspect Panel

`GardenInspectPanel` lives at `res://game/scenes/ui/garden_inspect_panel.tscn` with script `game/scripts/ui/garden_inspect_panel.gd`. It is a temporary safe-moment inspector for the first fun test. After a room reward is claimed, pressing `I` opens the panel, Arrow keys move the selected garden cell, and Escape closes it.

The panel reads the selected cell's piece data from `ContentDatabase` and displays the simple description, detail description, tags, likes, synergies, trigger summaries, and current stored resource counts. It should remain presentation-only; placement rules, effects, and trigger logic stay in the garden systems.

## Garden Interval Ticking

Garden interval production is owned by `GardenTickSystem.process_intervals(delta)`. The system inspects placed garden pieces through `GardenManager.get_all_cells()`, asks `GardenTriggerSystem` for JSON triggers with `event == "on_interval"`, advances a per-cell/per-trigger cooldown timer, and asks `GardenManager` to apply the trigger when its `cooldown` is reached.

The current Lantern Lily trigger comes from `game/data/garden_pieces/lantern_lily.json` and produces 1 Light every 4 seconds. Debug scenes should call `GardenTickSystem.process_intervals(delta)` instead of owning production timers.

`GardenTickSystem` owns the interval timer dictionary, timer key generation, and stale timer clearing. It resets timers on `GardenManager.grid_reset` and clears a cell's timers when `GardenManager.piece_placed` or `GardenManager.piece_removed` fires.

## Garden Trigger Lookup

`GardenTriggerSystem` owns event-to-trigger lookup. `trigger_cell_event(cell, event_name, context)` finds matching triggers for the piece in one cell. `trigger_global_event(event_name, context)` checks every placed piece and dispatches matching triggers. `get_matching_triggers(piece_id, event_name)` is the shared lookup helper used by both direct cell events and interval ticking.

`GardenManager` still owns low-level trigger application through `apply_trigger_request(cell, piece_id, trigger, context)`, including effect request construction, success bookkeeping, Bloomchain recording, resource provenance, and follow-up event handoff. This keeps the extraction focused; a later task can move trigger request construction and follow-up ownership further out of `GardenManager`.

## Garden Effect Resolution

`GardenEffectResolver` is the generic action resolver for data-defined garden effects. For `produce_resource`, `GardenManager` builds an effect request from the successful trigger context, `GardenEffectResolver` validates the resource id and amount, calls `GardenResources.add(resource_id, amount)`, and returns an effect result.

For `grant_player_shield`, `GardenEffectResolver` validates the resource id, cost, and shield amount, spends the resource through `GardenResources.spend()`, and emits `CombatEvents.player_shield_requested`. `GardenManager` still owns resource provenance, trigger success bookkeeping, `piece_triggered`, Bloomchain recording, and follow-up dispatch for now.

The resolver also recognizes the current generic MVP action vocabulary:

- `consume_resource`
- `store_resource`
- `damage_enemy`
- `damage_nearby_enemies`
- `spawn_helper`
- `repeat_last_trigger`
- `move_resource`
- `copy_output`
- `modify_production`
- `protect_adjacent_living`
- `connect_adjacent_flora`

Some of these are minimal primitives that emit structured outputs but are not yet fully wired into piece-specific behavior. They are intentionally generic so later Flora, Fauna, and Object passes can reuse the same actions instead of hardcoding individual pieces.

## Combat Event Bus

`CombatEvents` is a generic signal bus for combat-facing effects that need to target players, enemies, or helper spawns without binding gameplay systems to a specific scene. It currently exposes requests for player shield, player damage, enemy damage, and helper spawning.

Player shield requests now route through `CombatEvents.player_shield_requested`. `PlayerController` listens for that signal and applies shield with `add_shield(amount)`. Enemy damage requests route through `EnemyRegistry`, which damages the nearest registered enemy that supports `take_damage(amount, source)`. Helper spawning is still scaffold-only.

`PlayerController` also emits `CombatEvents.player_damaged` after actual health damage is applied. The first fun test temporarily translates that event into the garden event `player_damaged_or_close_kill`, allowing Blood Rose to produce Blood when the player takes unshielded damage.

`Drifter` registers itself with `EnemyRegistry`, has simple health, emits `enemy_damaged`, and emits `enemy_defeated` before being removed. The first fun test translates enemy defeat into `enemy_died`, `enemy_died_nearby`, and `player_damaged_or_close_kill` garden events so Gravecap and Blood Rose can react.

## Flora Runtime Behavior

Current Flora behavior:

- Lantern Lily produces Light through its interval trigger.
- Bellflower produces Echo when the garden receives `garden_woke`.
- Blood Rose produces Blood when the player takes actual health damage in the first fun test.
- Gravecap produces Rot when an enemy defeat emits the `enemy_died` garden event.

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

## External Placeholder Assets

Repo-safe placeholder assets live under `game/art/external/`. Current imported packs are:

- `game/art/external/kenney/tiny_town/`
- `game/art/external/kenney/roguelike_rpg/`

Both imported Kenney packs are Creative Commons Zero, CC0, and include their original license files. These are development placeholders only. Future non-CC0 asset packs should not be committed unless their license explicitly allows redistribution in this repository.

## Placeholder Sprite Application

The first fun test now uses imported Kenney placeholder sprites for visible field actors instead of pure polygon shapes:

- `PlayerSprite` uses a temporary `Sprite2D` atlas region from the Kenney Roguelike/RPG sheet.
- `SaintmothSprite` uses a temporary `Sprite2D` atlas region from the Kenney Roguelike/RPG sheet.
- `Drifter/Body` uses a temporary `Sprite2D` atlas region from the Kenney Roguelike/RPG sheet.
- `GardenGridPanel` shows small temporary Tiny Town tile icons for current garden piece ids.

This is a prototype readability pass only. Long-term visual assignment should come from content data such as `visual_asset`, with a small resolver or lookup layer instead of hardcoded UI icon paths.

## Manual Garden Placement

Reward selection now starts a manual placement step instead of placing the chosen piece in the first empty cell. `RewardChoicePanel` still presents the reward choices, but `RewardController` owns the pending piece id, placement cursor, confirm/cancel input, and final placement request.

Temporary controls during placement:

- Arrow keys move the garden placement cursor.
- Enter or E confirms placement.
- Escape cancels placement and returns to the reward choices.

`GardenManager.get_placement_error()` and `GardenManager.can_place_piece()` provide non-mutating placement validation for UI previews. The Heart Tile and occupied cells are rejected before placement. `GardenGridPanel` displays a temporary placement highlight and validity color for the pending piece.

## Garden Cell Selection

`GardenManager` owns the current `selected_cell` and exposes `set_selected_cell()`, `select_heart_cell()`, and `move_selected_cell()` helpers. Selection changes emit `selected_cell_changed`, which the temporary Garden UI uses to refresh its selected-cell highlight.

Current Pulse behavior still selects the Heart Tile before pulsing so the first fun test remains focused on Saintmoth. Future inspect, tend, and selected-piece Pulse behavior should use these selection helpers instead of directly assigning `selected_cell`.

## Expedition Map Progression

The first fun test now includes a scaffold for the intended expedition map flow. `ExpeditionMapController` owns a small generated top-down grid of room nodes. The current demo generator creates a deterministic path using existing MVP room ids, but the controller API is meant to be replaced by procedural generation later.

Current behavior:

- The run starts in the first revealed room.
- Clearing a room reveals adjacent cardinal rooms that exist in the generated layout.
- After claiming the room reward, the player can use Arrow keys to select revealed adjacent rooms.
- Enter or E travels to the selected room.
- Backtracking to revealed adjacent rooms is allowed.
- `ExpeditionMapPanel` displays revealed rooms, current room, selected room, and cleared rooms.

This is groundwork for the final expedition system where map layouts are generated per expedition and room selection happens from a zoomed-out grid view.

## Room Objectives

`SimpleRoomController` now supports two temporary completion paths:

- survive until the room timer expires
- defeat the configured number of enemies

The first fun test currently tracks Drifter defeats through `CombatEvents.enemy_defeated` and completes the room when the enemy goal is met. This keeps the room loop low-stress while making garden enemy damage and Grave Bell payoff relevant.

## Garden Adjacency Queries

`GardenManager` exposes read-only helpers for placement-sensitive effects:

- `get_orthogonal_neighbors(cell)`
- `get_diagonal_neighbors(cell)`
- `get_opposite_cell(origin_cell, pivot_cell)`
- `are_cells_adjacent(a, b, include_diagonal)`
- `get_adjacent_piece_cells(cell, include_diagonal)`
- `get_adjacent_piece_ids(cell, include_diagonal)`
- `get_adjacent_cells_by_category(cell, category, include_diagonal)`
- `get_adjacent_cells_by_tag(cell, tag, include_diagonal)`
- `get_cells_by_category(category)`
- `get_cells_by_tag(tag)`

These helpers do not apply effects. They exist so later Flora/Fauna/Object behavior can ask placement questions consistently before `GardenEffectResolver` applies an action.

## Resource Provenance and Routing

Resources are still stored globally by `GardenResources`, but `GardenManager` now tracks lightweight source batches per resource id. When a trigger produces a resource, the source batch records:

- resource id and amount
- origin cell
- origin piece id
- chain context
- adjacent occupied cells
- adjacent Flora, Fauna, and Object cells

When a consuming trigger succeeds, GardenManager consumes from the matching resource source queue and uses the earliest available source context for Bloomchain causality. This is not full per-tile resource storage yet, but it gives future consumers and modifiers enough context for placement-sensitive behavior.

Consumers now prefer adjacent resource sources when possible. This means Saintmoth will preferentially consume Light whose source was adjacent to the Heart Tile, preserving the starter fantasy that Lantern Lily feeds Saintmoth when placed nearby.

Successful resource production dispatches:

- `resource_available` globally.
- `resource_available_adjacent` to occupied neighbor cells around the producing cell.

These events are used by Rotling, Mawlet, and Glass Beetle.

## Fauna Runtime Behavior

Current Fauna behavior:

- Saintmoth consumes Light and grants Shield. Light source provenance now prefers adjacent producers when available.
- Rotling listens for `resource_available`, consumes 2 Rot, and emits a debug helper spawn request.
- Mawlet listens for `resource_available`, consumes 2 Blood, and repeats the previous successful garden trigger at reduced strength. Repeat depth is capped so Mawlet cannot repeat itself indefinitely.
- Glass Beetle listens for `resource_available_adjacent` and only succeeds when the resource source is adjacent and another adjacent piece can use that resource.

## Object Runtime Behavior

Current Object behavior:

- Grave Bell listens for Echo availability, stores Echo up to 3, then dispatches `stored_resource_threshold` and emits enemy damage through `CombatEvents.enemy_damage_requested`.
- Mirror Shard listens for `opposite_tile_triggered`. The MVP interpretation reflects across the 3x3 grid: if the tile opposite the Mirror Shard triggers, the Mirror Shard copies resource or enemy-damage output at reduced strength.
- Bone Trellis triggers a placement passive marker and lets resource availability from adjacent Flora also notify other Flora adjacent to the same Trellis.
- Tiny Fence triggers a placement passive marker and applies its `production_bonus` to adjacent Flora production. It is the current MVP stand-in for protecting adjacent living pieces.

## Garden Feedback

`GardenGridPanel` is still temporary prototype UI, but it now provides several readability cues:

- pending placement cell highlight
- adjacent-cell highlight during placement
- stronger highlight for adjacent pieces liked by the pending piece
- selected-cell highlight
- action-specific trigger flash colors
- short trigger markers such as `+` for production, `>` for movement/copying, `!` for damage, and `x` for repeats

`FirstFunTest` also updates the debug status during placement with simple "Works with" hints based on adjacent piece ids, categories, and tags.

## Known Temporary Limitations

- Resources are globally counted, with lightweight source-batch provenance. They are not fully stored per tile or per piece yet.
- Only a partial set of trigger effects is implemented in code; `produce_resource` and `grant_player_shield` are routed through `GardenEffectResolver`.
- Interval ticking has moved to `GardenTickSystem`, and event-to-trigger lookup has moved to `GardenTriggerSystem`; completed trigger application still routes through `GardenManager`.
- Room objective timing has moved to `SimpleRoomController`, but `FirstFunTest` still wires room-ready and reward-claimed outcomes.
- Bloomchain causality is minimal and still lacks per-resource-unit provenance or visual path playback.
- Shield application now routes through `CombatEvents`, but other combat-facing effects are still not implemented.
- Placeholder actor and garden piece sprites are hardcoded in scenes/UI for now and should move to data-driven `visual_asset` resolution later.
- Manual garden placement is keyboard-only and temporary; no mouse, drag-and-drop, or controller-specific placement polish exists yet.
- General garden selection exists, but only Heart Tile Pulse and reward placement currently use garden cell state.
