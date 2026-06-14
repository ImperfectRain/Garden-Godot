extends Node2D

@onready var player := $Player
@onready var saintmoth := $Saintmoth
@onready var debug_label := $CanvasLayer/DebugLabel

const MAX_EVENT_LOG_LINES := 6

var debug_message := "Drifter pressure active"
var event_log: Array[String] = []
var _last_health := 0
var _last_shield := 0


func _ready() -> void:
	RunManager.start_run()
	GardenManager.place_piece(Vector2i(0, 1), "lantern_lily")
	# Temporary first-fun-test wiring: Saintmoth requests shield, player applies it.
	saintmoth.shield_requested.connect(player.add_shield)
	player.health_changed.connect(_on_player_health_changed)
	player.shield_changed.connect(_on_player_shield_changed)
	player.player_defeated.connect(_on_player_defeated)
	GardenResources.resource_changed.connect(_on_resource_changed)
	GardenResources.resource_spent.connect(_on_resource_spent)
	GardenResources.resource_failed.connect(_on_resource_failed)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	_last_health = player.health
	_last_shield = player.shield
	_add_event("Lantern Lily produces +1 Light every 5 seconds.")
	_add_event("Pulse when Saintmoth has 2 Light to gain Shield.")
	_refresh_debug("", 0, 0)


func _process(delta: float) -> void:
	GardenManager.process_intervals(delta)


func _on_piece_triggered(_cell: Vector2i, piece_id: String, _trigger: Dictionary) -> void:
	JournalManager.discover_piece(piece_id)
	if piece_id == "lantern_lily":
		_add_event("Lantern Lily produced +1 Light.")
	_refresh_debug("", 0, 0)


func _on_player_shield_changed(shield: int) -> void:
	var delta := shield - _last_shield
	if delta > 0:
		_add_event("Saintmoth granted +%s Shield." % delta)
	elif delta < 0:
		_add_event("Shield absorbed %s damage." % abs(delta))
	_last_shield = shield
	_refresh_debug("", 0, 0)


func _on_player_health_changed(health: int, _max_health: int) -> void:
	var damage := _last_health - health
	if damage > 0:
		_add_event("Drifter hit player for %s damage." % damage)
	_last_health = health
	_refresh_debug("", 0, 0)


func _on_resource_changed(_resource_id: String, _amount: int, _delta: int) -> void:
	_refresh_debug("", 0, 0)


func _on_resource_spent(resource_id: String, amount: int) -> void:
	if resource_id == "light":
		_add_event("Saintmoth consumed %s Light." % amount)
	_refresh_debug("", 0, 0)


func _on_resource_failed(resource_id: String, requested: int, _available: int) -> void:
	if resource_id == "light":
		_add_event("Saintmoth needs %s Light." % requested)
	_refresh_debug("", 0, 0)


func _on_player_defeated() -> void:
	debug_message = "Player defeated - restart the scene to try again"
	_refresh_debug("", 0, 0)


func _refresh_debug(_resource_id: String, _amount: int, _delta: int) -> void:
	var lines: Array[String] = [
		"Garden of Teeth - First Fun Test",
		"WASD move | Space pulse Saintmoth",
		"Interval ticking: GardenManager",
		"Enemy: Drifter slowly follows and deals contact damage",
		"Resources: %s" % GardenResources.get_all(),
		"Health: %s/%s" % [player.health, player.max_health],
		"Shield: %s" % player.shield,
		"Status: %s" % debug_message,
		"Garden:"
	]
	lines.append_array(GardenManager.as_debug_rows())
	lines.append("Event Log:")
	lines.append_array(event_log)
	debug_label.text = "\n".join(PackedStringArray(lines))


func _add_event(message: String) -> void:
	event_log.append(message)
	while event_log.size() > MAX_EVENT_LOG_LINES:
		event_log.pop_front()
