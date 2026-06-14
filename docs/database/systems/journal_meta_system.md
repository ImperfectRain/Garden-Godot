# System: Journal And Meta

## Plainspeak

Losing should still grow something. The journal records what the player discovered, which chains happened, and how Saintmoth's bond is progressing.

Meta-progression should unlock options and memories, not raw stat grind.

## Technical

Owner file: `game/scripts/meta/journal_manager.gd`

Autoload name: `JournalManager`

Primary APIs:

- `discover_piece(piece_id)`
- `record_bloomchain(piece_ids)`
- `record_run(summary)`
- `get_discovered_piece_ids() -> Array[String]`

Signals:

- `piece_discovered(piece_id)`
- `bloomchain_recorded(piece_ids)`
- `run_recorded(summary)`

Current stored state:

- `discovered_pieces`
- `discovered_bloomchains`
- `run_history`
- `saintmoth_bond`

Future requirements:

- Save/load journal state.
- Companion notes.
- Largest chain achieved.
- Run memories in home garden.
- Discovered symbiosis entries.
- Cosmetic unlock records.
