extends Node

@warning_ignore("unused_signal")
signal player_shield_requested(amount: int, source: Dictionary)
@warning_ignore("unused_signal")
signal player_damage_requested(amount: int, source: Dictionary)
@warning_ignore("unused_signal")
signal player_damaged(amount: int, source: Dictionary)
@warning_ignore("unused_signal")
signal enemy_damage_requested(amount: int, source: Dictionary)
@warning_ignore("unused_signal")
signal enemy_damaged(enemy_id: String, amount: int, source: Dictionary)
@warning_ignore("unused_signal")
signal enemy_defeated(enemy_id: String, world_position: Vector2, source: Dictionary)
@warning_ignore("unused_signal")
signal helper_spawn_requested(helper_id: String, amount: int, source: Dictionary)

# Generic combat-facing effect bus.
# This is intentionally not Saintmoth-specific: garden effects, enemies, room
# scripts, or future relics can request player/enemy-facing combat outcomes
# without knowing which scene currently owns the player, enemies, or helpers.
