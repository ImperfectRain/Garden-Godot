# Garden of Teeth MVP

## One-Sentence Pitch

A relaxing creature-garden roguelite where the player explores with a bonded companion, collects Flora, Fauna, and Objects, and arranges them into a living inventory that protects them through Bloomchain cascades.

## Design Pillars

- Relaxing first, deep second.
- The garden is alive, not a passive inventory.
- Flora produces, Fauna consumes, Objects modify, and the player tends.
- Every piece should be useful alone and better together.
- The player stays mostly consistent while the garden changes between runs.
- Saintmoth should create emotional continuity and clear protection.
- Big cascades should feel readable, beautiful, and earned.
- Failure should still grow journal, bond, or discovery progress.

## Core Loop

Start at home, enter an expedition, clear a short relaxed combat room, collect a garden piece, place it during a safe garden moment, watch the garden help, trigger Bloomchains, fight a mini-boss, and return home with discoveries.

The current smallest loop is:

Lantern Lily -> Light -> Saintmoth -> Shield

No new content should be added until this loop is playable and understandable.

## Flora/Fauna/Object Grammar

- Flora produces resources or growth.
- Fauna consumes resources and acts when fed.
- Objects modify, store, copy, connect, protect, or repeat.
- The player tends the system through placement, safe tending, and Pulse.

## Bloomchain Definition

A Bloomchain occurs when three or more garden pieces trigger each other in sequence. MVP Bloomchains should glow, show a visible path, play a small cue at length 3+, and stop before loops become confusing or infinite.

## MVP Scope

- Godot 4 project.
- 2D top-down player movement.
- One debug first fun test scene.
- One starter companion: Saintmoth.
- One 3x3 garden grid with a Heart Tile.
- Four resources: Light, Rot, Blood, Echo.
- Twelve planned MVP garden pieces.
- Data-driven content files.
- Basic journal, run, resource, garden, companion, and Bloomchain scaffolding.

## Explicit Non-Goals

- No additional companions yet.
- No complex breeding.
- No procedural map generation.
- No large item pool.
- No 5x5 garden.
- No real-time rearranging during combat.
- No full economy, achievements, localization, final art, or final music.
- No new content before the Lantern Lily -> Light -> Saintmoth -> Shield loop works.
