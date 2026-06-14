extends PanelContainer

signal reward_selected(piece_id: String)

@export var reward_piece_ids: Array[String] = ["gravecap", "bellflower", "grave_bell"]

@onready var choices_box := $MarginContainer/VBoxContainer/Choices


func _ready() -> void:
	_build_choices()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or (event is InputEventKey) == false or not event.is_pressed():
		return
	match event.keycode:
		KEY_1:
			_select_index(0)
		KEY_2:
			_select_index(1)
		KEY_3:
			_select_index(2)


func _build_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()
	for index in range(reward_piece_ids.size()):
		var piece_id := reward_piece_ids[index]
		var piece := ContentDatabase.get_garden_piece(piece_id)
		var button := Button.new()
		button.text = _format_choice_text(index, piece_id, piece)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_select_index.bind(index))
		choices_box.add_child(button)


func _select_index(index: int) -> void:
	if index < 0 or index >= reward_piece_ids.size():
		return
	reward_selected.emit(reward_piece_ids[index])


func _format_choice_text(index: int, piece_id: String, piece: Dictionary) -> String:
	if piece.is_empty():
		return "%s. Unknown reward: %s" % [index + 1, piece_id]
	return "%s. %s [%s]\n%s" % [
		index + 1,
		piece.get("name", piece_id),
		piece.get("category", "unknown"),
		piece.get("simple_description", "")
	]
