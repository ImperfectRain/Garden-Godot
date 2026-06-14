extends Node

signal resource_changed(resource_id: String, amount: int, delta: int)
signal resource_spent(resource_id: String, amount: int)
signal resource_failed(resource_id: String, requested: int, available: int)

var _amounts: Dictionary = {}
var _caps: Dictionary = {
	"light": 99,
	"rot": 99,
	"blood": 99,
	"echo": 99
}


func reset() -> void:
	_amounts.clear()
	for resource_id in _caps.keys():
		_amounts[resource_id] = 0
		resource_changed.emit(resource_id, 0, 0)


func get_amount(resource_id: String) -> int:
	return int(_amounts.get(resource_id, 0))


func get_all() -> Dictionary:
	return _amounts.duplicate()


func add(resource_id: String, amount: int) -> int:
	if amount <= 0:
		return get_amount(resource_id)
	var current := get_amount(resource_id)
	var cap := int(_caps.get(resource_id, 99))
	var next_amount = min(current + amount, cap)
	_amounts[resource_id] = next_amount
	resource_changed.emit(resource_id, next_amount, next_amount - current)
	return next_amount


func can_spend(resource_id: String, amount: int) -> bool:
	return get_amount(resource_id) >= amount


func spend(resource_id: String, amount: int) -> bool:
	var current := get_amount(resource_id)
	if current < amount:
		resource_failed.emit(resource_id, amount, current)
		return false
	_amounts[resource_id] = current - amount
	resource_spent.emit(resource_id, amount)
	resource_changed.emit(resource_id, current - amount, -amount)
	return true


func set_cap(resource_id: String, cap: int) -> void:
	_caps[resource_id] = max(cap, 0)
	if get_amount(resource_id) > cap:
		_amounts[resource_id] = cap
		resource_changed.emit(resource_id, cap, 0)
