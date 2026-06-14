extends Node2D

@onready var player := $Player
@onready var saintmoth := $Saintmoth
@onready var debug_label := $CanvasLayer/DebugLabel

var debug_message := "Drifter pressure active"


func _ready() -> void:
	RunManager.start_run()
	GardenManager.place_piece(Vector2i(0, 1), "lantern_lily")
	# Temporary first-fun-test wiring: Saintmoth requests shield, player applies it.
	saintmoth.shield_requested.connect(player.add_shield)
	player.health_changed.connect(_on_player_health_changed)
	player.shield_changed.connect(_on_player_shield_changed)
	player.player_defeated.connect(_on_player_defeated)
	GardenResources.resource_changed.connect(_refresh_debug)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	_refresh_debug("", 0, 0)


func _process(delta: float) -> void:
	GardenManager.process_intervals(delta)


func _on_piece_triggered(_cell: Vector2i, piece_id: String, _trigger: Dictionary) -> void:
	JournalManager.discover_piece(piece_id)
	_refresh_debug("", 0, 0)


func _on_player_shield_changed(_shield: int) -> void:
	_refresh_debug("", 0, 0)


func _on_player_health_changed(_health: int, _max_health: int) -> void:
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
	debug_label.text = "\n".join(PackedStringArray(lines))
