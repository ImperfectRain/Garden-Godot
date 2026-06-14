extends Node

signal chain_started(origin_cell: Vector2i, origin_piece_id: String)
signal chain_step_added(cell: Vector2i, piece_id: String, action: String, chain_length: int)
signal chain_finished(length: int, piece_ids: Array[String])

const CHAIN_TIMEOUT_SECONDS := 1.25
const SOFT_CHAIN_CAP := 8

var active_chain: Array[Dictionary] = []
var largest_chain_this_run := 0
var _chain_elapsed := 0.0


func _process(delta: float) -> void:
	if active_chain.is_empty():
		return
	_chain_elapsed += delta
	if _chain_elapsed >= CHAIN_TIMEOUT_SECONDS:
		finish_chain()


func reset_run() -> void:
	active_chain.clear()
	largest_chain_this_run = 0
	_chain_elapsed = 0.0


func record_trigger(cell: Vector2i, piece_id: String, trigger: Dictionary) -> void:
	var action := str(trigger.get("action", ""))
	if active_chain.is_empty():
		active_chain.append(_make_step(cell, piece_id, action))
		_chain_elapsed = 0.0
		chain_started.emit(cell, piece_id)
		chain_step_added.emit(cell, piece_id, action, active_chain.size())
		return
	if _has_piece_triggered(piece_id):
		finish_chain()
		active_chain.append(_make_step(cell, piece_id, action))
		chain_started.emit(cell, piece_id)
	else:
		active_chain.append(_make_step(cell, piece_id, action))
	_chain_elapsed = 0.0
	chain_step_added.emit(cell, piece_id, action, active_chain.size())
	if active_chain.size() >= SOFT_CHAIN_CAP:
		finish_chain()


func finish_chain() -> void:
	if active_chain.is_empty():
		return
	var ids: Array[String] = []
	for step in active_chain:
		ids.append(str(step.get("piece_id", "")))
	var length := active_chain.size()
	largest_chain_this_run = max(largest_chain_this_run, length)
	if length >= 3:
		JournalManager.record_bloomchain(ids)
	chain_finished.emit(length, ids)
	active_chain.clear()
	_chain_elapsed = 0.0


func get_active_chain_ids() -> Array[String]:
	var ids: Array[String] = []
	for step in active_chain:
		ids.append(str(step.get("piece_id", "")))
	return ids


func _has_piece_triggered(piece_id: String) -> bool:
	for step in active_chain:
		if step.get("piece_id", "") == piece_id:
			return true
	return false


func _make_step(cell: Vector2i, piece_id: String, action: String) -> Dictionary:
	return {
		"cell": cell,
		"piece_id": piece_id,
		"action": action,
		"time_msec": Time.get_ticks_msec()
	}
