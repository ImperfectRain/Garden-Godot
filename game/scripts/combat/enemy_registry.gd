extends Node

var _enemies: Array[Node2D] = []


func _ready() -> void:
	CombatEvents.enemy_damage_requested.connect(_on_enemy_damage_requested)


func register_enemy(enemy: Node2D) -> void:
	if enemy == null or _enemies.has(enemy):
		return
	_enemies.append(enemy)


func unregister_enemy(enemy: Node2D) -> void:
	_enemies.erase(enemy)


func get_registered_enemies() -> Array[Node2D]:
	var live_enemies: Array[Node2D] = []
	for enemy in _enemies:
		if is_instance_valid(enemy):
			live_enemies.append(enemy)
	_enemies = live_enemies.duplicate()
	return live_enemies


func damage_nearest_enemy(amount: int, source: Dictionary = {}) -> bool:
	var target := _get_nearest_enemy(_get_source_position(source))
	if target == null or not target.has_method("take_damage"):
		return false
	target.take_damage(amount, source)
	return true


func _on_enemy_damage_requested(amount: int, source: Dictionary) -> void:
	damage_nearest_enemy(amount, source)


func _get_nearest_enemy(source_position: Vector2) -> Node2D:
	var live_enemies := get_registered_enemies()
	if live_enemies.is_empty():
		return null
	var nearest := live_enemies[0]
	var nearest_distance := source_position.distance_squared_to(nearest.global_position)
	for enemy in live_enemies:
		var distance := source_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func _get_source_position(source: Dictionary) -> Vector2:
	if source.has("world_position"):
		return source["world_position"]
	var cell = source.get("cell", Vector2i.ZERO)
	if cell is Vector2i:
		return Vector2(cell.x, cell.y)
	return Vector2.ZERO
