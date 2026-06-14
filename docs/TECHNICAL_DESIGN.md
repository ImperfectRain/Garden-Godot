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

## Current Data Files

- `game/data/garden_pieces/mvp_garden_pieces.json`
- `game/data/resources/mvp_resources.json`
- `game/data/enemies/mvp_enemies.json`
- `game/data/rooms/mvp_rooms.json`
- `game/data/rewards/mvp_reward_pools.json`

## Garden Interval Ticking

Garden interval production is owned by `GardenManager.process_intervals(delta)`. The method inspects placed garden pieces, reads each JSON trigger with `event == "on_interval"`, advances a per-cell/per-trigger cooldown timer, and applies the trigger when its `cooldown` is reached.

The current Lantern Lily trigger comes from `game/data/garden_pieces/mvp_garden_pieces.json` and produces 1 Light every 5 seconds. Debug scenes should call `GardenManager.process_intervals(delta)` instead of owning production timers.

## Git LFS Expectations

Likely binary art and audio assets should be tracked with Git LFS through `.gitattributes`. This includes common image, audio, pixel art, layered source, Krita, and Blender files such as `png`, `jpg`, `jpeg`, `webp`, `wav`, `ogg`, `mp3`, `aseprite`, `psd`, `kra`, and `blend`.

Keep placeholder scripts, scenes, JSON data, and documentation in normal Git. If automated exports are added later, review whether `export_presets.cfg` should remain ignored or become committed project configuration.

## Known Temporary Limitations

- Resources are global to the garden instead of stored per tile or per piece.
- Only a partial set of trigger effects is implemented in code.
- Bloomchain detection is temporal and records nearby trigger timing, not explicit graph causality yet.
- Shield application is wired through the current debug scene and companion signal connection.
