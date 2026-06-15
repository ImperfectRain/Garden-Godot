# Content Schema

## Garden Piece JSON

Garden pieces are currently defined in:

- `game/data/garden_pieces/*.json`

Each garden piece should be its own JSON object file named after its stable id, such as `lantern_lily.json`. Add future pieces by adding a new JSON file to the folder, not by editing a master collection file.

Each garden piece should use these fields:

- `id`: stable snake_case identifier.
- `name`: player-facing display name.
- `category`: garden piece category.
- `tags`: list of search, rule, and synergy tags.
- `simple_description`: short casual-facing explanation.
- `detail_description`: exact technical/mechanical explanation.
- `produces`: resources or outputs created by this piece.
- `consumes`: resources this piece spends.
- `stores`: resources this piece can hold.
- `triggers`: events and actions this piece responds to.
- `effects`: mechanical effects caused by this piece.
- `likes`: piece ids, tags, or resources that synergize with this piece.
- `dislikes`: piece ids, tags, or resources that conflict with this piece.
- `synergies`: readable synergy notes for players, developers, and agents.
- `visual_asset`: future art resource path.
- `sound_asset`: future audio resource path.

## Allowed Categories

- `flora`
- `fauna`
- `object`

## Garden Piece Validation

`ContentDatabase.load_all()` validates garden pieces after loading JSON. Validation errors are stored in `ContentDatabase.validation_errors` and emitted through `content_load_failed(path, reason)`. Validation reports problems but does not block loading unless a JSON root is invalid.

Required garden piece fields:

- `id`
- `name`
- `category`
- `simple_description`
- `detail_description`
- `triggers`

Each `category` must be one of the allowed categories above.

Each trigger entry must include:

- `id`
- `event`
- `action`

Indexed collections should not contain duplicate `id` values. Duplicate ids are reported as validation errors and the first loaded entry is kept.

## Current Resources

- `light`
- `rot`
- `blood`
- `echo`

## Room Reward Pools

Rooms are currently defined in:

- `game/data/rooms/*.json`

Each room should include a `reward_pool` id. `RewardController` uses that id to look up a pool in:

- `game/data/rewards/*.json`

Reward pools currently use:

- `id`: stable pool identifier.
- `choices`: ordered list of garden piece ids.

The first fun test currently takes the first three available choices from the room's pool and skips pieces already placed in the garden. This is deterministic MVP behavior, not the final weighted or random reward resolver.

## Trigger Fields

Trigger entries currently support:

- `id`: stable trigger identifier within the piece.
- `event`: event name that activates this trigger.
- `action`: action interpreted by the garden system.
- `resource`: resource id used by resource actions.
- `amount`: produced amount, shield amount, or action magnitude depending on action.
- `cost`: resource cost for consuming actions.
- `cooldown`: interval seconds for `on_interval` triggers.
- `follow_up_events`: optional event names dispatched after this trigger succeeds.

Current causal Bloomchain support uses `follow_up_events` plus runtime chain context from `GardenManager`. The chain context is not authored directly in JSON yet; it is generated when successful triggers produce or spend resources.

Current first-chain authored events:

- `on_interval`: Lantern Lily produces Light.
- `on_pulse`: Saintmoth spends Light and grants Shield.
- `garden_woke`: Bellflower reacts to a successful Saintmoth Pulse and produces Echo.
