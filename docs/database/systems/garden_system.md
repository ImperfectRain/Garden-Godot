# System: Garden

## Plainspeak

The garden is a 3x3 living grid. The center tile is Saintmoth's Heart Tile. Pieces go into cells, trigger when events happen, and produce or spend resources.

The garden should feel like a living place, not a stat inventory.

## Technical

Owner file: `game/scripts/garden/garden_manager.gd`

Autoload name: `GardenManager`

Constants:

- `GRID_SIZE = Vector2i(3, 3)`
- `HEART_CELL = Vector2i(1, 1)`

Primary APIs:

- `reset_grid()`
- `place_piece(cell, piece_id, allow_heart := false) -> bool`
- `remove_piece(cell) -> String`
- `trigger_piece(cell, event_name) -> bool`
- `pulse_selected() -> bool`
- `produce_from_intervals()`
- `get_piece_at(cell) -> Dictionary`
- `get_neighbors(cell, include_diagonal := false) -> Array[Vector2i]`
- `as_debug_rows() -> Array[String]`

Signals:

- `grid_reset`
- `piece_placed(cell, piece_id)`
- `piece_removed(cell, piece_id)`
- `piece_triggered(cell, piece_id, trigger)`
- `placement_failed(cell, piece_id, reason)`

Current trigger actions:

- `produce_resource`: calls `GardenResources.add`.
- `grant_player_shield`: spends a resource cost, then emits `piece_triggered`; the companion listens and asks the player to add shield.

Design constraints:

- The Heart Tile is reserved for the companion.
- The grid size should not change during MVP.
- Trigger application should stay readable and capped.
- UI should observe garden state, not own it.
