extends PanelContainer

const CELL_SIZE := Vector2(96, 64)
const EMPTY_TEXT := "."
const TRIGGER_MARKER := " *"

@onready var grid := $MarginContainer/VBoxContainer/GridContainer

var _cell_panels: Dictionary = {}
var _cell_labels: Dictionary = {}
var _flash_tweens: Dictionary = {}


func _ready() -> void:
	GardenManager.grid_reset.connect(refresh)
	GardenManager.piece_placed.connect(_on_piece_changed)
	GardenManager.piece_removed.connect(_on_piece_changed)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	_build_cells()
	refresh()


func refresh() -> void:
	for cell in _cell_labels.keys():
		_update_cell(cell)


func _build_cells() -> void:
	for child in grid.get_children():
		child.queue_free()
	_cell_panels.clear()
	_cell_labels.clear()
	for y in range(GardenManager.GRID_SIZE.y):
		for x in range(GardenManager.GRID_SIZE.x):
			var cell := Vector2i(x, y)
			var panel := PanelContainer.new()
			panel.custom_minimum_size = CELL_SIZE
			panel.add_theme_stylebox_override("panel", _make_cell_style(Color(0.15, 0.18, 0.16, 0.92), Color(0.38, 0.44, 0.38, 1.0)))
			grid.add_child(panel)

			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_font_size_override("font_size", 12)
			panel.add_child(label)

			_cell_panels[cell] = panel
			_cell_labels[cell] = label


func _update_cell(cell: Vector2i) -> void:
	var label: Label = _cell_labels[cell]
	var panel: PanelContainer = _cell_panels[cell]
	var piece_id := GardenManager.get_piece_id_at(cell)
	var piece := ContentDatabase.get_garden_piece(piece_id)
	var is_heart := cell == GardenManager.HEART_CELL
	label.text = _get_cell_text(cell, piece_id, piece, false)
	panel.add_theme_stylebox_override("panel", _make_cell_style(_get_cell_color(piece, is_heart), _get_border_color(is_heart)))


func _get_cell_text(cell: Vector2i, piece_id: String, piece: Dictionary, triggered: bool) -> String:
	var marker := TRIGGER_MARKER if triggered else ""
	if piece_id.is_empty():
		return "Heart\n%s%s" % [EMPTY_TEXT, marker] if cell == GardenManager.HEART_CELL else "%s%s" % [EMPTY_TEXT, marker]
	var display_name := str(piece.get("name", piece_id))
	var category := "heart" if cell == GardenManager.HEART_CELL else str(piece.get("category", "unknown"))
	return "%s\n%s%s" % [category.capitalize(), display_name, marker]


func _get_cell_color(piece: Dictionary, is_heart: bool) -> Color:
	if is_heart:
		return Color(0.42, 0.35, 0.12, 0.96)
	match str(piece.get("category", "")):
		"flora":
			return Color(0.16, 0.32, 0.20, 0.94)
		"fauna":
			return Color(0.18, 0.24, 0.38, 0.94)
		"object":
			return Color(0.30, 0.27, 0.22, 0.94)
		_:
			return Color(0.15, 0.18, 0.16, 0.92)


func _get_border_color(is_heart: bool) -> Color:
	return Color(1.0, 0.86, 0.34, 1.0) if is_heart else Color(0.38, 0.44, 0.38, 1.0)


func _make_cell_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin(SIDE_LEFT, 4)
	style.set_content_margin(SIDE_RIGHT, 4)
	style.set_content_margin(SIDE_TOP, 4)
	style.set_content_margin(SIDE_BOTTOM, 4)
	return style


func _on_piece_changed(_cell: Vector2i, _piece_id: String) -> void:
	refresh()


func _on_piece_triggered(cell: Vector2i, _piece_id: String, _trigger: Dictionary) -> void:
	_flash_cell(cell)


func _flash_cell(cell: Vector2i) -> void:
	if not _cell_panels.has(cell):
		return
	var panel: PanelContainer = _cell_panels[cell]
	var label: Label = _cell_labels[cell]
	var piece_id := GardenManager.get_piece_id_at(cell)
	var piece := ContentDatabase.get_garden_piece(piece_id)
	label.text = _get_cell_text(cell, piece_id, piece, true)
	panel.modulate = Color(1.25, 1.25, 0.7, 1.0)
	if _flash_tweens.has(cell):
		var old_tween: Tween = _flash_tweens[cell]
		if old_tween != null:
			old_tween.kill()
	var tween := create_tween()
	_flash_tweens[cell] = tween
	tween.tween_property(panel, "modulate", Color.WHITE, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_flash_finished.bind(cell))


func _on_flash_finished(cell: Vector2i) -> void:
	_flash_tweens.erase(cell)
	_update_cell(cell)
