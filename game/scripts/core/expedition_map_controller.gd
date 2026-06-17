extends RefCounted

signal map_changed
signal room_selected(room_id: String, position: Vector2i)
signal selection_failed(reason: String)

const ROOM_SEQUENCE: Array[String] = ["meadow", "nursery", "burrow", "reliquary", "boss_grove"]
const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0)
]

var rooms: Dictionary = {}
var current_position := Vector2i.ZERO
var selected_position := Vector2i.ZERO


func generate_demo_map() -> void:
	rooms.clear()
	current_position = Vector2i.ZERO
	selected_position = current_position
	_add_room(current_position, ROOM_SEQUENCE[0], true, true, true)
	var cursor := current_position
	for index in range(1, ROOM_SEQUENCE.size()):
		cursor += CARDINAL_DIRECTIONS[(index - 1) % CARDINAL_DIRECTIONS.size()]
		_add_room(cursor, ROOM_SEQUENCE[index], false, false, false)
	_reveal_adjacent_rooms(current_position)
	map_changed.emit()


func complete_current_room() -> void:
	if not rooms.has(current_position):
		return
	var room: Dictionary = rooms[current_position]
	room["cleared"] = true
	room["revealed"] = true
	rooms[current_position] = room
	_reveal_adjacent_rooms(current_position)
	map_changed.emit()


func move_selection(direction: Vector2i) -> bool:
	var target := selected_position + direction
	if not rooms.has(target):
		selection_failed.emit("No expedition room in that direction")
		return false
	var room: Dictionary = rooms[target]
	if not bool(room.get("revealed", false)):
		selection_failed.emit("That room is still hidden")
		return false
	selected_position = target
	map_changed.emit()
	return true


func confirm_selection() -> bool:
	if selected_position == current_position:
		selection_failed.emit("Already in this room")
		return false
	if not rooms.has(selected_position):
		selection_failed.emit("No room selected")
		return false
	var room: Dictionary = rooms[selected_position]
	if not bool(room.get("revealed", false)):
		selection_failed.emit("Selected room is hidden")
		return false
	if not _can_travel_to(selected_position):
		selection_failed.emit("Select an adjacent revealed room")
		return false
	current_position = selected_position
	room["visited"] = true
	rooms[current_position] = room
	room_selected.emit(str(room.get("room_id", "")), current_position)
	map_changed.emit()
	return true


func get_current_room_id() -> String:
	if not rooms.has(current_position):
		return ""
	return str(rooms[current_position].get("room_id", ""))


func get_completed_room_count() -> int:
	var count := 0
	for room in rooms.values():
		if bool(room.get("cleared", false)):
			count += 1
	return count


func get_room_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for position in rooms.keys():
		var room: Dictionary = rooms[position].duplicate(true)
		room["position"] = position
		room["is_current"] = position == current_position
		room["is_selected"] = position == selected_position
		room["is_selectable"] = bool(room.get("revealed", false)) and _can_travel_to(position)
		snapshot.append(room)
	return snapshot


func _add_room(position: Vector2i, room_id: String, revealed: bool, visited: bool, cleared: bool) -> void:
	rooms[position] = {
		"room_id": room_id,
		"revealed": revealed,
		"visited": visited,
		"cleared": cleared
	}


func _reveal_adjacent_rooms(position: Vector2i) -> void:
	for direction in CARDINAL_DIRECTIONS:
		var target := position + direction
		if rooms.has(target):
			var room: Dictionary = rooms[target]
			room["revealed"] = true
			rooms[target] = room


func _can_travel_to(position: Vector2i) -> bool:
	if position == current_position:
		return true
	if current_position.distance_squared_to(position) != 1:
		return false
	var room: Dictionary = rooms.get(position, {})
	return bool(room.get("revealed", false))
