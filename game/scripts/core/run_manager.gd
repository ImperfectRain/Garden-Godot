extends Node

signal run_started
signal run_finished(summary: Dictionary)
signal room_completed(room_id: String)

var current_room_index := 0
var planned_rooms: Array[String] = ["meadow", "nursery", "burrow", "reliquary", "boss_grove"]
var is_run_active := false


func start_run() -> void:
	is_run_active = true
	current_room_index = 0
	GardenResources.reset()
	GardenManager.reset_grid()
	Bloomchains.reset_run()
	JournalManager.discover_piece("saintmoth")
	run_started.emit()


func get_current_room_id() -> String:
	if current_room_index < 0 or current_room_index >= planned_rooms.size():
		return ""
	return planned_rooms[current_room_index]


func get_completed_room_count() -> int:
	return current_room_index


func complete_current_room() -> void:
	var room_id := get_current_room_id()
	if room_id.is_empty():
		return
	room_completed.emit(room_id)
	current_room_index += 1
	if current_room_index >= planned_rooms.size():
		finish_run(true)


func finish_run(success: bool) -> void:
	if not is_run_active:
		return
	is_run_active = false
	Bloomchains.finish_chain()
	var summary := {
		"success": success,
		"largest_chain": Bloomchains.largest_chain_this_run,
		"rooms_completed": current_room_index,
		"resources": GardenResources.get_all()
	}
	JournalManager.record_run(summary)
	run_finished.emit(summary)
