extends CharacterBody2D

@export var move_speed := 70.0
@export var contact_damage := 1
@export var damage_cooldown := 1.0
@export var contact_range := 22.0
@export var max_health := 18
@export var enemy_id := "drifter"
@export var player_path: NodePath

var health := max_health
var _player: Node2D
var _damage_timer := 0.0


func _ready() -> void:
	health = max_health
	EnemyRegistry.register_enemy(self)
	if not str(player_path).is_empty():
		_player = get_node_or_null(player_path)


func _exit_tree() -> void:
	EnemyRegistry.unregister_enemy(self)


func _physics_process(delta: float) -> void:
	_damage_timer = max(_damage_timer - delta, 0.0)
	if _player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_chase_player()
	move_and_slide()
	_try_contact_damage()


func _chase_player() -> void:
	var to_player := _player.global_position - global_position
	if to_player.length() <= 1.0:
		velocity = Vector2.ZERO
		return
	velocity = to_player.normalized() * move_speed


func _try_contact_damage() -> void:
	if _damage_timer > 0.0:
		return
	if global_position.distance_to(_player.global_position) > contact_range:
		return
	if not _player.has_method("take_damage"):
		return
	_player.take_damage(contact_damage)
	_damage_timer = damage_cooldown


func take_damage(amount: int, source: Dictionary = {}) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	CombatEvents.enemy_damaged.emit(enemy_id, amount, source)
	if health == 0:
		CombatEvents.enemy_defeated.emit(enemy_id, global_position, source)
		queue_free()
