extends RefCounted

signal reward_claimed(piece_id: String, cell: Vector2i)
signal reward_failed(piece_id: String, reason: String)

const REWARD_CHOICE_COUNT := 3

var is_reward_available := false
var _has_claimed_reward := false
var _reward_panel = null


func setup(reward_panel) -> void:
	_reward_panel = reward_panel
	_reward_panel.reward_selected.connect(_on_reward_selected)
	hide_rewards()


func show_rewards_for_room(room_id: String) -> void:
	var rewards := _get_rewards_for_room(room_id)
	if rewards.is_empty():
		reward_failed.emit("", "No rewards available for room %s" % room_id)
		return
	show_rewards(rewards)


func show_rewards(piece_ids: Array[String]) -> void:
	is_reward_available = true
	_has_claimed_reward = false
	if _reward_panel != null:
		_reward_panel.set_rewards(piece_ids)
		_reward_panel.show_rewards()


func hide_rewards() -> void:
	is_reward_available = false
	if _reward_panel != null:
		_reward_panel.hide_rewards()


func has_claimed_reward() -> bool:
	return _has_claimed_reward


func _on_reward_selected(piece_id: String) -> void:
	if _has_claimed_reward or not is_reward_available:
		return
	var placed_cell := GardenManager.place_piece_in_first_empty_cell(piece_id)
	if placed_cell == Vector2i(-1, -1):
		reward_failed.emit(piece_id, "No empty garden cell")
		return
	_has_claimed_reward = true
	hide_rewards()
	reward_claimed.emit(piece_id, placed_cell)


func _get_rewards_for_room(room_id: String) -> Array[String]:
	var room := ContentDatabase.get_room(room_id)
	var pool_id := str(room.get("reward_pool", ""))
	if pool_id.is_empty():
		return []
	var pool := ContentDatabase.get_reward_pool(pool_id)
	var choices: Array[String] = []
	for choice in pool.get("choices", []):
		var piece_id := str(choice)
		if piece_id.is_empty() or _is_piece_already_placed(piece_id):
			continue
		choices.append(piece_id)
		if choices.size() >= REWARD_CHOICE_COUNT:
			break
	return choices


func _is_piece_already_placed(piece_id: String) -> bool:
	for placed_piece_id in GardenManager.get_all_cells().values():
		if str(placed_piece_id) == piece_id:
			return true
	return false
