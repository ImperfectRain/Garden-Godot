extends Control

const SHIELD_SFX := preload("res://game/audio/sfx/prototype_shield.wav")
const BLOOM_SFX := preload("res://game/audio/sfx/prototype_bloom.wav")
const HIT_SFX := preload("res://game/audio/sfx/prototype_hit.wav")
const ROOM_SFX := preload("res://game/audio/sfx/prototype_room.wav")

@onready var flash_rect: ColorRect = $FlashRect
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var _flash_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1, 1, 1, 0)


func play_shield() -> void:
	_play(SHIELD_SFX)
	_flash(Color(0.45, 0.85, 1.0, 0.22), 0.18)


func play_bloomchain() -> void:
	_play(BLOOM_SFX)
	_flash(Color(0.85, 1.0, 0.45, 0.24), 0.22)


func play_enemy_hit() -> void:
	_play(HIT_SFX)
	_flash(Color(1.0, 0.45, 0.35, 0.18), 0.12)


func play_room_complete() -> void:
	_play(ROOM_SFX)
	_flash(Color(1.0, 0.82, 0.36, 0.24), 0.24)


func _play(stream: AudioStream) -> void:
	if audio_player == null:
		return
	audio_player.stream = stream
	audio_player.play()


func _flash(color: Color, duration: float) -> void:
	if flash_rect == null:
		return
	if _flash_tween != null:
		_flash_tween.kill()
	flash_rect.color = color
	_flash_tween = create_tween()
	_flash_tween.tween_property(flash_rect, "color", Color(color.r, color.g, color.b, 0), duration)
