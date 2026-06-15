extends Node

signal content_loaded
signal content_load_failed(path: String, reason: String)

const GARDEN_PIECES_DIR := "res://game/data/garden_pieces"
const RESOURCES_DIR := "res://game/data/resources"
const ENEMIES_DIR := "res://game/data/enemies"
const ROOMS_DIR := "res://game/data/rooms"
const REWARD_POOLS_DIR := "res://game/data/rewards"
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
var _content_source_paths: Dictionary = {}


func _ready() -> void:
	load_all()


func load_all() -> void:
	validation_errors.clear()
	_content_source_paths.clear()
	garden_pieces = _load_indexed_directory(GARDEN_PIECES_DIR, "pieces")
	resources = _load_indexed_directory(RESOURCES_DIR, "resources")
	enemies = _load_indexed_directory(ENEMIES_DIR, "enemies")
	rooms = _load_indexed_directory(ROOMS_DIR, "rooms")
	reward_pools = _load_indexed_directory(REWARD_POOLS_DIR, "reward_pools")
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


func _load_indexed_directory(directory_path: String, collection_key: String) -> Dictionary:
	var indexed: Dictionary = {}
	_content_source_paths[collection_key] = {}
	for path in _list_json_files(directory_path):
		var parsed := _load_json(path)
		for entry in _extract_entries(parsed, collection_key):
			_add_indexed_entry(indexed, collection_key, entry, path)
	return indexed


func _extract_entries(parsed: Dictionary, collection_key: String) -> Array:
	if parsed.has(collection_key):
		var collection = parsed.get(collection_key, [])
		if typeof(collection) == TYPE_ARRAY:
			return collection
		return []
	if parsed.has("id"):
		return [parsed]
	return []


func _add_indexed_entry(indexed: Dictionary, collection_key: String, entry, path: String) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		_report_validation_error(path, "Entry in %s must be an object" % collection_key)
		return
	var id := str(entry.get("id", ""))
	if id.is_empty():
		_report_validation_error(path, "Entry in %s is missing id" % collection_key)
		return
	if indexed.has(id):
		_report_validation_error(path, "Duplicate id in %s: %s" % [collection_key, id])
		return
	indexed[id] = entry
	_content_source_paths[collection_key][id] = path


func _list_json_files(directory_path: String) -> Array[String]:
	var paths: Array[String] = []
	var dir := DirAccess.open(directory_path)
	if dir == null:
		content_load_failed.emit(directory_path, "Directory does not exist")
		return paths
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		var path := "%s/%s" % [directory_path, file_name]
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				paths.append_array(_list_json_files(path))
		elif file_name.get_extension().to_lower() == "json":
			paths.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths


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
			var path := str(_content_source_paths.get("pieces", {}).get(piece_id, GARDEN_PIECES_DIR))
			_report_validation_error(path, "Garden piece %s: %s" % [piece_id, error])


func _report_validation_error(path: String, reason: String) -> void:
	validation_errors.append("%s: %s" % [path, reason])
	content_load_failed.emit(path, reason)
