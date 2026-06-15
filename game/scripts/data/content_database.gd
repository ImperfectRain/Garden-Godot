extends Node

signal content_loaded
signal content_load_failed(path: String, reason: String)

const GARDEN_PIECES_PATH := "res://game/data/garden_pieces/mvp_garden_pieces.json"
const RESOURCES_PATH := "res://game/data/resources/mvp_resources.json"
const ENEMIES_PATH := "res://game/data/enemies/mvp_enemies.json"
const ROOMS_PATH := "res://game/data/rooms/mvp_rooms.json"
const REWARD_POOLS_PATH := "res://game/data/rewards/mvp_reward_pools.json"
const GARDEN_PIECE_REQUIRED_FIELDS := ["id", "name", "category", "simple_description", "detail_description", "triggers"]
const GARDEN_PIECE_CATEGORIES := ["flora", "fauna", "object"]
const TRIGGER_REQUIRED_FIELDS := ["id", "event", "action"]

var garden_pieces: Dictionary = {}
var resources: Dictionary = {}
var enemies: Dictionary = {}
var rooms: Dictionary = {}
var reward_pools: Dictionary = {}
var validation_errors: Array[String] = []
var is_loaded := false


func _ready() -> void:
	load_all()


func load_all() -> void:
	validation_errors.clear()
	garden_pieces = _load_indexed_collection(GARDEN_PIECES_PATH, "pieces")
	resources = _load_indexed_collection(RESOURCES_PATH, "resources")
	enemies = _load_indexed_collection(ENEMIES_PATH, "enemies")
	rooms = _load_indexed_collection(ROOMS_PATH, "rooms")
	reward_pools = _load_indexed_collection(REWARD_POOLS_PATH, "reward_pools")
	_validate_garden_pieces()
	is_loaded = true
	content_loaded.emit()


func get_garden_piece(piece_id: String) -> Dictionary:
	return garden_pieces.get(piece_id, {}).duplicate(true)


func get_resource(resource_id: String) -> Dictionary:
	return resources.get(resource_id, {}).duplicate(true)


func get_enemy(enemy_id: String) -> Dictionary:
	return enemies.get(enemy_id, {}).duplicate(true)


func get_room(room_id: String) -> Dictionary:
	return rooms.get(room_id, {}).duplicate(true)


func get_reward_pool(pool_id: String) -> Dictionary:
	return reward_pools.get(pool_id, {}).duplicate(true)


func list_garden_piece_ids(category := "") -> Array[String]:
	var ids: Array[String] = []
	for piece_id in garden_pieces.keys():
		var piece: Dictionary = garden_pieces[piece_id]
		if category.is_empty() or piece.get("category", "") == category:
			ids.append(piece_id)
	ids.sort()
	return ids


func validate_garden_piece(piece: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in GARDEN_PIECE_REQUIRED_FIELDS:
		if not piece.has(key) or str(piece[key]).is_empty():
			errors.append("Missing required field: %s" % key)
	if not GARDEN_PIECE_CATEGORIES.has(piece.get("category", "")):
		errors.append("Invalid category: %s" % piece.get("category", ""))
	var triggers = piece.get("triggers", [])
	if typeof(triggers) != TYPE_ARRAY:
		errors.append("Field triggers must be an array")
		return errors
	for index in range(triggers.size()):
		var trigger = triggers[index]
		if typeof(trigger) != TYPE_DICTIONARY:
			errors.append("Trigger %d must be an object" % index)
			continue
		for key in TRIGGER_REQUIRED_FIELDS:
			if not trigger.has(key) or str(trigger[key]).is_empty():
				errors.append("Trigger %d missing required field: %s" % [index, key])
	return errors


func _load_indexed_collection(path: String, collection_key: String) -> Dictionary:
	var parsed := _load_json(path)
	var indexed: Dictionary = {}
	for entry in parsed.get(collection_key, []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var id := str(entry.get("id", ""))
		if id.is_empty():
			_report_validation_error(path, "Entry in %s is missing id" % collection_key)
			continue
		if indexed.has(id):
			_report_validation_error(path, "Duplicate id in %s: %s" % [collection_key, id])
			continue
		indexed[id] = entry
	return indexed


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		content_load_failed.emit(path, "File does not exist")
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		content_load_failed.emit(path, "JSON root must be an object")
		return {}
	return parsed


func _validate_garden_pieces() -> void:
	for piece_id in garden_pieces.keys():
		var piece: Dictionary = garden_pieces[piece_id]
		for error in validate_garden_piece(piece):
			_report_validation_error(GARDEN_PIECES_PATH, "Garden piece %s: %s" % [piece_id, error])


func _report_validation_error(path: String, reason: String) -> void:
	validation_errors.append("%s: %s" % [path, reason])
	content_load_failed.emit(path, reason)
