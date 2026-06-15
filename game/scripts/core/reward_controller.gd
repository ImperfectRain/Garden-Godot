extends RefCounted

signal reward_claimed(piece_id: String, cell: Vector2i)
signal reward_failed(piece_id: String, reason: String)

var is_reward_available := false
var _has_claimed_reward := false
var _reward_panel = null


func setup(reward_panel) -> void:
	_reward_panel = reward_panel
	_reward_panel.reward_selected.connect(_on_reward_selected)
	hide_rewards()


func show_rewards() -> void:
	is_reward_available = true
	_has_claimed_reward = false
	if _reward_panel != null:
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
