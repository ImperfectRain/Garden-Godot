# Editing Guide

## Plainspeak

Make small changes, keep the garden understandable, and update the docs when behavior changes. The MVP should grow from one clear relationship at a time.

Do not add systems just because they are cool. Add systems only when they make the garden feel more alive, readable, relaxing, or satisfying to tend.

## Technical Workflow

1. Identify the owner.
   - Content changes usually belong in `game/data`.
   - Grid/resource/chain rules belong in `game/scripts/garden`.
   - Run flow belongs in `game/scripts/core`.
   - Discovery/meta belongs in `game/scripts/meta`.
2. Make the smallest useful change.
3. Update the relevant doc in `docs/database`.
4. Run the smallest available verification.
5. Commit only coherent working slices.

## Safe Content Edits

Safe without architecture review:

- Add a new garden piece using existing actions.
- Tune resource amounts or intervals.
- Add reward pool entries.
- Add enemy stat variants using existing enemy behavior.
- Improve descriptions and synergy notes.

Needs architecture review:

- Add a new resource type.
- Add new trigger events.
- Add a new action interpreter.
- Change grid size.
- Change Heart Tile behavior.
- Allow infinite or repeatable chain loops.

## Safe Code Edits

Prefer adding narrow methods over rewriting managers.

Do:

- Keep manager responsibilities focused.
- Add signals for cross-system communication.
- Let data drive ids, names, descriptions, and tunable numbers.
- Keep debug scenes separate from production scenes.

Avoid:

- Hardcoding new garden piece ids in combat code.
- Making UI own gameplay state.
- Letting enemies directly mutate garden resources.
- Adding hidden passive stat sticks that do not express Flora/Fauna/Object grammar.

## Required Doc Updates

Update docs when:

- A file or folder responsibility changes.
- A JSON field is added, renamed, or removed.
- A new manager or system appears.
- A trigger action is added.
- The first fun test changes meaningfully.
