# Technical Design

## Current Architecture

The project uses Godot autoloads for small global systems that coordinate data, garden state, resources, run flow, and meta records.

## Autoloads

- `ContentDatabase`: loads JSON content from `game/data`.
- `GardenResources`: tracks current Light, Rot, Blood, and Echo resource amounts.
- `GardenManager`: owns the 3x3 grid, Heart Tile placement, and garden trigger dispatch.
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

## Reward Choice Scaffold

The first fun test includes a temporary reward panel at `res://game/scenes/ui/reward_choice_panel.tscn`. It shows three hardcoded MVP rewards, displays each piece's name, category, and simple description from `ContentDatabase`, and accepts either button clicks or keyboard keys 1/2/3.

Selection currently calls `GardenManager.place_piece_in_first_empty_cell(piece_id)` and auto-places the reward into the first empty non-heart garden cell. This is a scaffold for validating reward readability and garden placement; it is not the final room reward flow, drag-and-drop garden UI, or polished reward screen.

## Garden Interval Ticking

Garden interval production is owned by `GardenManager.process_intervals(delta)`. The method inspects placed garden pieces, reads each JSON trigger with `event == "on_interval"`, advances a per-cell/per-trigger cooldown timer, and applies the trigger when its `cooldown` is reached.

The current Lantern Lily trigger comes from `game/data/garden_pieces/mvp_garden_pieces.json` and produces 1 Light every 5 seconds. Debug scenes should call `GardenManager.process_intervals(delta)` instead of owning production timers.

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
- Only a partial set of trigger effects is implemented in code.
- Bloomchain detection is temporal and records nearby trigger timing, not explicit graph causality yet.
- Shield application is wired through the current debug scene and companion signal connection.
