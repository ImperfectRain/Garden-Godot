# System: Content Database

## Plainspeak

The Content Database is the library shelf. It loads the JSON files and lets the rest of the game ask for a piece, resource, enemy, room, or reward pool by id.

If a thing is content, it should probably be loaded here first.

## Technical

Owner file: `game/scripts/data/content_database.gd`

Autoload name: `ContentDatabase`

Loaded files:

- `game/data/garden_pieces/mvp_garden_pieces.json`
- `game/data/resources/mvp_resources.json`
- `game/data/enemies/mvp_enemies.json`
- `game/data/rooms/mvp_rooms.json`
- `game/data/rewards/mvp_reward_pools.json`

Primary APIs:

- `load_all()`
- `get_garden_piece(piece_id: String) -> Dictionary`
- `get_resource(resource_id: String) -> Dictionary`
- `get_enemy(enemy_id: String) -> Dictionary`
- `get_room(room_id: String) -> Dictionary`
- `get_reward_pool(pool_id: String) -> Dictionary`
- `list_garden_piece_ids(category := "") -> Array[String]`
- `validate_garden_piece(piece: Dictionary) -> Array[String]`

Signals:

- `content_loaded`
- `content_load_failed(path, reason)`

Implementation notes:

- Returned dictionaries are deep duplicates so callers do not mutate source data by accident.
- Validation is intentionally minimal in first pass. Expand it as schema needs become clearer.
- Data ids should remain stable once saves or journal records depend on them.
