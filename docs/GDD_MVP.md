# Garden of Teeth MVP

## Plainspeak

Garden of Teeth is a relaxing creature-garden roguelite. The player is not collecting weapons. They are tending a small living ecosystem that protects them through readable cascades called Bloomchains.

The first fun test is intentionally tiny:

1. The player moves.
2. Saintmoth follows.
3. Lantern Lily makes Light.
4. Saintmoth eats Light.
5. The player gets a shield by pressing Pulse.

If that relationship is not charming and understandable, no larger system should be built yet.

## Technical North Star

The MVP should be built bottom-up around data-defined garden pieces and small runtime managers:

- `ContentDatabase` loads JSON content.
- `GardenManager` owns the 3x3 grid and trigger dispatch.
- `GardenResources` owns Light, Rot, Blood, and Echo counts.
- `Bloomchains` records trigger sequences and prevents unbounded loops.
- `RunManager` owns run flow.
- `JournalManager` records discoveries.

Every future feature should preserve the central grammar:

- Flora produces.
- Fauna consumes.
- Objects modify.
- The player tends.

## MVP Scope

Included:

- Godot 4 project.
- Data-driven 12-piece MVP content set.
- Four resources: Light, Rot, Blood, Echo.
- 3x3 garden with Saintmoth Heart Tile.
- First fun test scene.
- Placeholder-friendly folders for scenes, scripts, art, audio, and data.
- Documentation database for code, content, systems, and editing workflow.

Not included yet:

- Full combat loop.
- Reward UI.
- Real Bloomchain visualization.
- Final art/audio.
- Procedural generation.
- Multiple companions.
- Complex meta-progression.

## Current First-Pass Status

This repository now has groundwork, not a finished MVP. The next playable target is to make the first fun test feel good before expanding content behavior.
