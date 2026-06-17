extends PanelContainer

@onready var label: Label = $MarginContainer/VBoxContainer/SummaryLabel


func _ready() -> void:
	hide()


func show_summary(summary: Dictionary) -> void:
	var lines: Array[String] = [
		"Run Summary",
		"Result: %s" % ("Success" if bool(summary.get("success", false)) else "Failed"),
		"Rooms cleared: %s" % summary.get("rooms_completed", 0),
		"Largest Bloomchain: %s" % summary.get("largest_chain", 0),
		"Resources: %s" % summary.get("resources", {}),
		"",
		"Press R to restart"
	]
	label.text = "\n".join(PackedStringArray(lines))
	show()
