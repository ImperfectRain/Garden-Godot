extends Node

signal player_shield_requested(amount: int, source: Dictionary)
signal player_damage_requested(amount: int, source: Dictionary)
signal player_damaged(amount: int, source: Dictionary)
signal enemy_damage_requested(amount: int, source: Dictionary)
signal helper_spawn_requested(helper_id: String, amount: int, source: Dictionary)

# Generic combat-facing effect bus.
# This is intentionally not Saintmoth-specific: garden effects, enemies, room
# scripts, or future relics can request player/enemy-facing combat outcomes
# without knowing which scene currently owns the player, enemies, or helpers.
