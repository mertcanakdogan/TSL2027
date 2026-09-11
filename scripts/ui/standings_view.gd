class_name StandingsView
extends VBoxContainer

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)

var league_state
var table_grid: GridContainer
var summary_label: Label
var built: bool = false

func setup(state) -> void:
	league_state = state
	if not built:
		_build_ui()
		built = true
	refresh()

func refresh() -> void:
	if league_state == null or table_grid == null:
		return
	var rows: Array = league_state.get_table()
	summary_label.text = "%d takım • %d/%d. maç haftası" % [rows.size(), min(league_state.current_week - 1, league_state.season_weeks), league_state.season_weeks]
	for child in table_grid.get_children():
		child.free()
	for header in ["#", "Takım", "O", "G", "B", "M", "AV", "P"]:
		_add_cell(header, true)
	for index in range(rows.size()):
		var row: Dictionary = rows[index]
		_add_cell(str(index + 1), false)
		_add_cell(String(row["name"]), false)
		_add_cell(str(row["played"]), false)
		_add_cell(str(row["wins"]), false)
		_add_cell(str(row["draws"]), false)
		_add_cell(str(row["losses"]), false)
		_add_cell(str(row["goal_difference"]), false)
		_add_cell(str(row["points"]), false)

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)
	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Lig Tablosu", 24, COLOR_TEXT))
	header.add_child(_make_label("Trendyol Süper Lig %s güncel puan durumu" % league_state.season_label, 14, COLOR_MUTED))
	summary_label = _make_label("Tablo yükleniyor", 13, COLOR_BLUE)
	header.add_child(summary_label)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_BLUE))
	add_child(panel)
	table_grid = GridContainer.new()
	table_grid.columns = 8
	table_grid.add_theme_constant_override("h_separation", 18)
	table_grid.add_theme_constant_override("v_separation", 4)
	panel.add_child(table_grid)

func _add_cell(text_value: String, is_header: bool) -> void:
	var cell := _make_label(text_value, 13 if is_header else 14, COLOR_MUTED if is_header else COLOR_TEXT)
	cell.custom_minimum_size = Vector2(0, 28)
	cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	table_grid.add_child(cell)

func _make_label(text_value: String, font_size: int = 16, font_color: Color = COLOR_TEXT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label

func _make_panel_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	return style
