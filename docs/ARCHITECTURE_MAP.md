# Architecture Map

This document defines current responsibilities and the near-term architecture target for Garden of Teeth. Use it when deciding where a new behavior belongs.

## Working Rules

- Keep each change small and focused.
- Do not add new gameplay content unless explicitly requested.
- Do not hardcode behavior to one gameplay feature unless the task explicitly marks it as temporary debug wiring.
- Give every file one clear responsibility.
- Prefer generic systems that can support future Flora, Fauna, Objects, companions, enemies, rooms, and effects.
- Preserve current playable behavior unless a task explicitly asks to change it.
- Update relevant docs with every task:
  - `docs/TECHNICAL_DESIGN.md`
  - `docs/ARCHITECTURE_MAP.md` if architecture changes
  - `docs/CONTENT_SCHEMA.md` if data or schema changes
  - `docs/MANUAL_TESTS.md` if test steps change
  - `docs/COMMIT_LOG.md` always

## Current Responsibilities

### ContentDatabase

- Current file: `game/scripts/data/content_database.gd`
- Loads JSON content from `game/data`.
- Provides lookup helpers for garden pieces, resources, enemies, rooms, and reward pools.
- Should remain focused on loading, indexing, and validating content.

### GardenManager

- Current file: `game/scripts/garden/garden_manager.gd`
- Owns the 3x3 grid, Heart Tile placement, cell lookup, and garden-level trigger dispatch.
- Currently also handles interval ticking, trigger matching, direct effect application, and some causal Bloomchain context.
- Target direction: keep grid and garden events here, then move ticking, trigger matching, and effect application into dedicated systems.

### GardenTickSystem

- Target system, not implemented yet.
- Should own interval and cooldown ticking for garden pieces.
- Should read trigger timing from data and produce trigger requests rather than applying effects directly.

### GardenTriggerSystem

- Target system, not implemented yet.
- Should find matching triggers for events and build trigger requests.
- Should not apply gameplay effects directly.

### GardenEffectResolver

- Target system, not implemented yet.
- Should apply data-defined effect actions generically.
- Should emit effect results that other systems can observe.
- Should not know about debug UI scenes.

### CombatEvents

- Target system, not implemented yet.
- Should route combat-facing effects such as shield, damage, healing, spawning, knockback, or enemy-facing results.
- Should replace scene-specific shield wiring when combat effects expand.

### Bloomchains

- Current file: `game/scripts/garden/bloomchain_manager.gd`
- Records causal and temporary fallback trigger chains.
- Tracks largest chain this run and emits chain signals.
- Currently records journal Bloomchains directly.
- Target direction: record chain results and emit events; journal persistence should eventually move behind a clearer meta/progression boundary.

### RunManager

- Current file: `game/scripts/core/run_manager.gd`
- Owns run lifecycle, planned room order, current room index, run reset, and run summary.
- Should not own room objectives, reward timing, enemy waves, or debug presentation.

### RoomController

- Current file: `game/scripts/core/simple_room_controller.gd`
- Current implementation is a tiny first-fun-test survival timer.
- Target direction: own room objectives and reward timing per room.

### RewardController / RewardChoicePanel

- Current file: `game/scripts/ui/reward_choice_panel.gd`
- Current implementation presents three hardcoded MVP choices and emits a selected piece id.
- Target direction: presentation and selection should stay separate from reward pool generation and garden placement rules.

### DebugHUD

- Target system, not implemented yet.
- Current debug display lives inside `game/scripts/core/first_fun_test.gd`.
- Should eventually own temporary debug text, event log, room status, resource display, and Bloomchain debug output.

### FirstFunTest

- Current file: `game/scripts/core/first_fun_test.gd`
- Temporary debug scene glue only.
- Wires prototype systems together so the smallest playable loop can be tested.
- Should not become the permanent home for gameplay rules.

## Design Principle

Garden pieces define data. Systems interpret data. Effects are resolved generically. Scenes wire prototype presentation, not gameplay rules.
