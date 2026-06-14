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
	var result := {
		"success": false,
		"action": str(request.get("action", "")),
		"reason": "No actions implemented yet"
	}
	effect_failed.emit(request, result["reason"])
	return result
