extends Node2D

const SimpleRoomControllerScript := preload("res://game/scripts/core/simple_room_controller.gd")
const RewardControllerScript := preload("res://game/scripts/core/reward_controller.gd")

@onready var player := $Player
@onready var debug_hud := $CanvasLayer/DebugHUD
@onready var garden_grid_panel := $CanvasLayer/GardenGridPanel
@onready var reward_choice_panel := $CanvasLayer/RewardChoicePanel

var _last_health := 0
var _last_shield := 0
var _room_controller := SimpleRoomControllerScript.new()
var _reward_controller := RewardControllerScript.new()


func _ready() -> void:
	RunManager.start_run()
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
	debug_hud.add_event("Survive 30 seconds, then choose a garden reward.")
	_room_controller.start(RunManager.get_current_room_id())
	_refresh_debug()


func _process(delta: float) -> void:
	GardenTickSystem.process_intervals(delta)
	_room_controller.process(delta)
	_refresh_debug()


func _unhandled_input(event: InputEvent) -> void:
	if _reward_controller.handle_placement_input(event):
		get_viewport().set_input_as_handled()
		_refresh_debug()


func _on_piece_triggered(_cell: Vector2i, piece_id: String, _trigger: Dictionary) -> void:
	JournalManager.discover_piece(piece_id)
	if piece_id == "lantern_lily":
		debug_hud.add_event("Lantern Lily produced +1 Light.")
	elif piece_id == "bellflower":
		debug_hud.add_event("Bellflower heard the garden wake and produced +1 Echo.")
	elif piece_id == "blood_rose":
		debug_hud.add_event("Blood Rose drank danger and produced +1 Blood.")
	elif piece_id == "gravecap":
		debug_hud.add_event("Gravecap grew from a nearby death and produced +1 Rot.")
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
	debug_hud.add_event("Room complete. Advanced to %s." % RunManager.get_current_room_id())
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
	debug_hud.set_status("Place %s with Arrow keys, Enter/E confirm, Esc cancel" % _get_piece_name(piece_id))
	debug_hud.add_event("Choose a garden cell for %s." % _get_piece_name(piece_id))
	_refresh_debug()


func _on_reward_placement_cursor_changed(piece_id: String, cell: Vector2i) -> void:
	garden_grid_panel.set_placement_preview(true, piece_id, cell)
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
	_refresh_debug()


func _on_enemy_defeated(enemy_id: String, world_position: Vector2, source: Dictionary) -> void:
	debug_hud.add_event("%s fell. Death-fed Flora wake." % enemy_id.capitalize())
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
	_refresh_debug()


func _on_bloomchain_finished(length: int, piece_ids: Array[String]) -> void:
	if length < 3:
		return
	var bloomchain := " -> ".join(PackedStringArray(_get_piece_names(piece_ids)))
	debug_hud.set_last_bloomchain(bloomchain)
	debug_hud.add_event("Bloomchain finalized x%s: %s" % [length, bloomchain])
	debug_hud.set_status("Bloomchain finalized")
	_refresh_debug()


func _on_room_started(room_id: String) -> void:
	debug_hud.add_event("Room started: %s." % room_id)
	_refresh_debug()


func _on_room_reward_ready(room_id: String) -> void:
	debug_hud.set_status("Room survived - choose a reward")
	debug_hud.add_event("Meadow survived. Choose one reward with 1, 2, or 3, then place it.")
	_reward_controller.show_rewards_for_room(room_id)
	_refresh_debug()


func _refresh_debug() -> void:
	var room_id := RunManager.get_current_room_id()
	debug_hud.set_room_info(room_id, RunManager.get_completed_room_count(), _room_controller.get_objective_text())
	debug_hud.refresh()
	garden_grid_panel.refresh()


func _get_piece_name(piece_id: String) -> String:
	var piece := ContentDatabase.get_garden_piece(piece_id)
	return piece.get("name", piece_id)


func _get_piece_names(piece_ids: Array[String]) -> Array[String]:
	var names: Array[String] = []
	for piece_id in piece_ids:
		names.append(_get_piece_name(piece_id))
	return names
