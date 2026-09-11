extends Control

const LeagueStateScript = preload("res://scripts/core/league_state.gd")
const DataPackScript = preload("res://scripts/core/data_pack.gd")
const SquadStateScript = preload("res://scripts/core/squad_state.gd")
const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")
const EconomyStateScript = preload("res://scripts/core/economy_state.gd")
const TransferMarketStateScript = preload("res://scripts/core/transfer_market_state.gd")
const SquadViewScript = preload("res://scripts/ui/squad_view.gd")
const TacticsViewScript = preload("res://scripts/ui/tactics_view.gd")
const FixtureViewScript = preload("res://scripts/ui/fixture_view.gd")
const StandingsViewScript = preload("res://scripts/ui/standings_view.gd")
const TransferViewScript = preload("res://scripts/ui/transfer_view.gd")
const SaveGameScript = preload("res://scripts/core/save_game.gd")
const TeamSelectionViewScript = preload("res://scripts/ui/team_selection_view.gd")

const COLOR_BACKGROUND := Color(0.05098, 0.058824, 0.078431, 1.0)
const COLOR_PANEL := Color(0.090196, 0.105882, 0.137255, 1.0)
const COLOR_PANEL_ALT := Color(0.121569, 0.137255, 0.172549, 1.0)
const COLOR_ACCENT := Color(0.87451, 0.168627, 0.164706, 1.0)
const COLOR_BLUE := Color(0.0, 0.501961, 0.705882, 1.0)
const COLOR_TEXT := Color(0.95, 0.96, 0.98, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.72, 1.0)
const COLOR_SUCCESS := Color(0.0, 0.588235, 0.431373, 1.0)

const DEFAULT_TEAM_ID := "kocaelispor"
const SAVE_PATH := "user://tsl2027_save.json"

var league
var table_grid: GridContainer
var week_label: Label
var week_value: Label
var leader_value: Label
var user_position_value: Label
var upcoming_label: Label
var result_label: Label
var play_button: Button
var save_button: Button
var load_button: Button
var data_status_label: Label
var data_pack
var managed_team_id: String = DEFAULT_TEAM_ID
var managed_team_name: String = "Kocaelispor"
var squad_state
var squad_view
var tactics_state
var tactics_view
var economy_state
var transfer_market_state
var transfer_view
var fixture_view
var standings_view
var team_selection_view
var save_game
var dashboard_subtitle: Label
var dashboard_nodes: Array = []
var content_scroll: ScrollContainer

func _ready() -> void:
	data_pack = DataPackScript.new()
	var data_loaded: bool = data_pack.load_from_files(
		"res://data/teams.json",
		"res://data/players.json",
		"res://data/game_rules.json"
	)
	_build_ui()
	if not data_loaded:
		_set_data_error_state()
		return

	save_game = SaveGameScript.new()
	team_selection_view.setup(data_pack.teams, DEFAULT_TEAM_ID)
	_start_new_career(DEFAULT_TEAM_ID)

func _start_new_career(selected_team_id: String) -> bool:
	var selected_team: Dictionary = _find_team(selected_team_id)
	if selected_team.is_empty():
		_set_data_error_state("Seçilen takım veri paketinde bulunamadı: %s" % selected_team_id)
		return false
	managed_team_id = selected_team_id
	managed_team_name = String(selected_team.get("name", selected_team_id))

	squad_state = SquadStateScript.new()
	if not squad_state.initialize(managed_team_id, data_pack.get_team_squad(managed_team_id)):
		_set_data_error_state(squad_state.error_message)
		return false
	tactics_state = TacticsStateScript.new()
	if not tactics_state.initialize():
		_set_data_error_state(tactics_state.error_message)
		return false
	economy_state = EconomyStateScript.new()
	if not economy_state.initialize(
		managed_team_id,
		int(selected_team.get("strength", 50)),
		data_pack.rules.get("economy", {}),
		data_pack.get_team_squad(managed_team_id)
	):
		_set_data_error_state(economy_state.error_message)
		return false
	transfer_market_state = TransferMarketStateScript.new()
	if not transfer_market_state.initialize(
		data_pack.players,
		managed_team_id,
		int(data_pack.rules.get("economy", {}).get("transfer_window_end_week", 8))
	):
		_set_data_error_state(transfer_market_state.error_message)
		return false
	league = LeagueStateScript.new()
	league.initialize(data_pack.teams, 2026)
	_sync_managed_context()
	data_status_label.text = "%d takım • %d sentetik oyuncu • yönetilen: %s • şema %s" % [
		data_pack.teams.size(),
		data_pack.players.size(),
		managed_team_name,
		data_pack.schema_version
	]
	squad_view.setup(squad_state, managed_team_name)
	tactics_view.setup(tactics_state, managed_team_name)
	transfer_view.setup(transfer_market_state, economy_state, squad_state, managed_team_name)
	fixture_view.setup(league, managed_team_id, managed_team_name)
	standings_view.setup(league)
	team_selection_view.setup(data_pack.teams, managed_team_id)
	_set_screen("dashboard")
	_refresh_ui()
	return true

func _find_team(team_id: String) -> Dictionary:
	for team in data_pack.teams:
		if String(team.get("id", "")) == team_id:
			return team
	return {}

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = COLOR_BACKGROUND
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	margin.add_child(page)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 66)
	page.add_child(header)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	title_box.add_child(_make_label("TSL2027", 30, COLOR_TEXT))
	title_box.add_child(_make_label("Trendyol Süper Lig 2026/27 | İlk oynanabilir prototip", 14, COLOR_MUTED))
	data_status_label = _make_label("Veri paketi yükleniyor", 12, COLOR_MUTED)
	title_box.add_child(data_status_label)

	week_label = _make_label("Maç haftası 1/34", 16, COLOR_MUTED)
	week_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(week_label)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	page.add_child(body)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(220, 0)
	sidebar.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_PANEL_ALT))
	body.add_child(sidebar)

	var navigation := VBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	sidebar.add_child(navigation)
	navigation.add_child(_make_label("MENÜ", 12, COLOR_MUTED))

	var menu_items := ["Genel Bakış", "Takım Seç", "Kadro", "Taktikler", "Fikstür", "Lig Tablosu", "Transfer"]
	for index in range(menu_items.size()):
		var button := Button.new()
		button.text = menu_items[index]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 42)
		button.add_theme_font_size_override("font_size", 15)
		navigation.add_child(button)

		if index == 0:
			button.pressed.connect(_show_dashboard)
		elif index == 1:
			button.pressed.connect(_show_team_selection)
		elif index == 2:
			button.pressed.connect(_show_squad)
		elif index == 3:
			button.pressed.connect(_show_tactics)
		elif index == 4:
			button.pressed.connect(_show_fixtures)
		elif index == 5:
			button.pressed.connect(_show_standings)
		else:
			button.pressed.connect(_show_transfer)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	navigation.add_child(spacer)
	navigation.add_child(_make_label("Demo veri seti\nGerçek oyuncu verisi henüz yok", 12, COLOR_MUTED))

	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(content_scroll)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(880, 0)
	content.add_theme_constant_override("separation", 14)
	content_scroll.add_child(content)

	var dashboard_header := HBoxContainer.new()
	content.add_child(dashboard_header)
	var dashboard_title := VBoxContainer.new()
	dashboard_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dashboard_header.add_child(dashboard_title)
	dashboard_title.add_child(_make_label("Genel Bakış", 24, COLOR_TEXT))
	dashboard_subtitle = _make_label("Takım yükleniyor", 14, COLOR_MUTED)
	dashboard_title.add_child(dashboard_subtitle)

	var stats_grid := GridContainer.new()
	stats_grid.columns = 3
	stats_grid.add_theme_constant_override("h_separation", 12)
	stats_grid.add_theme_constant_override("v_separation", 12)
	content.add_child(stats_grid)

	week_value = _add_stat_card(stats_grid, "HAFTA", "1/34", COLOR_ACCENT)
	leader_value = _add_stat_card(stats_grid, "LİDER", "-", COLOR_BLUE)
	user_position_value = _add_stat_card(stats_grid, "TAKIM", "-", COLOR_SUCCESS)

	var upcoming_panel := PanelContainer.new()
	upcoming_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_PANEL_ALT))
	content.add_child(upcoming_panel)

	var upcoming_box := VBoxContainer.new()
	upcoming_box.add_theme_constant_override("separation", 8)
	upcoming_panel.add_child(upcoming_box)
	upcoming_box.add_child(_make_label("SONRAKİ MAÇ", 12, COLOR_MUTED))
	upcoming_label = _make_label("Fikstür yükleniyor", 21, COLOR_TEXT)
	upcoming_box.add_child(upcoming_label)

	play_button = Button.new()
	play_button.text = "Haftayı Oynat"
	play_button.custom_minimum_size = Vector2(0, 44)
	play_button.add_theme_font_size_override("font_size", 16)
	play_button.pressed.connect(_on_play_week_pressed)
	upcoming_box.add_child(play_button)

	var save_actions := HBoxContainer.new()
	save_actions.add_theme_constant_override("separation", 8)
	upcoming_box.add_child(save_actions)
	save_button = Button.new()
	save_button.text = "Kaydet"
	save_button.custom_minimum_size = Vector2(0, 36)
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_on_save_pressed)
	save_actions.add_child(save_button)
	load_button = Button.new()
	load_button.text = "Yükle"
	load_button.custom_minimum_size = Vector2(0, 36)
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_on_load_pressed)
	save_actions.add_child(load_button)

	var result_panel := PanelContainer.new()
	result_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_PANEL_ALT))
	content.add_child(result_panel)

	var result_box := VBoxContainer.new()
	result_box.add_theme_constant_override("separation", 8)
	result_panel.add_child(result_box)
	result_box.add_child(_make_label("MAÇ MERKEZİ", 12, COLOR_MUTED))
	result_label = _make_label("İlk haftayı oynatınca maç sonuçları burada görünecek.", 15, COLOR_TEXT)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.custom_minimum_size = Vector2(0, 72)
	result_box.add_child(result_label)

	var table_panel := PanelContainer.new()
	table_panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL, COLOR_PANEL_ALT))
	content.add_child(table_panel)

	var table_box := VBoxContainer.new()
	table_box.add_theme_constant_override("separation", 10)
	table_panel.add_child(table_box)
	table_box.add_child(_make_label("LİG TABLOSU", 12, COLOR_MUTED))

	table_grid = GridContainer.new()
	table_grid.columns = 6
	table_grid.add_theme_constant_override("h_separation", 18)
	table_grid.add_theme_constant_override("v_separation", 4)
	table_box.add_child(table_grid)

	dashboard_nodes = content.get_children()
	squad_view = SquadViewScript.new()
	squad_view.visible = false
	content.add_child(squad_view)
	tactics_view = TacticsViewScript.new()
	tactics_view.visible = false
	tactics_view.formation_apply_requested.connect(_on_formation_apply_requested)
	content.add_child(tactics_view)
	fixture_view = FixtureViewScript.new()
	fixture_view.visible = false
	content.add_child(fixture_view)
	standings_view = StandingsViewScript.new()
	standings_view.visible = false
	content.add_child(standings_view)
	transfer_view = TransferViewScript.new()
	transfer_view.visible = false
	transfer_view.transfer_requested.connect(_on_transfer_requested)
	content.add_child(transfer_view)
	team_selection_view = TeamSelectionViewScript.new()
	team_selection_view.visible = false
	team_selection_view.new_career_requested.connect(_on_new_career_requested)
	content.add_child(team_selection_view)

func _refresh_ui() -> void:
	var rows: Array = league.get_table()
	if rows.is_empty():
		return
	dashboard_subtitle.text = "%s teknik direktör koltuğu" % managed_team_name

	var leader: Dictionary = rows[0]
	leader_value.text = String(leader["name"])

	var user_row: Dictionary = {}
	for index in range(rows.size()):
		if String(rows[index]["id"]) == managed_team_id:
			user_row = rows[index]
			user_position_value.text = "%d. sıra | %d puan" % [index + 1, int(rows[index]["points"])]
			break

	var displayed_week: int = min(league.current_week, 34)
	week_label.text = "Maç haftası %d/34" % displayed_week
	week_value.text = "%d/34" % displayed_week
	play_button.disabled = league.current_week > 34

	var next_fixture: Dictionary = league.get_next_fixture_for_team(managed_team_id)
	if next_fixture.is_empty():
		upcoming_label.text = "Sezon tamamlandı"
	else:
		var home: Dictionary = league.get_team(String(next_fixture["home_id"]))
		var away: Dictionary = league.get_team(String(next_fixture["away_id"]))
		upcoming_label.text = "Hafta %d  |  %s - %s" % [
			int(next_fixture["week"]),
			String(home.get("name", "?")),
			String(away.get("name", "?"))
		]

	_render_table(rows)
	if fixture_view != null:
		fixture_view.refresh()
	if standings_view != null:
		standings_view.refresh()
	if transfer_view != null:
		transfer_view.refresh()

func _set_data_error_state(message: String = "") -> void:
	data_status_label.text = "Veri paketi yüklenemedi"
	play_button.disabled = true
	if save_button != null:
		save_button.disabled = true
	if load_button != null:
		load_button.disabled = true
	var resolved_message: String = message if not message.is_empty() else data_pack.error_message
	result_label.text = "Oyun başlatılamadı: %s" % resolved_message

func _on_save_pressed() -> void:
	_sync_managed_context()
	if save_game == null:
		result_label.text = "Oyun kaydedilemedi: kayıt sistemi hazır değil."
		return
	if not save_game.save_to_file(SAVE_PATH, league, squad_state, tactics_state, economy_state, transfer_market_state, data_pack.schema_version):
		result_label.text = "Oyun kaydedilemedi: %s" % save_game.error_message
		return
	result_label.text = "Oyun kaydedildi. Hafta %d/%d" % [min(league.current_week, 34), 34]

func _on_load_pressed() -> void:
	if save_game == null:
		result_label.text = "Oyun yüklenemedi: kayıt sistemi hazır değil."
		return
	if not save_game.load_from_file(SAVE_PATH, league, squad_state, tactics_state, economy_state, transfer_market_state, data_pack.schema_version, managed_team_id):
		result_label.text = "Oyun yüklenemedi: %s" % save_game.error_message
		return
	_sync_managed_context()
	squad_view.setup(squad_state, managed_team_name)
	tactics_view.setup(tactics_state, managed_team_name)
	transfer_view.setup(transfer_market_state, economy_state, squad_state, managed_team_name)
	fixture_view.setup(league, managed_team_id, managed_team_name)
	_refresh_ui()
	result_label.text = "Oyun yüklendi. Hafta %d/%d" % [min(league.current_week, 34), 34]

func _render_table(rows: Array) -> void:
	for child in table_grid.get_children():
		child.free()

	var headers := ["#", "Takım", "O", "G", "B", "P"]
	for header in headers:
		_add_table_cell(header, true)

	for index in range(rows.size()):
		var row: Dictionary = rows[index]
		_add_table_cell(str(index + 1), false)
		_add_table_cell(String(row["name"]), false)
		_add_table_cell(str(row["played"]), false)
		_add_table_cell(str(row["wins"]), false)
		_add_table_cell(str(row["draws"]), false)
		_add_table_cell(str(row["points"]), false)

func _on_play_week_pressed() -> void:
	_sync_managed_context()
	var week_to_play: int = league.current_week
	var results: Array = league.play_next_week()

	if results.is_empty():
		result_label.text = "Sezonun tüm haftaları tamamlandı."
		_refresh_ui()
		return
	if not economy_state.advance_week(week_to_play):
		result_label.text = "Hafta oynandı ancak ekonomi tahsil edilemedi: %s" % economy_state.error_message
	transfer_market_state.set_current_week(league.current_week)

	var lines: Array = ["Hafta %d tamamlandı." % week_to_play]
	for result in results:
		var home: Dictionary = league.get_team(String(result["home_id"]))
		var away: Dictionary = league.get_team(String(result["away_id"]))
		lines.append(
			"%s %d - %d %s" % [
				String(home.get("name", "?")),
				int(result["home_goals"]),
				int(result["away_goals"]),
				String(away.get("name", "?"))
			]
		)

	result_label.text = "\n".join(lines)
	_refresh_ui()

func _sync_managed_context() -> void:
	if league == null or squad_state == null or tactics_state == null:
		return
	league.set_team_context(managed_team_id, {
		"starting_xi": squad_state.get_starting_xi(),
		"tactics": tactics_state.get_snapshot()
	})

func _show_dashboard() -> void:
	_set_screen("dashboard")
	result_label.text = "Genel bakış aktif. Haftayı oynatarak simülasyonu ilerletebilirsin."

func _show_squad() -> void:
	_set_screen("squad")

func _show_team_selection() -> void:
	_set_screen("team_selection")

func _on_new_career_requested(selected_team_id: String) -> void:
	if _start_new_career(selected_team_id):
		result_label.text = "%s ile yeni kariyer başladı." % managed_team_name

func _on_formation_apply_requested(formation: String) -> void:
	if not squad_state.can_apply_formation(formation):
		tactics_view.apply_formation_result(false, squad_state.error_message)
		return
	var previous_squad: Dictionary = squad_state.get_snapshot()
	var previous_tactics: Dictionary = tactics_state.get_snapshot()
	if not squad_state.apply_formation(formation):
		tactics_view.apply_formation_result(false, squad_state.error_message)
		return
	if not tactics_state.set_formation(formation):
		squad_state.restore_snapshot(previous_squad)
		tactics_state.initialize(previous_tactics)
		_sync_managed_context()
		tactics_view.apply_formation_result(false, tactics_state.error_message)
		return
	_sync_managed_context()
	squad_view.setup(squad_state, managed_team_name)
	tactics_view.apply_formation_result(true, "Diziliş ve ilk 11 güncellendi: %s" % formation)

func _show_tactics() -> void:
	_set_screen("tactics")

func _show_fixtures() -> void:
	_set_screen("fixtures")

func _show_standings() -> void:
	_set_screen("standings")

func _show_transfer() -> void:
	_set_screen("transfer")

func _on_transfer_requested(player_id: String) -> void:
	if not transfer_market_state.sign_player(player_id, squad_state, economy_state):
		transfer_view.apply_result(transfer_market_state.error_message)
		return
	squad_view.setup(squad_state, managed_team_name)
	transfer_view.apply_result("Transfer tamamlandı. Oyuncu kadroya ve sözleşmelere eklendi.")
	result_label.text = "Transfer tamamlandı: %s" % player_id

func _show_placeholder(screen_name: String) -> void:
	_set_screen("dashboard")
	result_label.text = "%s ekranı sonraki geliştirme diliminde açılacak." % screen_name

func _set_screen(screen_name: String) -> void:
	var show_dashboard: bool = screen_name == "dashboard"
	for node in dashboard_nodes:
		node.visible = show_dashboard
	if squad_view != null:
		squad_view.visible = screen_name == "squad"
	if tactics_view != null:
		tactics_view.visible = screen_name == "tactics"
	if fixture_view != null:
		fixture_view.visible = screen_name == "fixtures"
	if standings_view != null:
		standings_view.visible = screen_name == "standings"
	if transfer_view != null:
		transfer_view.visible = screen_name == "transfer"
	if team_selection_view != null:
		team_selection_view.visible = screen_name == "team_selection"
	if content_scroll != null:
		content_scroll.scroll_vertical = 0

func _add_stat_card(parent: GridContainer, title_text: String, value_text: String, accent: Color) -> Label:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 90)
	panel.add_theme_stylebox_override("panel", _make_panel_style(COLOR_PANEL_ALT, accent))
	parent.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	box.add_child(_make_label(title_text, 11, COLOR_MUTED))

	var value := _make_label(value_text, 22, COLOR_TEXT)
	box.add_child(value)
	return value

func _add_table_cell(text_value: String, is_header: bool) -> void:
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
