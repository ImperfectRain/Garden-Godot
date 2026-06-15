# System: Run And Rooms

## Plainspeak

A run is a short path through rooms, with safe breaks between danger. The MVP should not start as endless survival.

The first full run target is simple: a few rooms, a mini-boss, a summary, journal updates, and one reason to try again.

## Technical

Owner file: `game/scripts/core/run_manager.gd`

Related data:

- `game/data/rooms/*.json`
- `game/data/rewards/*.json`
- `game/data/enemies/*.json`

Current planned room order:

1. `meadow`
2. `nursery`
3. `burrow`
4. `reliquary`
5. `boss_grove`

Primary APIs:

- `start_run()`
- `get_current_room_id() -> String`
- `complete_current_room()`
- `finish_run(success)`

Signals:

- `run_started`
- `run_finished(summary)`
- `room_completed(room_id)`

Future requirements:

- Room start/end triggers.
- Enemy spawner.
- Reward choice.
- Safe garden placement screen.
- Mini-boss completion.
- Run summary UI.
