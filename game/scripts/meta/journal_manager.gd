extends Node

signal piece_discovered(piece_id: String)
signal bloomchain_recorded(piece_ids: Array[String])
signal run_recorded(summary: Dictionary)

var discovered_pieces: Dictionary = {}
var discovered_bloomchains: Array[Array] = []
var run_history: Array[Dictionary] = []
var saintmoth_bond := 1


func discover_piece(piece_id: String) -> void:
	if discovered_pieces.has(piece_id):
		return
	discovered_pieces[piece_id] = true
	piece_discovered.emit(piece_id)


func record_bloomchain(piece_ids: Array[String]) -> void:
	discovered_bloomchains.append(piece_ids.duplicate())
	bloomchain_recorded.emit(piece_ids)


func record_run(summary: Dictionary) -> void:
	run_history.append(summary.duplicate(true))
	if int(summary.get("largest_chain", 0)) >= 3:
		saintmoth_bond = min(saintmoth_bond + 1, 3)
	run_recorded.emit(summary)


func get_discovered_piece_ids() -> Array[String]:
	var ids: Array[String] = []
	for piece_id in discovered_pieces.keys():
		ids.append(str(piece_id))
	ids.sort()
	return ids
