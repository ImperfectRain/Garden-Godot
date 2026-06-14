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
