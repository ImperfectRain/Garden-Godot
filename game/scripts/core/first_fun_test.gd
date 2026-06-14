extends Node2D

@onready var player := $Player
@onready var saintmoth := $Saintmoth
@onready var debug_label := $CanvasLayer/DebugLabel

var _produce_timer := 0.0


func _ready() -> void:
	RunManager.start_run()
	GardenManager.place_piece(Vector2i(0, 1), "lantern_lily")
	saintmoth.shield_requested.connect(player.add_shield)
	player.shield_changed.connect(_on_player_shield_changed)
	GardenResources.resource_changed.connect(_refresh_debug)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	_refresh_debug("", 0, 0)


func _process(delta: float) -> void:
	_produce_timer += delta
	if _produce_timer >= 5.0:
		_produce_timer = 0.0
		GardenManager.trigger_piece(Vector2i(0, 1), "on_interval")


func _on_piece_triggered(_cell: Vector2i, piece_id: String, _trigger: Dictionary) -> void:
	JournalManager.discover_piece(piece_id)
	_refresh_debug("", 0, 0)


func _on_player_shield_changed(_shield: int) -> void:
	_refresh_debug("", 0, 0)


func _refresh_debug(_resource_id: String, _amount: int, _delta: int) -> void:
	var lines: Array[String] = [
		"Garden of Teeth - First Fun Test",
		"WASD move | Space pulse Saintmoth",
		"Resources: %s" % GardenResources.get_all(),
		"Shield: %s" % player.shield,
		"Garden:"
	]
	lines.append_array(GardenManager.as_debug_rows())
	debug_label.text = "\n".join(PackedStringArray(lines))
