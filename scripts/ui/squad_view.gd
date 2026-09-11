class_name SquadView
extends VBoxContainer

const PlayerRoleRulesScript = preload("res://scripts/core/player_role_rules.gd")

const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

var squad_state
var team_name: String = "Kocaelispor"
var selected_player_id: String = ""
var summary_label: Label
var subtitle_label: Label
var selection_label: Label
var starting_list: VBoxContainer
var bench_list: VBoxContainer
var roster_list: VBoxContainer

func setup(state, managed_team_name: String = "Kocaelispor") -> void:
	squad_state = state
	team_name = managed_team_name
	selected_player_id = ""
	if subtitle_label == null:
		_build_ui()
	else:
		subtitle_label.text = "%s prototip kadrosu • başlangıç planı 4-4-2" % team_name
	_refresh_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(880, 0)
	add_theme_constant_override("separation", 14)

	var header := VBoxContainer.new()
	add_child(header)
	header.add_child(_make_label("Kadro", 24, COLOR_TEXT))
	subtitle_label = _make_label("%s prototip kadrosu • başlangıç planı 4-4-2" % team_name, 14, COLOR_MUTED)
	header.add_child(subtitle_label)
	summary_label = _make_label("Kadro yükleniyor", 13, COLOR_SUCCESS)
	header.add_child(summary_label)

	var instruction_panel := PanelContainer.new()
	instruction_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_BLUE))
	add_child(instruction_panel)
	var instruction_box := VBoxContainer.new()
	instruction_box.add_theme_constant_override("separation", 5)
	instruction_panel.add_child(instruction_box)
	instruction_box.add_child(_make_label("OYUNCU DEĞİŞİMİ", 11, COLOR_MUTED))
	selection_label = _make_label("Kadrodaki iki oyuncuya sırayla basarak ilk 11 ile yedek arasında değişim yap.", 14, COLOR_TEXT)
	selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_box.add_child(selection_label)

	var groups := HBoxContainer.new()
	groups.add_theme_constant_override("separation", 12)
	add_child(groups)
	starting_list = _add_group_panel(groups, "İLK 11 • 4-4-2", COLOR_ACCENT)
	bench_list = _add_group_panel(groups, "YEDEK KULÜBESİ", COLOR_SUCCESS)

	var roster_panel := PanelContainer.new()
	roster_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_PANEL_ALT))
	add_child(roster_panel)
	var roster_box := VBoxContainer.new()
	roster_box.add_theme_constant_override("separation", 8)
	roster_panel.add_child(roster_box)
	roster_box.add_child(_make_label("KADRO HAVUZU", 11, COLOR_MUTED))
	roster_box.add_child(_make_label("Durumunu görmek veya değişim yapmak için oyuncu seç.", 13, COLOR_MUTED))
	roster_list = VBoxContainer.new()
	roster_list.add_theme_constant_override("separation", 3)
	roster_box.add_child(roster_list)

func _refresh_ui() -> void:
	if squad_state == null:
		return

	var starting: Array = squad_state.get_starting_xi()
	var bench: Array = squad_state.get_bench()
	summary_label.text = "%d oyuncu • İlk 11: %d • Yedek: %d" % [
		squad_state.get_roster().size(),
		starting.size(),
		bench.size()
	]
	_clear_list(starting_list)
	_clear_list(bench_list)
	_clear_list(roster_list)

	for player in starting:
		_add_group_player(starting_list, player)
	for player in bench:
		_add_group_player(bench_list, player)
	for player in squad_state.get_roster():
		_add_roster_player(roster_list, player)

func _add_group_panel(parent: HBoxContainer, title: String, border_color: Color) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, border_color))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	box.add_child(_make_label(title, 11, COLOR_MUTED))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 3)
	box.add_child(list)
	return list

func _add_group_player(parent: VBoxContainer, player: Dictionary) -> void:
	var text := "%s  |  %s  |  %s yaş" % [
		String(player.get("display_name", "Oyuncu")),
		String(player.get("position", "?")),
		str(player.get("age", "?"))
	]
	parent.add_child(_make_label("%s  |  %s" % [text, _role_text(player)], 13, COLOR_TEXT))

func _add_roster_player(parent: VBoxContainer, player: Dictionary) -> void:
	var player_id: String = String(player.get("id", ""))
	var group: String = squad_state.get_player_group(player_id)
	var group_text := "İLK 11" if group == "starting" else ("YEDEK" if group == "bench" else "KADRO DIŞI")
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 32)
	parent.add_child(row)

	var player_label := _make_label(
		"%-30s %-3s  %2s yaş  %s" % [
			String(player.get("display_name", "Oyuncu")),
			String(player.get("position", "?")),
			str(player.get("age", "?")),
			"%s  %s" % [group_text, _role_text(player)]
		],
		13,
		COLOR_TEXT
	)
	player_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(player_label)

	var select_button := Button.new()
	select_button.text = "Seçildi" if selected_player_id == player_id else "Seç"
	select_button.custom_minimum_size = Vector2(76, 28)
	select_button.pressed.connect(_on_player_selected.bind(player_id))
	row.add_child(select_button)

func _role_text(player: Dictionary) -> String:
	var best_role: Dictionary = PlayerRoleRulesScript.get_best_role(player)
	var role_name: String = String(best_role.get("role", ""))
	if role_name.is_empty():
		return "Rol uygunluğu yok"
	return "%s %.0f" % [role_name, float(best_role.get("score", 0.0))]

func _on_player_selected(player_id: String) -> void:
	if selected_player_id.is_empty():
		selected_player_id = player_id
		selection_label.text = "%s seçildi. Değiştirmek istediğin ikinci oyuncuya bas." % _player_name(player_id)
		_refresh_ui()
		return

	if selected_player_id == player_id:
		selected_player_id = ""
		selection_label.text = "Oyuncu seçimi iptal edildi. İki oyuncuya sırayla basarak değişim yap."
		_refresh_ui()
		return

	var first_player_id := selected_player_id
	if squad_state.swap_players(first_player_id, player_id):
		selected_player_id = ""
		selection_label.text = "%s ↔ %s değiştirildi." % [_player_name(first_player_id), _player_name(player_id)]
	else:
		selection_label.text = squad_state.error_message
	_refresh_ui()

func _player_name(player_id: String) -> String:
	for player in squad_state.get_roster():
		if String(player.get("id", "")) == player_id:
			return String(player.get("display_name", player_id))
	return player_id

func _clear_list(list: VBoxContainer) -> void:
	for child in list.get_children():
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
