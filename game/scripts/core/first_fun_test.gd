extends Node2D

const SimpleRoomControllerScript := preload("res://game/scripts/core/simple_room_controller.gd")
const RewardControllerScript := preload("res://game/scripts/core/reward_controller.gd")
const ExpeditionMapControllerScript := preload("res://game/scripts/core/expedition_map_controller.gd")
const DrifterScene := preload("res://game/scenes/enemies/drifter.tscn")
const DRIFTER_SPAWN_POSITION := Vector2(190, 90)

@onready var player := $Player
@onready var debug_hud := $CanvasLayer/DebugHUD
@onready var garden_grid_panel := $CanvasLayer/GardenGridPanel
@onready var garden_inspect_panel := $CanvasLayer/GardenInspectPanel
@onready var expedition_map_panel := $CanvasLayer/ExpeditionMapPanel
@onready var reward_choice_panel := $CanvasLayer/RewardChoicePanel
@onready var run_summary_panel := $CanvasLayer/RunSummaryPanel
@onready var prototype_feedback := $CanvasLayer/PrototypeFeedback

var _last_health := 0
var _last_shield := 0
var _room_controller := SimpleRoomControllerScript.new()
var _reward_controller := RewardControllerScript.new()
var _expedition_map := ExpeditionMapControllerScript.new()
var _active_drifter: Node = null
var _is_inspecting_garden := false


func _ready() -> void:
	_active_drifter = $Drifter
	RunManager.start_run()
	RunManager.run_finished.connect(_on_run_finished)
	_expedition_map.generate_demo_map()
	GardenManager.place_piece(Vector2i(0, 1), "lantern_lily")
	debug_hud.set_player(player)
	debug_hud.set_status("Survive until the reward appears")
	player.health_changed.connect(_on_player_health_changed)
	player.shield_changed.connect(_on_player_shield_changed)
	player.player_defeated.connect(_on_player_defeated)
	GardenResources.resource_changed.connect(_on_resource_changed)
	GardenResources.resource_spent.connect(_on_resource_spent)
	GardenResources.resource_failed.connect(_on_resource_failed)
	CombatEvents.player_damaged.connect(_on_player_damaged_event)
	CombatEvents.enemy_damaged.connect(_on_enemy_damaged)
	CombatEvents.enemy_defeated.connect(_on_enemy_defeated)
	CombatEvents.helper_spawn_requested.connect(_on_helper_spawn_requested)
	GardenManager.piece_placed.connect(_on_piece_placed)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	Bloomchains.chain_finished.connect(_on_bloomchain_finished)
	_room_controller.room_started.connect(_on_room_started)
	_room_controller.reward_ready.connect(_on_room_reward_ready)
	_expedition_map.map_changed.connect(_on_expedition_map_changed)
	_expedition_map.room_selected.connect(_on_expedition_room_selected)
	_expedition_map.selection_failed.connect(_on_expedition_selection_failed)
	_reward_controller.setup(reward_choice_panel)
	_reward_controller.placement_started.connect(_on_reward_placement_started)
	_reward_controller.placement_cursor_changed.connect(_on_reward_placement_cursor_changed)
	_reward_controller.placement_cancelled.connect(_on_reward_placement_cancelled)
	_reward_controller.reward_claimed.connect(_on_reward_claimed)
	_reward_controller.reward_failed.connect(_on_reward_failed)
	_last_health = player.health
	_last_shield = player.shield
	debug_hud.add_event("Lantern Lily produces +1 Light every 5 seconds.")
	debug_hud.add_event("Pulse when Saintmoth has 2 Light to gain Shield.")
	debug_hud.add_event("Clear rooms, choose rewards, then pick adjacent expedition rooms.")
	_room_controller.start(_expedition_map.get_current_room_id())
	_refresh_debug()


func _process(delta: float) -> void:
	GardenTickSystem.process_intervals(delta)
	_room_controller.process(delta)
	_refresh_debug()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()
		return
	if _reward_controller.handle_placement_input(event):
		get_viewport().set_input_as_handled()
		_refresh_debug()
		return
	if _handle_garden_inspect_input(event):
		get_viewport().set_input_as_handled()
		_refresh_debug()
		return
	if _handle_expedition_input(event):
		get_viewport().set_input_as_handled()
		_refresh_debug()


func _on_piece_triggered(_cell: Vector2i, piece_id: String, _trigger: Dictionary) -> void:
	JournalManager.discover_piece(piece_id)
	var action := str(_trigger.get("action", ""))
	if piece_id == "lantern_lily":
		debug_hud.add_event("Lantern Lily produced +1 Light.")
	elif piece_id == "bellflower":
		debug_hud.add_event("Bellflower heard the garden wake and produced +1 Echo.")
	elif piece_id == "blood_rose":
		debug_hud.add_event("Blood Rose drank danger and produced +1 Blood.")
	elif piece_id == "gravecap":
		debug_hud.add_event("Gravecap grew from a nearby death and produced +1 Rot.")
	elif piece_id == "grave_bell" and action == "store_resource":
		debug_hud.add_event("Grave Bell stored Echo.")
	elif piece_id == "grave_bell" and action == "damage_nearby_enemies":
		debug_hud.add_event("Grave Bell rang and damaged an enemy.")
	elif piece_id == "mirror_shard":
		debug_hud.add_event("Mirror Shard copied the opposite tile.")
	elif piece_id == "bone_trellis":
		debug_hud.add_event("Bone Trellis connected adjacent Flora.")
	elif piece_id == "tiny_fence":
		debug_hud.add_event("Tiny Fence protected nearby living pieces.")
	_refresh_debug()


func _on_piece_placed(cell: Vector2i, piece_id: String) -> void:
	JournalManager.discover_piece(piece_id)
	if piece_id != "saintmoth":
		debug_hud.add_event("%s placed at garden cell %s,%s." % [_get_piece_name(piece_id), cell.x, cell.y])
	_refresh_debug()


func _on_reward_claimed(piece_id: String, _cell: Vector2i) -> void:
	garden_grid_panel.set_placement_preview(false)
	_room_controller.mark_reward_claimed()
	debug_hud.set_status("Reward placed: %s" % _get_piece_name(piece_id))
	RunManager.complete_current_room()
	_expedition_map.complete_current_room()
	debug_hud.add_event("Room cleared. Choose an adjacent expedition room.")
	_refresh_debug()


func _on_reward_failed(piece_id: String, reason: String) -> void:
	if piece_id.is_empty():
		debug_hud.add_event(reason)
		_refresh_debug()
		return
	debug_hud.add_event("%s for %s." % [reason, _get_piece_name(piece_id)])
	_refresh_debug()


func _on_reward_placement_started(piece_id: String, cell: Vector2i) -> void:
	garden_grid_panel.set_placement_preview(true, piece_id, cell)
	debug_hud.set_status(_get_placement_status(piece_id, cell))
	debug_hud.add_event("Choose a garden cell for %s." % _get_piece_name(piece_id))
	_refresh_debug()


func _on_reward_placement_cursor_changed(piece_id: String, cell: Vector2i) -> void:
	garden_grid_panel.set_placement_preview(true, piece_id, cell)
	debug_hud.set_status(_get_placement_status(piece_id, cell))
	_refresh_debug()


func _on_reward_placement_cancelled(piece_id: String) -> void:
	garden_grid_panel.set_placement_preview(false)
	debug_hud.set_status("Choose a reward")
	debug_hud.add_event("Placement cancelled for %s." % _get_piece_name(piece_id))
	_refresh_debug()


func _on_player_shield_changed(shield: int) -> void:
	var delta := shield - _last_shield
	if delta > 0:
		debug_hud.add_event("Saintmoth granted +%s Shield." % delta)
		prototype_feedback.play_shield()
	elif delta < 0:
		debug_hud.add_event("Shield absorbed %s damage." % abs(delta))
	_last_shield = shield
	_refresh_debug()


func _on_player_health_changed(health: int, _max_health: int) -> void:
	var damage := _last_health - health
	if damage > 0:
		debug_hud.add_event("Drifter hit player for %s damage." % damage)
	_last_health = health
	_refresh_debug()


func _on_player_damaged_event(amount: int, source: Dictionary) -> void:
	GardenTriggerSystem.trigger_global_event("player_damaged_or_close_kill", {
		"damage": amount,
		"source": source
	})
	_refresh_debug()


func _on_enemy_damaged(enemy_id: String, amount: int, _source: Dictionary) -> void:
	debug_hud.add_event("%s took %s garden damage." % [enemy_id.capitalize(), amount])
	prototype_feedback.play_enemy_hit()
	_refresh_debug()


func _on_enemy_defeated(enemy_id: String, world_position: Vector2, source: Dictionary) -> void:
	debug_hud.add_event("%s fell. Death-fed Flora wake." % enemy_id.capitalize())
	_room_controller.record_enemy_defeated()
	var context := {
		"enemy_id": enemy_id,
		"world_position": world_position,
		"source": source
	}
	GardenTriggerSystem.trigger_global_event("enemy_died", context)
	GardenTriggerSystem.trigger_global_event("enemy_died_nearby", context)
	GardenTriggerSystem.trigger_global_event("player_damaged_or_close_kill", context)
	_refresh_debug()


func _on_helper_spawn_requested(helper_id: String, amount: int, _source: Dictionary) -> void:
	debug_hud.add_event("Rotling requested %s %s helper." % [amount, helper_id])
	_refresh_debug()


func _on_resource_changed(_resource_id: String, _amount: int, _delta: int) -> void:
	_refresh_debug()


func _on_resource_spent(resource_id: String, amount: int) -> void:
	if resource_id == "light":
		debug_hud.add_event("Saintmoth consumed %s Light." % amount)
	_refresh_debug()


func _on_resource_failed(resource_id: String, requested: int, _available: int) -> void:
	if resource_id == "light":
		debug_hud.add_event("Saintmoth needs %s Light." % requested)
	_refresh_debug()


func _on_player_defeated() -> void:
	_room_controller.stop()
	debug_hud.set_status("Player defeated - restart the scene to try again")
	RunManager.finish_run(false)
	_refresh_debug()


func _on_bloomchain_finished(length: int, piece_ids: Array[String]) -> void:
	if length < 3:
		return
	var bloomchain := " -> ".join(PackedStringArray(_get_piece_names(piece_ids)))
	debug_hud.set_last_bloomchain(bloomchain)
	debug_hud.add_event("Bloomchain finalized x%s: %s" % [length, bloomchain])
	debug_hud.set_status("Bloomchain finalized")
	prototype_feedback.play_bloomchain()
	_refresh_debug()


func _on_room_started(room_id: String) -> void:
	_spawn_drifter_for_room()
	debug_hud.add_event("Room started: %s." % room_id)
	_refresh_debug()


func _on_room_reward_ready(room_id: String) -> void:
	debug_hud.set_status("Room survived - choose a reward")
	debug_hud.add_event("%s survived. Choose one reward with 1, 2, or 3, then place it." % room_id.capitalize())
	prototype_feedback.play_room_complete()
	_reward_controller.show_rewards_for_room(room_id)
	_refresh_debug()


func _refresh_debug() -> void:
	var room_id := _expedition_map.get_current_room_id()
	debug_hud.set_room_info(room_id, _expedition_map.get_completed_room_count(), _room_controller.get_objective_text())
	debug_hud.refresh()
	garden_grid_panel.refresh()
	if _is_inspecting_garden:
		garden_inspect_panel.set_inspected_cell(GardenManager.selected_cell)
		garden_inspect_panel.refresh()
	expedition_map_panel.set_rooms(_expedition_map.get_room_snapshot())


func _get_piece_name(piece_id: String) -> String:
	var piece := ContentDatabase.get_garden_piece(piece_id)
	return piece.get("name", piece_id)


func _get_piece_names(piece_ids: Array[String]) -> Array[String]:
	var names: Array[String] = []
	for piece_id in piece_ids:
		names.append(_get_piece_name(piece_id))
	return names


func _get_placement_status(piece_id: String, cell: Vector2i) -> String:
	var status := "Place %s with Arrows, Enter/E confirm, Esc cancel" % _get_piece_name(piece_id)
	var synergy_names := _get_adjacent_synergy_names(piece_id, cell)
	if not synergy_names.is_empty():
		status += " | Works with: %s" % ", ".join(PackedStringArray(synergy_names))
	return status


func _get_adjacent_synergy_names(piece_id: String, cell: Vector2i) -> Array[String]:
	var piece := ContentDatabase.get_garden_piece(piece_id)
	var names: Array[String] = []
	for neighbor in GardenManager.get_adjacent_piece_cells(cell):
		var neighbor_id := GardenManager.get_piece_id_at(neighbor)
		var neighbor_piece := ContentDatabase.get_garden_piece(neighbor_id)
		var neighbor_category := str(neighbor_piece.get("category", ""))
		for like in piece.get("likes", []):
			var like_id := str(like)
			if like_id == neighbor_id or like_id == neighbor_category or neighbor_piece.get("tags", []).has(like_id):
				names.append(_get_piece_name(neighbor_id))
				break
	return names


func _handle_expedition_input(event: InputEvent) -> bool:
	if _is_inspecting_garden or _room_controller.is_active or _room_controller.is_reward_ready or _reward_controller.is_reward_available:
		return false
	if (event is InputEventKey) == false or not event.is_pressed() or event.echo:
		return false
	match event.keycode:
		KEY_LEFT:
			return _expedition_map.move_selection(Vector2i.LEFT)
		KEY_RIGHT:
			return _expedition_map.move_selection(Vector2i.RIGHT)
		KEY_UP:
			return _expedition_map.move_selection(Vector2i.UP)
		KEY_DOWN:
			return _expedition_map.move_selection(Vector2i.DOWN)
		KEY_ENTER, KEY_KP_ENTER, KEY_E:
			return _expedition_map.confirm_selection()
	return false


func _handle_garden_inspect_input(event: InputEvent) -> bool:
	if (event is InputEventKey) == false or not event.is_pressed() or event.echo:
		return false
	if event.keycode == KEY_I:
		if _room_controller.is_active or _room_controller.is_reward_ready or _reward_controller.is_reward_available:
			debug_hud.add_event("Garden inspect opens after a reward is claimed.")
			return true
		_set_garden_inspect_mode(not _is_inspecting_garden)
		return true
	if not _is_inspecting_garden:
		return false
	match event.keycode:
		KEY_LEFT:
			return GardenManager.move_selected_cell(Vector2i.LEFT)
		KEY_RIGHT:
			return GardenManager.move_selected_cell(Vector2i.RIGHT)
		KEY_UP:
			return GardenManager.move_selected_cell(Vector2i.UP)
		KEY_DOWN:
			return GardenManager.move_selected_cell(Vector2i.DOWN)
		KEY_ESCAPE:
			_set_garden_inspect_mode(false)
			return true
	return false


func _set_garden_inspect_mode(enabled: bool) -> void:
	_is_inspecting_garden = enabled
	garden_inspect_panel.visible = enabled
	if enabled:
		garden_inspect_panel.set_inspected_cell(GardenManager.selected_cell)
		debug_hud.set_status("Garden inspect: Arrows select cells, Esc closes")
	else:
		debug_hud.set_status("Choose an adjacent expedition room")


func _on_expedition_map_changed() -> void:
	_refresh_debug()


func _on_expedition_room_selected(room_id: String, _position: Vector2i) -> void:
	debug_hud.set_status("Entered expedition room: %s" % room_id)
	debug_hud.add_event("Entered %s." % room_id.capitalize())
	_room_controller.start(room_id)
	_refresh_debug()


func _on_expedition_selection_failed(reason: String) -> void:
	debug_hud.add_event(reason)
	_refresh_debug()


func _on_run_finished(summary: Dictionary) -> void:
	run_summary_panel.show_summary(summary)
	debug_hud.set_status("Run finished")
	_refresh_debug()


func _spawn_drifter_for_room() -> void:
	if is_instance_valid(_active_drifter):
		_active_drifter.queue_free()
	var drifter := DrifterScene.instantiate()
	drifter.name = "Drifter"
	drifter.position = DRIFTER_SPAWN_POSITION
	drifter.player_path = NodePath("../Player")
	add_child(drifter)
	_active_drifter = drifter
