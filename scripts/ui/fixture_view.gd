class_name FixtureView
extends VBoxContainer

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

var league_state
var team_id: String = ""
var summary_label: Label
var fixture_list: VBoxContainer
var built: bool = false

func setup(state, managed_team_id: String) -> void:
	league_state = state
	team_id = managed_team_id
	if not built:
		_build_ui()
		built = true
	refresh()

func refresh() -> void:
	if league_state == null or fixture_list == null:
		return
	var fixtures: Array = league_state.get_fixtures_for_team(team_id)
	summary_label.text = "%d maç • %d oynandı • %d planlandı" % [
		fixtures.size(),
		_played_count(fixtures),
		fixtures.size() - _played_count(fixtures)
	]
	_clear_list()
	for fixture in fixtures:
		fixture_list.add_child(_make_fixture_row(fixture))

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)
	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Fikstür", 24, COLOR_TEXT))
	header.add_child(_make_label("Kocaelispor 2026/27 lig fikstürü", 14, COLOR_MUTED))
	summary_label = _make_label("Fikstür yükleniyor", 13, COLOR_SUCCESS)
	header.add_child(summary_label)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_ACCENT))
	add_child(panel)
	fixture_list = VBoxContainer.new()
	fixture_list.add_theme_constant_override("separation", 4)
	panel.add_child(fixture_list)

func _make_fixture_row(fixture: Dictionary) -> Control:
	var home_id: String = String(fixture["home_id"])
	var away_id: String = String(fixture["away_id"])
	var opponent_id: String = away_id if home_id == team_id else home_id
	var opponent: Dictionary = league_state.get_team(opponent_id)
	var venue: String = "İç saha" if home_id == team_id else "Deplasman"
	var status: String = "Planlandı"
	var status_color: Color = COLOR_MUTED
	if bool(fixture.get("played", false)):
		var result: Dictionary = fixture.get("result", {})
		var home_goals: int = int(result.get("home_goals", 0))
		var away_goals: int = int(result.get("away_goals", 0))
		var managed_goals: int = home_goals if home_id == team_id else away_goals
		var conceded_goals: int = away_goals if home_id == team_id else home_goals
		status = "Skor %d-%d" % [managed_goals, conceded_goals]
		status_color = COLOR_SUCCESS

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 32)
	row.add_theme_constant_override("separation", 12)
	row.add_child(_make_label("%02d. hafta" % int(fixture["week"]), 13, COLOR_MUTED))
	row.add_child(_make_label(venue, 13, COLOR_MUTED))
	var opponent_label := _make_label(String(opponent.get("name", opponent_id)), 14, COLOR_TEXT)
	opponent_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(opponent_label)
	var status_label := _make_label(status, 13, status_color)
	status_label.custom_minimum_size = Vector2(120, 0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(status_label)
	return row

func _played_count(fixtures: Array) -> int:
	var count: int = 0
	for fixture in fixtures:
		if bool(fixture.get("played", false)):
			count += 1
	return count

func _clear_list() -> void:
	for child in fixture_list.get_children():
		child.free()

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
