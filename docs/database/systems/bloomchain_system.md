# System: Bloomchains

## Plainspeak

A Bloomchain is a visible sequence where garden pieces wake each other up. Three or more linked triggers should feel like a small beautiful cascade.

The player should be able to explain why it happened.

## Technical

Owner file: `game/scripts/garden/bloomchain_manager.gd`

Autoload name: `Bloomchains`

Primary APIs:

- `reset_run()`
- `record_trigger(cell, piece_id, trigger)`
- `finish_chain()`
- `get_active_chain_ids() -> Array[String]`

Signals:

- `chain_started(origin_cell, origin_piece_id)`
- `chain_step_added(cell, piece_id, action, chain_length)`
- `chain_finished(length, piece_ids)`

Safety rules in first pass:

- `CHAIN_TIMEOUT_SECONDS = 1.25`
- `SOFT_CHAIN_CAP = 8`
- A repeated piece id ends the current chain and starts a new one.
- Chains of 3+ are recorded in the journal.

Future implementation requirements:

- Draw visible paths between grid cells.
- Add sound cues at chain length 3+.
- Add stronger feedback at chain length 5+.
- Keep visual playback short and readable.
- Detect loops before they become infinite.
