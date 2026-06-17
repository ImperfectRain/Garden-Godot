extends RefCounted

signal room_started(room_id: String)
signal room_completed(room_id: String)
signal reward_ready(room_id: String)

const DEFAULT_SURVIVAL_SECONDS := 24.0

var room_id := ""
var duration_seconds := DEFAULT_SURVIVAL_SECONDS
var enemy_goal := 1
var defeated_enemies := 0
var elapsed_seconds := 0.0
var is_active := false
var is_complete := false
var is_reward_ready := false


func start(next_room_id: String, duration: float = DEFAULT_SURVIVAL_SECONDS, next_enemy_goal := 1) -> void:
	room_id = next_room_id
	duration_seconds = max(duration, 0.1)
	enemy_goal = max(next_enemy_goal, 0)
	defeated_enemies = 0
	elapsed_seconds = 0.0
	is_active = true
	is_complete = false
	is_reward_ready = false
	room_started.emit(room_id)


func process(delta: float) -> void:
	if not is_active or is_complete:
		return
	elapsed_seconds = min(elapsed_seconds + delta, duration_seconds)
	if elapsed_seconds >= duration_seconds:
		_complete_room()


func record_enemy_defeated() -> void:
	if not is_active or is_complete:
		return
	defeated_enemies += 1
	if enemy_goal > 0 and defeated_enemies >= enemy_goal:
		_complete_room()


func stop() -> void:
	is_active = false


func mark_reward_claimed() -> void:
	is_reward_ready = false


func get_remaining_seconds() -> float:
	return max(duration_seconds - elapsed_seconds, 0.0)


func get_objective_text() -> String:
	if is_reward_ready:
		return "Reward ready"
	if is_complete:
		return "Reward claimed"
	return "defeat %s/%s or survive %.1fs" % [defeated_enemies, enemy_goal, get_remaining_seconds()]


func _complete_room() -> void:
	if is_complete:
		return
	is_complete = true
	is_active = false
	is_reward_ready = true
	room_completed.emit(room_id)
	reward_ready.emit(room_id)
