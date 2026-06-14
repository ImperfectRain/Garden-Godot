# Codebase Index

## Plainspeak

The repo is organized so game code, content data, scenes, art, audio, and docs live in predictable places. The content files are meant to be edited often. Core manager scripts should change more carefully.

## Technical

### Root

- `project.godot`: Godot project settings, autoloads, input actions, main debug scene.
- `.gitattributes`: line endings and Git LFS patterns for binary assets.
- `.gitignore`: Godot local cache ignores.

### `docs/`

- `docs/GDD_MVP.md`: current MVP design summary.
- `docs/database/`: technical and plain-language project database.

### `game/data/`

Data should define content identity and tunable behavior. Scripts should read from this folder rather than hardcoding new content.

- `garden_pieces/mvp_garden_pieces.json`: 12 MVP pieces.
- `resources/mvp_resources.json`: Light, Rot, Blood, Echo definitions.
- `enemies/mvp_enemies.json`: Drifter, Burrower, Grazer, Hungry Stag definitions.
- `rooms/mvp_rooms.json`: Meadow, Nursery, Burrow, Reliquary, Boss Grove definitions.
- `rewards/mvp_reward_pools.json`: reward pools by room/category.

### `game/scripts/`

- `data/content_database.gd`: loads and indexes JSON data.
- `garden/resource_manager.gd`: global resource wallet.
- `garden/garden_manager.gd`: 3x3 grid, placement, trigger application.
- `garden/bloomchain_manager.gd`: trigger-chain recording and loop cap.
- `player/player_controller.gd`: movement, health, shield, Pulse input.
- `companion/companion_controller.gd`: Saintmoth follow and shield request bridge.
- `enemies/enemy_controller.gd`: data-backed enemy movement/damage placeholder.
- `core/run_manager.gd`: run lifecycle and current room order.
- `core/first_fun_test.gd`: debug scene bootstrap.
- `meta/journal_manager.gd`: discoveries, chains, run history, Saintmoth bond.
- `ui/garden_grid_view.gd`: simple grid UI control scaffold.

### `game/scenes/`

- `debug/first_fun_test.tscn`: current main scene. It demonstrates movement, Saintmoth, Lantern Lily, Light, shield, and Pulse.
- Other scene folders are placeholders for future feature scenes.

### `game/art/` and `game/audio/`

Placeholder asset folders. Binary art/audio source files should be stored with Git LFS.

## Ownership Rules

- Content numbers and descriptions belong in `game/data`.
- Runtime state belongs in managers or scene instances, not JSON.
- New systems need docs in `docs/database/systems`.
- Debug/test scenes belong under `game/scenes/debug` until they become production scenes.
