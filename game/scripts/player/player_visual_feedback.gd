extends Node2D

@export var shield_radius := 24.0
@export var shield_width := 3.0
@export var shield_color := Color(0.55, 0.85, 1.0, 0.78)
@export var pulse_scale := 1.18
@export var pulse_duration := 0.16

var _last_shield := 0
var _pulse_tween: Tween


func _ready() -> void:
	visible = false
	var player := get_parent()
	if player != null and player.has_signal("shield_changed"):
		player.shield_changed.connect(_on_shield_changed)


func _draw() -> void:
	draw_arc(Vector2.ZERO, shield_radius, 0.0, TAU, 48, shield_color, shield_width, true)


func _on_shield_changed(shield: int) -> void:
	visible = shield > 0
	if shield > _last_shield:
		_play_shield_pulse()
	_last_shield = shield


func _play_shield_pulse() -> void:
	if _pulse_tween != null:
		_pulse_tween.kill()
	scale = Vector2.ONE * pulse_scale
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(self, "scale", Vector2.ONE, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
