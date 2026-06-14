# Content Schema

## Garden Piece JSON

Garden pieces are currently defined in:

- `game/data/garden_pieces/mvp_garden_pieces.json`

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

## Current Resources

- `light`
- `rot`
- `blood`
- `echo`
