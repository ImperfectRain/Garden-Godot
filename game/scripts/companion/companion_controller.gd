extends Node2D

signal mood_changed(mood: String)
signal shield_requested(amount: int)

@export var follow_distance := 34.0
@export var follow_speed := 7.0
@export var player_path: NodePath

var mood := "idle"
var bond_points := 0
var _player: Node2D


func _ready() -> void:
	if not str(player_path).is_empty():
		_player = get_node_or_null(player_path)
	GardenManager.piece_triggered.connect(_on_garden_piece_triggered)


func _process(delta: float) -> void:
	if _player == null:
		return
	var target_position := _player.global_position + Vector2(-follow_distance, -follow_distance * 0.35)
	global_position = global_position.lerp(target_position, min(delta * follow_speed, 1.0))


func set_mood(next_mood: String) -> void:
	if mood == next_mood:
		return
	mood = next_mood
	mood_changed.emit(mood)


func add_bond(points: int) -> void:
	bond_points = max(bond_points + points, 0)


func _on_garden_piece_triggered(_cell: Vector2i, piece_id: String, trigger: Dictionary) -> void:
	if piece_id != "saintmoth":
		return
	if trigger.get("action", "") == "grant_player_shield":
		# GardenManager only emits this trigger after Saintmoth's Light cost is paid.
		set_mood("happy")
		shield_requested.emit(int(trigger.get("amount", 20)))
