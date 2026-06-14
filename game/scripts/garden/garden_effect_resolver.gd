extends Node

signal effect_resolved(result: Dictionary)
signal effect_failed(request: Dictionary, reason: String)

# Intended request shape:
# {
#   "action": "produce_resource",
#   "cell": Vector2i,
#   "piece_id": "lantern_lily",
#   "trigger": {},
#   "context": {}
# }
#
# Intended result shape:
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


func _resolve_produce_resource(request: Dictionary) -> Dictionary:
	var trigger: Dictionary = request.get("trigger", {})
	var resource_id := str(trigger.get("resource", request.get("resource", "")))
	var amount := int(trigger.get("amount", request.get("amount", 1)))
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
