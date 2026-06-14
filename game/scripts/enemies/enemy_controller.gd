extends CharacterBody2D

signal defeated(enemy_id: String, world_position: Vector2)

@export var enemy_id := "drifter"
@export var target_path: NodePath

var health := 1
var speed := 60.0
var damage := 1
var _target: Node2D


func _ready() -> void:
	var data := ContentDatabase.get_enemy(enemy_id)
	health = int(data.get("health", health))
	speed = float(data.get("speed", speed))
	damage = int(data.get("damage", damage))
	if not str(target_path).is_empty():
		_target = get_node_or_null(target_path)


func _physics_process(_delta: float) -> void:
	if _target == null:
		velocity = Vector2.ZERO
	else:
		velocity = global_position.direction_to(_target.global_position) * speed
	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		defeated.emit(enemy_id, global_position)
		queue_free()
