# Content Schema

## Plainspeak

Most new game things should begin as data. A garden piece should say what it is, what it likes, what it makes or eats, and what should happen when it triggers. Code should then interpret that data.

This keeps new Flora, Fauna, Objects, enemies, rooms, and rewards easy to add without rewriting the game.

## Technical

### Garden Piece File

Path: `game/data/garden_pieces/mvp_garden_pieces.json`

Root fields:

- `schema_version`: integer schema version.
- `pieces`: array of garden piece objects.

Required garden piece fields:

- `id`: stable snake_case identifier. Never rename after saves or journal entries depend on it.
- `name`: display name.
- `category`: one of `flora`, `fauna`, `object`.
- `tags`: lowercase tags used by filtering, synergies, and future UI.
- `simple_description`: casual-facing text.
- `detail_description`: exact mechanical text for advanced players.
- `produces`: array of production descriptors.
- `consumes`: array of resource costs.
- `stores`: array of storage descriptors.
- `triggers`: array of runtime trigger descriptors.
- `effects`: array of effect descriptors.
- `likes`: ids, tags, or resource ids this piece likes.
- `dislikes`: ids, tags, or resource ids this piece dislikes.
- `synergies`: human-readable synergy notes.
- `visual_asset`: future resource path.
- `sound_asset`: future resource path.

### Trigger Descriptor

Common fields:

- `id`: unique trigger id within the piece.
- `event`: event name listened for by the piece.
- `action`: action interpreted by `GardenManager` or a later specialized system.

Current supported actions:

- `produce_resource`
- `grant_player_shield`

Reserved actions already present in data for future implementation:

- `spawn_helper`
- `repeat_last_trigger`
- `move_resource`
- `damage_nearby_enemies`
- `copy_output`
- `connect_adjacent_flora`
- `protect_adjacent_living`

### Resource File

Path: `game/data/resources/mvp_resources.json`

Required fields:

- `id`
- `name`
- `plain_description`
- `technical_description`
- `color`

### Enemy File

Path: `game/data/enemies/mvp_enemies.json`

Required fields:

- `id`
- `name`
- `plain_description`
- `technical_description`
- `health`
- `speed`
- `damage`
- `tags`

### Room File

Path: `game/data/rooms/mvp_rooms.json`

Required fields:

- `id`
- `name`
- `plain_description`
- `technical_description`
- `reward_pool`
- `enemy_pool`

### Reward Pool File

Path: `game/data/rewards/mvp_reward_pools.json`

Required fields:

- `id`
- `choices`: array of garden piece ids.

## Editing Checklist

When adding a content entry:

1. Add the JSON object.
2. Keep `id` snake_case and stable.
3. Include both simple and technical descriptions.
4. Use existing resource ids unless intentionally adding a new resource.
5. Add or update docs if the content introduces a new action, event, or system assumption.
6. Run the project or at least validate JSON syntax before committing.
