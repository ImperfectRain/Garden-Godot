extends Node

signal chain_started(origin_cell: Vector2i, origin_piece_id: String)
signal chain_step_added(cell: Vector2i, piece_id: String, action: String, chain_length: int)
signal chain_finished(length: int, piece_ids: Array[String])

const CHAIN_TIMEOUT_SECONDS := 1.25
const SOFT_CHAIN_CAP := 8

var active_chain: Array = []
var largest_chain_this_run := 0
var _chain_elapsed := 0.0
var _causal_chains: Dictionary = {}
var _recorded_chain_ids: Dictionary = {}


func _process(delta: float) -> void:
	if active_chain.is_empty():
		return
	_chain_elapsed += delta
	if _chain_elapsed >= CHAIN_TIMEOUT_SECONDS:
		finish_chain()


func reset_run() -> void:
	active_chain.clear()
	_causal_chains.clear()
	_recorded_chain_ids.clear()
	largest_chain_this_run = 0
	_chain_elapsed = 0.0


func record_trigger(cell: Vector2i, piece_id: String, trigger: Dictionary, context: Dictionary = {}) -> void:
	var chain_id := str(context.get("chain_id", ""))
	if not chain_id.is_empty():
		_record_causal_trigger(chain_id, cell, piece_id, trigger)
		return
	_record_temporal_trigger(cell, piece_id, trigger)


func finish_chain() -> void:
	if active_chain.is_empty():
		return
	var ids := _get_piece_ids(active_chain)
	var length := active_chain.size()
	var chain_id := str(active_chain[0].get("chain_id", ""))
	var was_recorded := not chain_id.is_empty() and _recorded_chain_ids.has(chain_id)
	largest_chain_this_run = max(largest_chain_this_run, length)
	if length >= 3 and not was_recorded:
		JournalManager.record_bloomchain(ids)
		if not chain_id.is_empty():
			_recorded_chain_ids[chain_id] = true
	if not was_recorded:
		chain_finished.emit(length, ids)
	active_chain.clear()
	_chain_elapsed = 0.0


func get_active_chain_ids() -> Array[String]:
	return _get_piece_ids(active_chain)


func _record_temporal_trigger(cell: Vector2i, piece_id: String, trigger: Dictionary) -> void:
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


func _record_causal_trigger(chain_id: String, cell: Vector2i, piece_id: String, trigger: Dictionary) -> void:
	var action := str(trigger.get("action", ""))
	var chain: Array = _causal_chains.get(chain_id, [])
	if _has_piece_triggered_in_chain(chain, piece_id):
		active_chain = chain.duplicate(true)
		finish_chain()
		chain = []
		_recorded_chain_ids.erase(chain_id)
	chain.append(_make_step(cell, piece_id, action, chain_id))
	if chain.size() > SOFT_CHAIN_CAP:
		chain = chain.slice(0, SOFT_CHAIN_CAP)
	_causal_chains[chain_id] = chain
	active_chain = chain.duplicate(true)
	_chain_elapsed = 0.0
	if chain.size() == 1:
		chain_started.emit(cell, piece_id)
	chain_step_added.emit(cell, piece_id, action, chain.size())
	_record_completed_causal_chain_if_needed(chain_id, chain)


func _record_completed_causal_chain_if_needed(chain_id: String, chain: Array) -> void:
	if chain.size() < 3 or _recorded_chain_ids.has(chain_id):
		return
	var ids := _get_piece_ids(chain)
	largest_chain_this_run = max(largest_chain_this_run, chain.size())
	JournalManager.record_bloomchain(ids)
	_recorded_chain_ids[chain_id] = true
	chain_finished.emit(chain.size(), ids)


func _get_piece_ids(chain: Array) -> Array[String]:
	var ids: Array[String] = []
	for step in chain:
		ids.append(str(step.get("piece_id", "")))
	return ids


func _has_piece_triggered(piece_id: String) -> bool:
	for step in active_chain:
		if step.get("piece_id", "") == piece_id:
			return true
	return false


func _has_piece_triggered_in_chain(chain: Array, piece_id: String) -> bool:
	for step in chain:
		if step.get("piece_id", "") == piece_id:
			return true
	return false


func _make_step(cell: Vector2i, piece_id: String, action: String, chain_id := "") -> Dictionary:
	return {
		"cell": cell,
		"piece_id": piece_id,
		"action": action,
		"chain_id": chain_id,
		"time_msec": Time.get_ticks_msec()
	}
