# AI Agent Guide

## Plainspeak

AI should work like a careful junior collaborator with good tools: small tasks, clear files, no surprise rewrites, and docs updated with code.

Good task:

> Add a new GardenPiece trigger action for storing Echo on Grave Bell. Edit only GardenManager, the Grave Bell JSON entry if needed, and the Bloomchain docs.

Bad task:

> Make the game fun.

## Technical Rules

### Before Editing

1. Read `docs/database/README.md`.
2. Read `docs/database/CODEBASE_INDEX.md`.
3. Read the relevant system doc.
4. Inspect current git status.

### During Editing

- Prefer `game/data` for content changes.
- Prefer existing manager APIs before adding new global state.
- Add signals for cross-system events.
- Keep behavior testable in `game/scenes/debug`.
- Do not rename stable ids casually.
- Do not expand MVP scope without explicit instruction.

### After Editing

- Update the relevant docs.
- Run JSON validation or Godot parse checks when available.
- Summarize changed files by responsibility.
- Call out any unverified behavior.

## Agent-Safe Task Templates

### Add Garden Piece

Scope:

- Edit `game/data/garden_pieces/mvp_garden_pieces.json`.
- If using an existing action, no code changes should be needed.
- Update `CONTENT_SCHEMA.md` only if schema interpretation changes.

Acceptance:

- JSON parses.
- `ContentDatabase.get_garden_piece("<id>")` returns data.
- The piece has solo value, obvious synergy, and deeper synergy notes.

### Add Trigger Action

Scope:

- Edit `GardenManager._apply_trigger` or a new specialized system.
- Add or update data that uses the action.
- Update `CONTENT_SCHEMA.md` and relevant system docs.

Acceptance:

- Unknown actions remain harmless.
- Chain recording still occurs only for successful triggers.
- Loop prevention still applies.

### Add Debug Scene

Scope:

- Add scene under `game/scenes/debug`.
- Add script under the most relevant script folder.
- Do not replace production scene unless instructed.

Acceptance:

- Scene demonstrates one concept clearly.
- On-screen debug text is useful for programmers.
