extends Control

@export var cell_size := Vector2(72, 72)

var labels: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = cell_size * Vector2(GardenManager.GRID_SIZE.x, GardenManager.GRID_SIZE.y)
	GardenManager.grid_reset.connect(refresh)
	GardenManager.piece_placed.connect(_on_piece_changed)
	GardenManager.piece_removed.connect(_on_piece_changed)
	_build_cells()
	refresh()


func refresh() -> void:
	for cell in labels.keys():
		var label: Label = labels[cell]
		var piece := GardenManager.get_piece_at(cell)
		label.text = piece.get("name", "") if not piece.is_empty() else ""
		if cell == GardenManager.HEART_CELL:
			label.modulate = Color(1.0, 0.92, 0.62)
		else:
			label.modulate = Color.WHITE


func _build_cells() -> void:
	for y in range(GardenManager.GRID_SIZE.y):
		for x in range(GardenManager.GRID_SIZE.x):
			var cell := Vector2i(x, y)
			var panel := PanelContainer.new()
			panel.position = Vector2(x * cell_size.x, y * cell_size.y)
			panel.size = cell_size
			add_child(panel)
			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			panel.add_child(label)
			labels[cell] = label


func _on_piece_changed(_cell: Vector2i, _piece_id: String) -> void:
	refresh()
