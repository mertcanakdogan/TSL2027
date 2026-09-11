class_name TacticsView
extends VBoxContainer

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

const MENTALITY_LABELS := {
	"cautious": "Temkinli",
	"balanced": "Dengeli",
	"positive": "Pozitif",
	"attacking": "Hücumcu"
}
const MARKING_LABELS := {
	"zonal": "Alan markajı",
	"man_oriented": "Adam adama"
}
const PARAMETER_LABELS := {
	"width": "Genişlik",
	"tempo": "Tempo",
	"defensive_line": "Savunma çizgisi",
	"press_intensity": "Pres yoğunluğu",
	"build_up_risk": "Geriden oyun riski",
	"directness": "Direktlik",
	"transition_speed": "Geçiş hızı",
	"set_piece_focus": "Duran top odağı"
}

var tactics_state
var team_name: String = "Kocaelispor"
var formation_option: OptionButton
var mentality_option: OptionButton
var marking_option: OptionButton
var parameter_sliders: Dictionary = {}
var parameter_values: Dictionary = {}
var feedback_label: Label
var built: bool = false
var subtitle_label: Label

func setup(state, managed_team_name: String = "Kocaelispor") -> void:
	tactics_state = state
	team_name = managed_team_name
	if not built:
		_build_ui()
		built = true
	else:
		subtitle_label.text = "%s maç planı • değerler sonraki motor entegrasyonuna hazır" % team_name
	_refresh_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)

	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Taktikler", 24, COLOR_TEXT))
	subtitle_label = _make_label("%s maç planı • değerler sonraki motor entegrasyonuna hazır" % team_name, 14, COLOR_MUTED)
	header.add_child(subtitle_label)
	feedback_label = _make_label("Değişiklikler bu oturumda uygulanır.", 13, COLOR_SUCCESS)
	header.add_child(feedback_label)

	var choices_panel := PanelContainer.new()
	choices_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_ACCENT))
	add_child(choices_panel)
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation", 10)
	choices_panel.add_child(choices)
	choices.add_child(_make_label("MAÇ PLANI", 11, COLOR_MUTED))
	formation_option = _add_option_row(choices, "Diziliş")
	for formation in tactics_state.FORMATIONS:
		formation_option.add_item(String(formation))
	formation_option.item_selected.connect(_on_formation_selected)

	mentality_option = _add_option_row(choices, "Zihniyet")
	for mentality in tactics_state.MENTALITIES:
		mentality_option.add_item(String(MENTALITY_LABELS[mentality]))
	mentality_option.item_selected.connect(_on_mentality_selected)

	marking_option = _add_option_row(choices, "Markaj")
	for marking in tactics_state.MARKING_APPROACHES:
		marking_option.add_item(String(MARKING_LABELS[marking]))
	marking_option.item_selected.connect(_on_marking_selected)

	var sliders_panel := PanelContainer.new()
	sliders_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_BLUE))
	add_child(sliders_panel)
	var sliders_box := VBoxContainer.new()
	sliders_box.add_theme_constant_override("separation", 8)
	sliders_panel.add_child(sliders_box)
	sliders_box.add_child(_make_label("TAKTİK YOĞUNLUKLARI", 11, COLOR_MUTED))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)
	sliders_box.add_child(grid)
	for parameter in tactics_state.NUMERIC_PARAMETERS:
		_add_slider_row(grid, String(parameter))

func _add_option_row(parent: VBoxContainer, title: String) -> OptionButton:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 34)
	parent.add_child(row)
	var label := _make_label(title, 14, COLOR_TEXT)
	label.custom_minimum_size = Vector2(190, 0)
	row.add_child(label)
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	return option

func _add_slider_row(parent: GridContainer, parameter: String) -> void:
	var row := VBoxContainer.new()
	row.custom_minimum_size = Vector2(390, 62)
	parent.add_child(row)
	var heading := HBoxContainer.new()
	row.add_child(heading)
	heading.add_child(_make_label(String(PARAMETER_LABELS[parameter]), 13, COLOR_TEXT))
	var value_label := _make_label("50", 13, COLOR_MUTED)
	value_label.name = "ValueLabel"
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	heading.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = 50
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_parameter_changed.bind(parameter))
	row.add_child(slider)
	parameter_sliders[parameter] = slider
	parameter_values[parameter] = value_label

func _refresh_ui() -> void:
	if tactics_state == null:
		return
	formation_option.select(tactics_state.FORMATIONS.find(tactics_state.formation))
	mentality_option.select(tactics_state.MENTALITIES.find(tactics_state.mentality))
	marking_option.select(tactics_state.MARKING_APPROACHES.find(tactics_state.marking_approach))
	for parameter in tactics_state.NUMERIC_PARAMETERS:
		var value: int = tactics_state.get_parameter(parameter)
		parameter_sliders[parameter].set_value_no_signal(value)
		parameter_values[parameter].text = str(value)

func _on_formation_selected(index: int) -> void:
	var value: String = String(tactics_state.FORMATIONS[index])
	if tactics_state.set_formation(value):
		feedback_label.text = "Diziliş güncellendi: %s" % value
	else:
		feedback_label.text = tactics_state.error_message
	_refresh_ui()

func _on_mentality_selected(index: int) -> void:
	var value: String = String(tactics_state.MENTALITIES[index])
	if tactics_state.set_mentality(value):
		feedback_label.text = "Zihniyet güncellendi: %s" % MENTALITY_LABELS[value]
	else:
		feedback_label.text = tactics_state.error_message
	_refresh_ui()

func _on_marking_selected(index: int) -> void:
	var value: String = String(tactics_state.MARKING_APPROACHES[index])
	if tactics_state.set_marking_approach(value):
		feedback_label.text = "Markaj güncellendi: %s" % MARKING_LABELS[value]
	else:
		feedback_label.text = tactics_state.error_message
	_refresh_ui()

func _on_parameter_changed(value: float, parameter: String) -> void:
	if tactics_state.set_parameter(parameter, value):
		feedback_label.text = "%s güncellendi: %d" % [PARAMETER_LABELS[parameter], tactics_state.get_parameter(parameter)]
	else:
		feedback_label.text = tactics_state.error_message
	_refresh_ui()

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
