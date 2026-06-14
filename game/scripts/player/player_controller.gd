extends CharacterBody2D

signal health_changed(health: int, max_health: int)
signal shield_changed(shield: int)
signal player_defeated

@export var move_speed := 160.0
@export var max_health := 6
@export var pickup_radius := 48.0

var health := max_health
var shield := 0


func _ready() -> void:
	health = max_health
	CombatEvents.player_shield_requested.connect(_on_player_shield_requested)
	health_changed.emit(health, max_health)
	shield_changed.emit(shield)


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pulse"):
		GardenManager.selected_cell = GardenManager.HEART_CELL
		GardenManager.pulse_selected()


func add_shield(amount: int) -> void:
	shield = max(shield + amount, 0)
	shield_changed.emit(shield)


func _on_player_shield_requested(amount: int, _source: Dictionary) -> void:
	add_shield(amount)


func take_damage(amount: int) -> void:
	var remaining := amount
	if shield > 0:
		var absorbed = min(shield, remaining)
		shield -= absorbed
		remaining -= absorbed
		shield_changed.emit(shield)
	if remaining > 0:
		health = max(health - remaining, 0)
		health_changed.emit(health, max_health)
		if health == 0:
			player_defeated.emit()
