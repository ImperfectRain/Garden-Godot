# Commit Log

## 2026-06-14 - mvp: add codex task workflow

### Plainspeak

Added the standing Codex task rules to the project docs so future work stays small, documented, committed, and pushed one task at a time.

### Technical

- Updated `docs/database/AI_AGENT_GUIDE.md` with global task rules, commit message style, required sanity checks, and the `docs/COMMIT_LOG.md` requirement.
- Created this commit log as the required per-task record.
- No gameplay behavior changed.

### Verification

- `git diff --check` passed.
- MVP JSON files parsed with PowerShell `ConvertFrom-Json`.
- No conflict markers, `TODO`, or `FIXME` markers found in project docs/game files.
- Godot CLI was not available in PATH, so editor-level scene/script validation was not run.
