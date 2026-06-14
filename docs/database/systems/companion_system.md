# System: Companion

## Plainspeak

Saintmoth is the player's emotional anchor. It follows the player, lives in the Heart Tile, eats Light, and protects the player with a shield.

The MVP should make Saintmoth feel helpful before adding more companions.

## Technical

Owner file: `game/scripts/companion/companion_controller.gd`

Related files:

- `game/scripts/player/player_controller.gd`
- `game/data/garden_pieces/mvp_garden_pieces.json`

Current behavior:

- Follows a `player_path` target with simple smoothing.
- Listens for Saintmoth garden triggers.
- Emits `shield_requested(amount)` when Saintmoth's `grant_player_shield` trigger succeeds.
- Tracks simple `mood` and `bond_points`.

Signals:

- `mood_changed(mood)`
- `shield_requested(amount)`

MVP bond rule:

- `JournalManager.saintmoth_bond` starts at 1.
- First pass increments bond when a recorded run summary has a largest chain of 3+.

Future requirements:

- Idle flutter.
- Happy fed reaction.
- Worried low-health reaction.
- Excited Bloomchain reaction.
- Tired run-loss reaction.
- Bond level 2 cosmetic glow.
- Bond level 3 starter preference choice.
