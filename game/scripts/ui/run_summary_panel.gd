extends PanelContainer

@onready var label: Label = $MarginContainer/VBoxContainer/SummaryLabel


func _ready() -> void:
	hide()


func show_summary(summary: Dictionary) -> void:
	var success := bool(summary.get("success", false))
	var garden_goal_met := bool(summary.get("garden_goal_met", false))
	var required_chain := int(summary.get("required_chain", 3))
	var largest_chain := int(summary.get("largest_chain", 0))
	var rooms_completed := int(summary.get("rooms_completed", 0))
	var rooms_planned := int(summary.get("rooms_planned", rooms_completed))
	var result_text := _get_result_text(success, garden_goal_met, rooms_completed, rooms_planned)
	var lines: Array[String] = [
		"Run Summary",
		"",
		"Result: %s" % result_text,
		"Rooms cleared: %s / %s" % [rooms_completed, rooms_planned],
		"Garden proof: %s" % ("Complete" if garden_goal_met else "Missing"),
		"Largest Bloomchain: %s / %s" % [largest_chain, required_chain],
		"Resources: %s" % summary.get("resources", {}),
		"",
		"Demo goal: create a Bloomchain of 3+.",
		"Press R to restart"
	]
	label.text = "\n".join(PackedStringArray(lines))
	show()


func _get_result_text(success: bool, garden_goal_met: bool, rooms_completed: int, rooms_planned: int) -> String:
	if success:
		return "Success"
	if rooms_completed >= rooms_planned and not garden_goal_met:
		return "Garden proof incomplete"
	return "Failed"
