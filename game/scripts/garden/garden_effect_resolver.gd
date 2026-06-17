extends Node

signal effect_resolved(result: Dictionary)
signal effect_failed(request: Dictionary, reason: String)

var _stored_resources: Dictionary = {}

# Intended effect request shape:
# {
#   "action": "produce_resource",
#   "cell": Vector2i,
#   "piece_id": "lantern_lily",
#   "trigger": {},
#   "context": {}
# }
#
# Intended effect result shape:
# {
#   "success": true,
#   "action": "produce_resource",
#   "cell": Vector2i,
#   "piece_id": "lantern_lily",
#   "outputs": [],
#   "context": {}
# }
func resolve_effect(request: Dictionary) -> Dictionary:
	var action := str(request.get("action", ""))
	var result := {}
	match action:
		"produce_resource":
			result = _resolve_produce_resource(request)
		"grant_player_shield":
			result = _resolve_grant_player_shield(request)
		"consume_resource":
			result = _resolve_consume_resource(request)
		"store_resource":
			result = _resolve_store_resource(request)
		"damage_enemy", "damage_nearby_enemies":
			result = _resolve_enemy_damage(request)
		"spawn_helper":
			result = _resolve_spawn_helper(request)
		"repeat_last_trigger":
			result = _resolve_repeat_last_trigger(request)
		"move_resource":
			result = _resolve_move_resource(request)
		"copy_output":
			result = _resolve_copy_output(request)
		"modify_production":
			result = _resolve_modify_production(request)
		"protect_adjacent_living":
			result = _resolve_marker_effect(request, "protect_adjacent_living")
		"connect_adjacent_flora":
			result = _resolve_marker_effect(request, "connect_adjacent_flora")
		_:
			result = {
				"success": false,
				"action": action,
				"reason": "No actions implemented yet"
			}
	if bool(result.get("success", false)):
		effect_resolved.emit(result)
	else:
		effect_failed.emit(request, str(result.get("reason", "Effect failed")))
	return result


func reset() -> void:
	_stored_resources.clear()


func get_stored_amount(cell: Vector2i, piece_id: String, resource_id: String) -> int:
	return int(_stored_resources.get(_get_storage_key(cell, piece_id, resource_id), 0))


func clear_stored_amount(cell: Vector2i, piece_id: String, resource_id: String) -> void:
	_stored_resources.erase(_get_storage_key(cell, piece_id, resource_id))


func _resolve_produce_resource(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var amount := int(trigger.get("amount", request.get("amount", 1)))
	amount += GardenManager.get_production_bonus_for_cell(request.get("cell", Vector2i(-1, -1)))
	var result := {
		"success": false,
		"action": "produce_resource",
		"resource": resource_id,
		"amount": amount,
		"cell": request.get("cell", Vector2i(-1, -1)),
		"piece_id": str(request.get("piece_id", "")),
		"trigger": trigger,
		"outputs": [],
		"context": request.get("context", {})
	}
	if resource_id.is_empty():
		result["reason"] = "Missing resource id"
		return result
	if amount <= 0:
		result["reason"] = "Amount must be positive"
		return result
	GardenResources.add(resource_id, amount)
	result["success"] = true
	result["outputs"] = [
		{
			"type": "resource",
			"resource": resource_id,
			"amount": amount
		}
	]
	return result


func _resolve_consume_resource(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var amount := int(trigger.get("cost", trigger.get("amount", request.get("amount", 0))))
	var result := _make_base_result(request, "consume_resource")
	result["resource"] = resource_id
	result["amount"] = amount
	if resource_id.is_empty():
		result["reason"] = "Missing resource id"
		return result
	if amount <= 0:
		result["reason"] = "Amount must be positive"
		return result
	if not GardenResources.spend(resource_id, amount):
		result["reason"] = "Not enough resource"
		return result
	result["success"] = true
	result["outputs"] = [
		{
			"type": "resource_consumed",
			"resource": resource_id,
			"amount": amount
		}
	]
	return result


func _resolve_store_resource(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var cell: Vector2i = request.get("cell", Vector2i(-1, -1))
	var piece_id := str(request.get("piece_id", ""))
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var amount := int(trigger.get("amount", trigger.get("cost", request.get("amount", 1))))
	var capacity := int(trigger.get("capacity", trigger.get("threshold", 0)))
	var result := _make_base_result(request, "store_resource")
	result["resource"] = resource_id
	result["amount"] = amount
	result["capacity"] = capacity
	result["threshold"] = capacity
	if resource_id.is_empty():
		result["reason"] = "Missing resource id"
		return result
	if amount <= 0:
		result["reason"] = "Amount must be positive"
		return result
	if not GardenResources.spend(resource_id, amount):
		result["reason"] = "Not enough resource"
		return result
	var key := _get_storage_key(cell, piece_id, resource_id)
	var stored := int(_stored_resources.get(key, 0)) + amount
	if capacity > 0:
		stored = mini(stored, capacity)
	_stored_resources[key] = stored
	result["stored"] = stored
	result["success"] = true
	result["outputs"] = [
		{
			"type": "resource_stored",
			"resource": resource_id,
			"amount": amount,
			"stored": stored,
			"capacity": capacity
		}
	]
	return result


func _resolve_grant_player_shield(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var context: Dictionary = request.get("context", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var cost := int(trigger.get("cost", request.get("cost", 0)))
	var amount := int(trigger.get("amount", request.get("amount", 0)))
	var source := {
		"piece_id": str(request.get("piece_id", "")),
		"cell": request.get("cell", Vector2i(-1, -1)),
		"trigger": trigger.duplicate(true),
		"context": context.duplicate(true)
	}
	var result := {
		"success": false,
		"action": "grant_player_shield",
		"resource": resource_id,
		"cost": cost,
		"amount": amount,
		"cell": request.get("cell", Vector2i(-1, -1)),
		"piece_id": str(request.get("piece_id", "")),
		"trigger": trigger,
		"outputs": [],
		"context": context,
		"source": source
	}
	if resource_id.is_empty():
		result["reason"] = "Missing resource id"
		return result
	if cost <= 0:
		result["reason"] = "Cost must be positive"
		return result
	if amount <= 0:
		result["reason"] = "Shield amount must be positive"
		return result
	if not GardenResources.spend(resource_id, cost):
		result["reason"] = "Not enough resource"
		return result
	CombatEvents.player_shield_requested.emit(amount, source)
	result["success"] = true
	result["outputs"] = [
		{
			"type": "player_shield",
			"amount": amount
		}
	]
	return result


func _resolve_enemy_damage(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var amount := int(trigger.get("amount", request.get("amount", 0)))
	var result := _make_base_result(request, str(request.get("action", "damage_enemy")))
	if amount <= 0:
		result["reason"] = "Damage amount must be positive"
		return result
	var source := _make_source(request)
	CombatEvents.enemy_damage_requested.emit(amount, source)
	result["success"] = true
	result["amount"] = amount
	result["outputs"] = [
		{
			"type": "enemy_damage",
			"amount": amount
		}
	]
	return result


func _resolve_spawn_helper(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var cost := int(trigger.get("cost", request.get("cost", 0)))
	var amount := int(trigger.get("amount", request.get("amount", 1)))
	var helper_id := str(trigger.get("helper_id", request.get("helper_id", "larva")))
	var result := _make_base_result(request, "spawn_helper")
	result["resource"] = resource_id
	result["cost"] = cost
	result["amount"] = amount
	result["helper_id"] = helper_id
	if amount <= 0:
		result["reason"] = "Helper amount must be positive"
		return result
	if not resource_id.is_empty() and cost > 0 and not GardenResources.spend(resource_id, cost):
		result["reason"] = "Not enough resource"
		return result
	CombatEvents.helper_spawn_requested.emit(helper_id, amount, _make_source(request))
	result["success"] = true
	result["outputs"] = [
		{
			"type": "helper_spawn",
			"helper_id": helper_id,
			"amount": amount
		}
	]
	return result


func _resolve_repeat_last_trigger(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var cost := int(trigger.get("cost", request.get("cost", 0)))
	var scalar := float(trigger.get("scalar", request.get("scalar", 1.0)))
	var result := _make_base_result(request, "repeat_last_trigger")
	result["resource"] = resource_id
	result["cost"] = cost
	result["scalar"] = scalar
	if scalar <= 0.0:
		result["reason"] = "Repeat scalar must be positive"
		return result
	if not resource_id.is_empty() and cost > 0 and not GardenResources.spend(resource_id, cost):
		result["reason"] = "Not enough resource"
		return result
	result["success"] = true
	result["outputs"] = [
		{
			"type": "repeat_last_trigger",
			"scalar": scalar
		}
	]
	return result


func _resolve_move_resource(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var context: Dictionary = request.get("context", {})
	var resource_id := str(trigger.get("resource", request.get("resource", context.get("resource", ""))))
	var amount := int(trigger.get("amount", request.get("amount", 1)))
	var carrier_cell: Vector2i = request.get("cell", Vector2i(-1, -1))
	var origin_cell: Vector2i = context.get("origin_cell", Vector2i(-1, -1))
	var target_cell := _find_adjacent_resource_target(carrier_cell, origin_cell, resource_id)
	var result := _make_base_result(request, "move_resource")
	result["resource"] = resource_id
	result["amount"] = amount
	result["origin_cell"] = origin_cell
	result["target_cell"] = target_cell
	if resource_id.is_empty():
		result["reason"] = "Missing resource id"
		return result
	if amount <= 0:
		result["reason"] = "Amount must be positive"
		return result
	if not GardenManager.are_cells_adjacent(carrier_cell, origin_cell):
		result["reason"] = "Resource source is not adjacent"
		return result
	if target_cell == Vector2i(-1, -1):
		result["reason"] = "No adjacent resource target"
		return result
	result["success"] = true
	result["outputs"] = [
		{
			"type": "resource_moved",
			"resource": resource_id,
			"amount": amount,
			"origin_cell": origin_cell,
			"target_cell": target_cell
		}
	]
	return result


func _resolve_copy_output(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var context: Dictionary = request.get("context", {})
	var scalar := float(trigger.get("scalar", request.get("scalar", 1.0)))
	var result := _make_base_result(request, "copy_output")
	result["scalar"] = scalar
	if scalar <= 0.0:
		result["reason"] = "Copy scalar must be positive"
		return result
	var copied_resource := str(context.get("copied_resource", ""))
	var copied_amount := int(context.get("copied_amount", 0))
	if not copied_resource.is_empty() and copied_amount > 0:
		var copied_resource_amount := maxi(1, int(floor(float(copied_amount) * scalar)))
		GardenResources.add(copied_resource, copied_resource_amount)
		result["resource"] = copied_resource
		result["amount"] = copied_resource_amount
		result["success"] = true
		result["outputs"] = [
			{
				"type": "resource",
				"resource": copied_resource,
				"amount": copied_resource_amount
			}
		]
		return result
	var copied_damage := int(context.get("copied_enemy_damage", 0))
	if copied_damage > 0:
		var copied_damage_amount := maxi(1, int(floor(float(copied_damage) * scalar)))
		CombatEvents.enemy_damage_requested.emit(copied_damage_amount, _make_source(request))
		result["amount"] = copied_damage_amount
		result["success"] = true
		result["outputs"] = [
			{
				"type": "enemy_damage",
				"amount": copied_damage_amount
			}
		]
		return result
	result["success"] = false
	result["reason"] = "No copied output"
	return result


func _resolve_modify_production(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var bonus := int(trigger.get("production_bonus", request.get("production_bonus", 0)))
	var result := _make_base_result(request, "modify_production")
	result["production_bonus"] = bonus
	result["success"] = true
	result["outputs"] = [
		{
			"type": "production_modifier",
			"production_bonus": bonus
		}
	]
	return result


func _resolve_marker_effect(request: Dictionary, action: String) -> Dictionary:
	var result := _make_base_result(request, action)
	result["success"] = true
	result["outputs"] = [
		{
			"type": action
		}
	]
	return result


func _make_base_result(request: Dictionary, action: String) -> Dictionary:
	return {
		"success": false,
		"action": action,
		"cell": request.get("cell", Vector2i(-1, -1)),
		"piece_id": str(request.get("piece_id", "")),
		"trigger": request.get("trigger", {}),
		"outputs": [],
		"context": request.get("context", {})
	}


func _make_source(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var context: Dictionary = request.get("context", {})
	return {
		"piece_id": str(request.get("piece_id", "")),
		"cell": request.get("cell", Vector2i(-1, -1)),
		"trigger": trigger.duplicate(true),
		"context": context.duplicate(true)
	}


func _get_storage_key(cell: Vector2i, piece_id: String, resource_id: String) -> String:
	return "%s,%s:%s:%s" % [cell.x, cell.y, piece_id, resource_id]


func _find_adjacent_resource_target(carrier_cell: Vector2i, origin_cell: Vector2i, resource_id: String) -> Vector2i:
	for neighbor in GardenManager.get_adjacent_piece_cells(carrier_cell):
		if neighbor == origin_cell:
			continue
		if _piece_can_use_resource(GardenManager.get_piece_at(neighbor), resource_id):
			return neighbor
	return Vector2i(-1, -1)


func _piece_can_use_resource(piece: Dictionary, resource_id: String) -> bool:
	for consume in piece.get("consumes", []):
		if str(consume.get("resource", "")) == resource_id:
			return true
	for store in piece.get("stores", []):
		if str(store.get("resource", "")) == resource_id:
			return true
	for like in piece.get("likes", []):
		if str(like) == resource_id:
			return true
	return false
