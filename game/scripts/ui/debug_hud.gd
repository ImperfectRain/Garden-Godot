extends Control

const MAX_EVENT_LOG_LINES := 6

@onready var debug_label: Label = $DebugLabel

var status_text := ""
var room_id := ""
var completed_room_count := 0
var objective_text := ""
var last_bloomchain := "None yet"
var event_log: Array[String] = []
var _player = null


func set_player(player: Node) -> void:
	_player = player
	refresh()


func set_status(message: String) -> void:
	status_text = message
	refresh()


func set_room_info(next_room_id: String, next_completed_count: int, next_objective_text: String) -> void:
	room_id = next_room_id
	completed_room_count = next_completed_count
	objective_text = next_objective_text
	refresh()


func set_last_bloomchain(text: String) -> void:
	last_bloomchain = text
	refresh()


func add_event(message: String) -> void:
	event_log.append(message)
	while event_log.size() > MAX_EVENT_LOG_LINES:
		event_log.pop_front()
	refresh()


func refresh() -> void:
	if debug_label == null:
		return
	var lines: Array[String] = [
		"Garden of Teeth - First Fun Test",
		"WASD move | Space pulse Saintmoth",
		"Room: %s | Completed: %s | Objective: %s" % [room_id, completed_room_count, objective_text],
		"Interval ticking: GardenTickSystem",
		"Enemy: Drifter slowly follows and deals contact damage",
		"Resources: %s" % GardenResources.get_all()
	]
	lines.append_array(_get_player_lines())
	lines.append("Status: %s" % status_text)
	lines.append("Last Bloomchain: %s" % last_bloomchain)
	lines.append("Garden:")
	lines.append_array(GardenManager.as_debug_rows())
	lines.append("Event Log:")
	lines.append_array(event_log)
	debug_label.text = "\n".join(PackedStringArray(lines))


func _get_player_lines() -> Array[String]:
	if _player == null:
		return [
			"Health: ?",
			"Shield: ?"
		]
	return [
		"Health: %s/%s" % [_player.health, _player.max_health],
		"Shield: %s" % _player.shield
	]
