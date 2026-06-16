extends RefCounted

signal reward_claimed(piece_id: String, cell: Vector2i)
signal reward_failed(piece_id: String, reason: String)
signal placement_started(piece_id: String, cell: Vector2i)
signal placement_cursor_changed(piece_id: String, cell: Vector2i)
signal placement_cancelled(piece_id: String)

const REWARD_CHOICE_COUNT := 3

var is_reward_available := false
var _has_claimed_reward := false
var _reward_panel = null
var _pending_piece_id := ""
var _placement_cell := Vector2i.ZERO


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


func has_pending_placement() -> bool:
	return not _pending_piece_id.is_empty()


func get_pending_piece_id() -> String:
	return _pending_piece_id


func get_placement_cell() -> Vector2i:
	return _placement_cell


func handle_placement_input(event: InputEvent) -> bool:
	if not has_pending_placement() or (event is InputEventKey) == false:
		return false
	var key_event := event as InputEventKey
	if not key_event.is_pressed() or key_event.echo:
		return false
	match key_event.keycode:
		KEY_LEFT:
			_move_placement_cursor(Vector2i.LEFT)
			return true
		KEY_RIGHT:
			_move_placement_cursor(Vector2i.RIGHT)
			return true
		KEY_UP:
			_move_placement_cursor(Vector2i.UP)
			return true
		KEY_DOWN:
			_move_placement_cursor(Vector2i.DOWN)
			return true
		KEY_ENTER, KEY_KP_ENTER, KEY_E:
			_confirm_placement()
			return true
		KEY_ESCAPE:
			_cancel_placement()
			return true
	return false


func _on_reward_selected(piece_id: String) -> void:
	if _has_claimed_reward or not is_reward_available:
		return
	var first_cell := _find_first_valid_cell(piece_id)
	if first_cell == Vector2i(-1, -1):
		reward_failed.emit(piece_id, "No empty garden cell")
		return
	_pending_piece_id = piece_id
	_placement_cell = first_cell
	if _reward_panel != null:
		_reward_panel.hide_rewards()
	placement_started.emit(_pending_piece_id, _placement_cell)


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


func _find_first_valid_cell(piece_id: String) -> Vector2i:
	for y in range(GardenManager.GRID_SIZE.y):
		for x in range(GardenManager.GRID_SIZE.x):
			var cell := Vector2i(x, y)
			if GardenManager.can_place_piece(cell, piece_id):
				return cell
	return Vector2i(-1, -1)


func _move_placement_cursor(offset: Vector2i) -> void:
	var next_cell := _placement_cell + offset
	next_cell.x = clampi(next_cell.x, 0, GardenManager.GRID_SIZE.x - 1)
	next_cell.y = clampi(next_cell.y, 0, GardenManager.GRID_SIZE.y - 1)
	if next_cell == _placement_cell:
		return
	_placement_cell = next_cell
	placement_cursor_changed.emit(_pending_piece_id, _placement_cell)


func _confirm_placement() -> void:
	var error := GardenManager.get_placement_error(_placement_cell, _pending_piece_id)
	if not error.is_empty():
		reward_failed.emit(_pending_piece_id, error)
		return
	var piece_id := _pending_piece_id
	var placed_cell := _placement_cell
	if not GardenManager.place_piece(placed_cell, piece_id):
		reward_failed.emit(piece_id, "Placement failed")
		return
	_pending_piece_id = ""
	_has_claimed_reward = true
	hide_rewards()
	reward_claimed.emit(piece_id, placed_cell)


func _cancel_placement() -> void:
	var piece_id := _pending_piece_id
	_pending_piece_id = ""
	if _reward_panel != null and is_reward_available and not _has_claimed_reward:
		_reward_panel.show_rewards()
	placement_cancelled.emit(piece_id)
