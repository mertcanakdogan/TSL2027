class_name TeamSelectionView
extends VBoxContainer

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

signal new_career_requested(team_id: String)

var team_records: Array = []
var team_option: OptionButton
var team_summary: Label
var start_button: Button
var selected_team_id: String = ""
var built: bool = false

func setup(records: Array, current_team_id: String) -> void:
	team_records = records.duplicate(true)
	selected_team_id = current_team_id
	if not built:
		_build_ui()
		built = true
		for team in team_records:
			team_option.add_item(String(team.get("name", "Takım")))
		team_option.item_selected.connect(_on_team_selected)
	_refresh_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)
	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Takım Seç", 24, COLOR_TEXT))
	header.add_child(_make_label("Yeni kariyer için Süper Lig'den bir kulüp seç", 14, COLOR_MUTED))

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_ACCENT))
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(_make_label("YÖNETİLECEK TAKIM", 11, COLOR_MUTED))
	team_option = OptionButton.new()
	team_option.custom_minimum_size = Vector2(0, 42)
	team_option.add_theme_font_size_override("font_size", 16)
	box.add_child(team_option)
	team_summary = _make_label("Takım bilgisi yükleniyor", 14, COLOR_TEXT)
	team_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(team_summary)
	start_button = Button.new()
	start_button.text = "Yeni Kariyeri Başlat"
	start_button.custom_minimum_size = Vector2(0, 46)
	start_button.add_theme_font_size_override("font_size", 16)
	start_button.pressed.connect(_on_start_pressed)
	box.add_child(start_button)

func _refresh_ui() -> void:
	if team_option == null:
		return
	var selected_index: int = _team_index(selected_team_id)
	if selected_index >= 0:
		team_option.select(selected_index)
		var team: Dictionary = team_records[selected_index]
		team_summary.text = "%s • takım gücü %d • sentetik 18 kişilik kadro" % [
			String(team.get("name", "Takım")),
			int(team.get("strength", 50))
		]

func _on_team_selected(index: int) -> void:
	if index < 0 or index >= team_records.size():
		return
	selected_team_id = String(team_records[index].get("id", ""))
	_refresh_ui()

func _on_start_pressed() -> void:
	if not selected_team_id.is_empty():
		new_career_requested.emit(selected_team_id)

func _team_index(team_id: String) -> int:
	for index in range(team_records.size()):
		if String(team_records[index].get("id", "")) == team_id:
			return index
	return -1

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
