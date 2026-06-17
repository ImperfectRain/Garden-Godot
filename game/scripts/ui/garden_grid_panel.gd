extends PanelContainer

const CELL_SIZE := Vector2(96, 64)
const EMPTY_TEXT := "."
const PIECE_ICON_PATHS := {
	"lantern_lily": "res://game/art/external/kenney/tiny_town/Tiles/tile_0002.png",
	"gravecap": "res://game/art/external/kenney/tiny_town/Tiles/tile_0029.png",
	"blood_rose": "res://game/art/external/kenney/tiny_town/Tiles/tile_0042.png",
	"bellflower": "res://game/art/external/kenney/tiny_town/Tiles/tile_0043.png",
	"saintmoth": "res://game/art/external/kenney/tiny_town/Tiles/tile_0094.png",
	"rotling": "res://game/art/external/kenney/tiny_town/Tiles/tile_0005.png",
	"mawlet": "res://game/art/external/kenney/tiny_town/Tiles/tile_0027.png",
	"glass_beetle": "res://game/art/external/kenney/tiny_town/Tiles/tile_0093.png",
	"grave_bell": "res://game/art/external/kenney/tiny_town/Tiles/tile_0128.png",
	"mirror_shard": "res://game/art/external/kenney/tiny_town/Tiles/tile_0131.png",
	"bone_trellis": "res://game/art/external/kenney/tiny_town/Tiles/tile_0056.png",
	"tiny_fence": "res://game/art/external/kenney/tiny_town/Tiles/tile_0044.png"
}
const CATEGORY_ICON_PATHS := {
	"flora": "res://game/art/external/kenney/tiny_town/Tiles/tile_0002.png",
	"fauna": "res://game/art/external/kenney/tiny_town/Tiles/tile_0094.png",
	"object": "res://game/art/external/kenney/tiny_town/Tiles/tile_0057.png",
	"heart": "res://game/art/external/kenney/tiny_town/Tiles/tile_0094.png"
}

@onready var grid := $MarginContainer/VBoxContainer/GridContainer

var _cell_panels: Dictionary = {}
var _cell_icons: Dictionary = {}
var _cell_labels: Dictionary = {}
var _cell_resource_labels: Dictionary = {}
var _cell_feedback_labels: Dictionary = {}
var _flash_tweens: Dictionary = {}
var _feedback_tweens: Dictionary = {}
var _texture_cache: Dictionary = {}
var _chain_tween: Tween
var _placement_active := false
var _placement_piece_id := ""
var _placement_cell := Vector2i.ZERO


func _ready() -> void:
	GardenManager.grid_reset.connect(refresh)
	GardenManager.piece_placed.connect(_on_piece_changed)
	GardenManager.piece_removed.connect(_on_piece_changed)
	GardenManager.piece_triggered.connect(_on_piece_triggered)
	GardenManager.selected_cell_changed.connect(_on_selected_cell_changed)
	GardenEffectResolver.effect_resolved.connect(_on_effect_resolved)
	Bloomchains.chain_path_finished.connect(_on_chain_path_finished)
	_build_cells()
	refresh()


func refresh() -> void:
	for cell in _cell_labels.keys():
		_update_cell(cell)


func set_placement_preview(active: bool, piece_id := "", cell := Vector2i.ZERO) -> void:
	_placement_active = active
	_placement_piece_id = piece_id
	_placement_cell = cell
	refresh()


func _build_cells() -> void:
	for child in grid.get_children():
		child.queue_free()
	_cell_panels.clear()
	_cell_feedback_labels.clear()
	_cell_resource_labels.clear()
	_cell_labels.clear()
	for y in range(GardenManager.GRID_SIZE.y):
		for x in range(GardenManager.GRID_SIZE.x):
			var cell := Vector2i(x, y)
			var panel := PanelContainer.new()
			panel.custom_minimum_size = CELL_SIZE
			panel.add_theme_stylebox_override("panel", _make_cell_style(Color(0.15, 0.18, 0.16, 0.92), Color(0.38, 0.44, 0.38, 1.0)))
			grid.add_child(panel)

			var content := VBoxContainer.new()
			content.alignment = BoxContainer.ALIGNMENT_CENTER
			panel.add_child(content)

			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(28, 28)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			content.add_child(icon)

			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.add_theme_font_size_override("font_size", 11)
			content.add_child(label)

			var resource_label := Label.new()
			resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			resource_label.add_theme_font_size_override("font_size", 10)
			resource_label.modulate = Color(0.82, 0.92, 0.78, 1.0)
			content.add_child(resource_label)

			var feedback_label := Label.new()
			feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			feedback_label.add_theme_font_size_override("font_size", 12)
			feedback_label.modulate = Color(1, 1, 1, 0)
			content.add_child(feedback_label)

			_cell_panels[cell] = panel
			_cell_icons[cell] = icon
			_cell_labels[cell] = label
			_cell_resource_labels[cell] = resource_label
			_cell_feedback_labels[cell] = feedback_label


func _update_cell(cell: Vector2i) -> void:
	var icon: TextureRect = _cell_icons[cell]
	var label: Label = _cell_labels[cell]
	var resource_label: Label = _cell_resource_labels[cell]
	var panel: PanelContainer = _cell_panels[cell]
	var piece_id := GardenManager.get_piece_id_at(cell)
	var piece := ContentDatabase.get_garden_piece(piece_id)
	var is_heart := cell == GardenManager.HEART_CELL
	icon.texture = _get_icon_texture(piece_id, piece, is_heart)
	icon.visible = icon.texture != null
	label.text = _get_cell_text(cell, piece_id, piece, _get_preview_marker(cell))
	resource_label.text = _get_resource_badge_text(cell, piece_id, piece)
	panel.add_theme_stylebox_override("panel", _make_cell_style(_get_cell_color(piece, is_heart), _get_border_color(cell, is_heart)))


func _get_cell_text(cell: Vector2i, piece_id: String, piece: Dictionary, marker: String) -> String:
	if _placement_active and cell == _placement_cell and piece_id.is_empty():
		var pending_piece := ContentDatabase.get_garden_piece(_placement_piece_id)
		return "Place\n%s%s" % [pending_piece.get("name", _placement_piece_id), marker]
	if _placement_active and cell == _placement_cell and not GardenManager.can_place_piece(cell, _placement_piece_id):
		return "Blocked\n%s%s" % [piece.get("name", piece_id), marker]
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


func _get_border_color(cell: Vector2i, is_heart: bool) -> Color:
	if _placement_active and cell == _placement_cell:
		return Color(0.36, 0.95, 0.52, 1.0) if GardenManager.can_place_piece(cell, _placement_piece_id) else Color(1.0, 0.28, 0.22, 1.0)
	if _placement_active and _is_mirror_opposite_preview_cell(cell):
		return Color(0.88, 0.50, 1.0, 1.0)
	if _placement_active and GardenManager.are_cells_adjacent(_placement_cell, cell):
		return Color(1.0, 0.80, 0.28, 1.0) if _pending_piece_likes_cell(cell) else Color(0.42, 0.62, 0.78, 1.0)
	if _placement_active and _pending_piece_can_route_to_cell(cell):
		return Color(0.56, 0.92, 1.0, 1.0)
	if cell == GardenManager.selected_cell:
		return Color(0.46, 0.78, 1.0, 1.0)
	return Color(1.0, 0.86, 0.34, 1.0) if is_heart else Color(0.38, 0.44, 0.38, 1.0)


func _get_icon_texture(piece_id: String, piece: Dictionary, is_heart: bool) -> Texture2D:
	if piece_id.is_empty():
		return null
	var icon_path := str(PIECE_ICON_PATHS.get(piece_id, ""))
	if icon_path.is_empty():
		var category := "heart" if is_heart else str(piece.get("category", ""))
		icon_path = str(CATEGORY_ICON_PATHS.get(category, ""))
	if icon_path.is_empty():
		return null
	if not _texture_cache.has(icon_path):
		_texture_cache[icon_path] = load(icon_path)
	return _texture_cache[icon_path]


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


func _on_selected_cell_changed(_cell: Vector2i) -> void:
	refresh()


func _on_piece_triggered(cell: Vector2i, _piece_id: String, _trigger: Dictionary) -> void:
	_flash_cell(cell, _trigger)
	_show_cell_feedback(cell, _get_feedback_text(_trigger))
	refresh()


func _flash_cell(cell: Vector2i, trigger: Dictionary) -> void:
	if not _cell_panels.has(cell):
		return
	var panel: PanelContainer = _cell_panels[cell]
	var label: Label = _cell_labels[cell]
	var piece_id := GardenManager.get_piece_id_at(cell)
	var piece := ContentDatabase.get_garden_piece(piece_id)
	label.text = _get_cell_text(cell, piece_id, piece, _get_trigger_marker(trigger))
	panel.modulate = _get_flash_color(piece, trigger)
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


func _show_cell_feedback(cell: Vector2i, text: String) -> void:
	if text.is_empty() or not _cell_feedback_labels.has(cell):
		return
	var label: Label = _cell_feedback_labels[cell]
	label.text = text
	label.modulate = Color(1, 1, 1, 1)
	if _feedback_tweens.has(cell):
		var old_tween: Tween = _feedback_tweens[cell]
		if old_tween != null:
			old_tween.kill()
	var tween := create_tween()
	_feedback_tweens[cell] = tween
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_feedback_finished.bind(cell))


func _on_feedback_finished(cell: Vector2i) -> void:
	_feedback_tweens.erase(cell)


func _on_effect_resolved(result: Dictionary) -> void:
	match str(result.get("action", "")):
		"move_resource":
			_show_resource_move(result)
		"copy_output":
			_show_copy_output(result)
		"store_resource":
			refresh()


func _show_resource_move(result: Dictionary) -> void:
	var origin_cell: Vector2i = result.get("origin_cell", Vector2i(-1, -1))
	var carrier_cell: Vector2i = result.get("cell", Vector2i(-1, -1))
	var target_cell: Vector2i = result.get("target_cell", Vector2i(-1, -1))
	var resource_id := str(result.get("resource", ""))
	if GardenManager.is_valid_cell(origin_cell):
		_show_cell_feedback(origin_cell, "%s >" % resource_id)
		_pulse_cell(origin_cell, Color(0.55, 0.85, 1.2, 1.0))
	if GardenManager.is_valid_cell(carrier_cell):
		_show_cell_feedback(carrier_cell, "Carry")
		_pulse_cell(carrier_cell, Color(0.9, 0.7, 1.25, 1.0))
	if GardenManager.is_valid_cell(target_cell):
		_show_cell_feedback(target_cell, "> %s" % resource_id)
		_pulse_cell(target_cell, Color(0.55, 1.05, 0.9, 1.0))
	refresh()


func _show_copy_output(result: Dictionary) -> void:
	var context: Dictionary = result.get("context", {})
	var source_cell: Vector2i = context.get("copied_source_cell", Vector2i(-1, -1))
	var mirror_cell: Vector2i = result.get("cell", Vector2i(-1, -1))
	if GardenManager.is_valid_cell(source_cell):
		_show_cell_feedback(source_cell, "Source")
		_pulse_cell(source_cell, Color(0.82, 0.82, 1.25, 1.0))
	if GardenManager.is_valid_cell(mirror_cell):
		_show_cell_feedback(mirror_cell, "Copy")
		_pulse_cell(mirror_cell, Color(1.08, 0.78, 1.35, 1.0))
	refresh()


func _on_chain_path_finished(steps: Array) -> void:
	if steps.size() < 2:
		return
	if _chain_tween != null:
		_chain_tween.kill()
	_chain_tween = create_tween()
	for index in range(steps.size()):
		var step: Dictionary = steps[index]
		var cell: Vector2i = step.get("cell", Vector2i(-1, -1))
		if not GardenManager.is_valid_cell(cell):
			continue
		_chain_tween.tween_callback(_show_chain_path_step.bind(cell, index + 1))
		_chain_tween.tween_interval(0.18)


func _show_chain_path_step(cell: Vector2i, step_number: int) -> void:
	_show_cell_feedback(cell, "Chain %s" % step_number)
	_pulse_cell(cell, Color(1.0, 1.18, 0.55, 1.0))


func _pulse_cell(cell: Vector2i, color: Color) -> void:
	if not _cell_panels.has(cell):
		return
	var panel: PanelContainer = _cell_panels[cell]
	panel.modulate = color
	if _flash_tweens.has(cell):
		var old_tween: Tween = _flash_tweens[cell]
		if old_tween != null:
			old_tween.kill()
	var tween := create_tween()
	_flash_tweens[cell] = tween
	tween.tween_property(panel, "modulate", Color.WHITE, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_flash_finished.bind(cell))


func _pending_piece_likes_cell(cell: Vector2i) -> bool:
	var cell_piece_id := GardenManager.get_piece_id_at(cell)
	if cell_piece_id.is_empty():
		return false
	var pending_piece := ContentDatabase.get_garden_piece(_placement_piece_id)
	var cell_piece := ContentDatabase.get_garden_piece(cell_piece_id)
	var cell_category := str(cell_piece.get("category", ""))
	var likes: Array = pending_piece.get("likes", [])
	for like in likes:
		var like_id := str(like)
		if like_id == cell_piece_id or like_id == cell_category or cell_piece.get("tags", []).has(like_id):
			return true
	return false


func _pending_piece_can_route_to_cell(cell: Vector2i) -> bool:
	if not _placement_active or cell == _placement_cell or GardenManager.get_piece_id_at(cell).is_empty():
		return false
	var pending_piece := ContentDatabase.get_garden_piece(_placement_piece_id)
	var pending_tags: Array = pending_piece.get("tags", [])
	if pending_tags.has("carrier"):
		return GardenManager.are_cells_adjacent(_placement_cell, cell)
	if pending_tags.has("connection") and GardenManager.get_piece_category_at(cell) == "flora":
		return GardenManager.are_cells_adjacent(_placement_cell, cell)
	return false


func _is_mirror_opposite_preview_cell(cell: Vector2i) -> bool:
	if not _placement_active or _placement_piece_id != "mirror_shard":
		return false
	var opposite := Vector2i(GardenManager.GRID_SIZE.x - 1 - _placement_cell.x, GardenManager.GRID_SIZE.y - 1 - _placement_cell.y)
	return cell == opposite and not GardenManager.get_piece_id_at(cell).is_empty()


func _get_preview_marker(cell: Vector2i) -> String:
	if not _placement_active or cell == _placement_cell:
		return ""
	if _is_mirror_opposite_preview_cell(cell):
		return " mirror"
	if _pending_piece_likes_cell(cell):
		return " link"
	if _pending_piece_can_route_to_cell(cell):
		return " route"
	return ""


func _get_resource_badge_text(cell: Vector2i, piece_id: String, piece: Dictionary) -> String:
	var parts: Array[String] = []
	var summary: Dictionary = GardenManager.get_cell_resource_summary(cell)
	for resource_id in summary.keys():
		parts.append("%s:%s" % [str(resource_id).substr(0, 1).to_upper(), int(summary[resource_id])])
	var stores: Array = piece.get("stores", [])
	for store_data in stores:
		var store: Dictionary = store_data
		var resource := str(store.get("resource", ""))
		if resource.is_empty():
			continue
		var stored := GardenEffectResolver.get_stored_amount(cell, piece_id, resource)
		if stored > 0:
			parts.append("%s:%s" % [resource.substr(0, 1).to_upper(), stored])
	if parts.is_empty():
		return ""
	return " ".join(PackedStringArray(parts))


func _get_trigger_marker(trigger: Dictionary) -> String:
	match str(trigger.get("action", "")):
		"produce_resource":
			return " +"
		"store_resource":
			return " ="
		"move_resource", "copy_output":
			return " >"
		"damage_enemy", "damage_nearby_enemies":
			return " !"
		"spawn_helper":
			return " *"
		"repeat_last_trigger":
			return " x"
		_:
			return " *"


func _get_feedback_text(trigger: Dictionary) -> String:
	var amount := int(trigger.get("amount", trigger.get("cost", 0)))
	match str(trigger.get("action", "")):
		"produce_resource":
			return "+%s %s" % [amount, str(trigger.get("resource", ""))]
		"grant_player_shield":
			return "+Shield"
		"store_resource":
			return "Store %s" % str(trigger.get("resource", ""))
		"damage_enemy", "damage_nearby_enemies":
			return "Hit %s" % amount
		"spawn_helper":
			return "+Helper"
		"repeat_last_trigger":
			return "Repeat"
		"move_resource":
			return "Move"
		"copy_output":
			return "Copy"
		"protect_adjacent_living":
			return "Protect"
		"connect_adjacent_flora":
			return "Connect"
	return ""


func _get_flash_color(piece: Dictionary, trigger: Dictionary) -> Color:
	match str(trigger.get("action", "")):
		"produce_resource":
			return Color(0.78, 1.35, 0.78, 1.0)
		"grant_player_shield", "consume_resource":
			return Color(0.72, 0.92, 1.35, 1.0)
		"damage_enemy", "damage_nearby_enemies":
			return Color(1.35, 0.82, 0.54, 1.0)
		"move_resource", "copy_output", "repeat_last_trigger":
			return Color(1.05, 0.82, 1.35, 1.0)
	match str(piece.get("category", "")):
		"flora":
			return Color(0.9, 1.25, 0.8, 1.0)
		"fauna":
			return Color(0.78, 0.95, 1.25, 1.0)
		"object":
			return Color(1.25, 1.08, 0.76, 1.0)
		_:
			return Color(1.25, 1.25, 0.7, 1.0)
