extends SceneTree

var failures: Array = []

func _init() -> void:
	_run()

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene._ready()

	var squad_view = scene.get("squad_view")
	var tactics_view = scene.get("tactics_view")
	var tactics_state = scene.get("tactics_state")
	var fixture_view = scene.get("fixture_view")
	var standings_view = scene.get("standings_view")
	var transfer_view = scene.get("transfer_view")
	var transfer_market = scene.get("transfer_market_state")
	var result_label = scene.get("result_label")
	var team_selection_view = scene.get("team_selection_view")
	var credits_view = scene.get("credits_view")
	var dashboard_nodes: Array = scene.get("dashboard_nodes")
	_check(squad_view != null, "main scene should create SquadView")
	_check(tactics_view != null, "main scene should create TacticsView")
	_check(fixture_view != null, "main scene should create FixtureView")
	_check(standings_view != null, "main scene should create StandingsView")
	_check(transfer_view != null, "main scene should create TransferView")
	_check(team_selection_view != null, "main scene should create TeamSelectionView")
	_check(credits_view != null, "main scene should create CreditsView")
	_check(not credits_view.visible, "dashboard should hide CreditsView by default")
	_check(team_selection_view.team_option.item_count == 18, "TeamSelectionView should list all 18 teams")
	_check(tactics_state != null, "main scene should create TacticsState")
	_check(scene.get("save_game") != null, "main scene should create SaveGame")
	_check(String(tactics_state.formation) == "4-4-2", "main scene should use the default formation")
	_check(String(squad_view.squad_state.get_active_formation()) == "4-4-2", "main scene should use the default active lineup formation")
	_check(not squad_view.visible, "dashboard should be visible by default")
	_check(not tactics_view.visible, "tactics view should be hidden by default")
	_check(dashboard_nodes.size() > 0, "main scene should register dashboard nodes")

	scene.call("_show_squad")
	_check(squad_view.visible, "Kadro action should show SquadView")
	_check(not dashboard_nodes[0].visible, "Kadro action should hide dashboard nodes")

	scene.call("_show_tactics")
	_check(tactics_view.visible, "Taktikler action should show TacticsView")
	_check(not squad_view.visible, "Taktikler action should hide SquadView")
	_check(not dashboard_nodes[0].visible, "Taktikler action should hide dashboard nodes")
	tactics_view.call("_on_formation_selected", 1)
	_check(String(tactics_state.formation) == "4-4-2", "formation selection should remain a draft until applied")
	tactics_view.call("_on_apply_formation_pressed")
	_check(String(tactics_state.formation) == "4-3-3", "Taktikler view should update formation state")
	_check(String(squad_view.squad_state.get_active_formation()) == "4-3-3", "applied formation should update SquadState")
	_check(squad_view.squad_state.get_starting_position_counts() == {"GK": 1, "DF": 4, "MF": 3, "FW": 3}, "applied formation should update starting position counts")
	tactics_view.call("_on_parameter_changed", 80.0, "tempo")
	_check(int(tactics_state.tempo) == 80, "Taktikler view should update numeric state")

	scene.call("_show_fixtures")
	_check(fixture_view.visible, "Fikstür action should show FixtureView")
	_check(not standings_view.visible, "Fikstür action should hide StandingsView")
	_check(fixture_view.fixture_list.get_child_count() == 34, "FixtureView should list 34 managed fixtures")

	scene.call("_show_standings")
	_check(standings_view.visible, "Lig Tablosu action should show StandingsView")
	_check(not fixture_view.visible, "Lig Tablosu action should hide FixtureView")
	_check(standings_view.table_grid.get_child_count() == 8 + (18 * 8), "StandingsView should render all teams")

	scene.call("_show_transfer")
	_check(transfer_view.visible, "Transfer action should show TransferView")
	_check(transfer_market.get_offers().size() == 324 - 18, "Transfer market should exclude managed team players")
	var first_offer: Dictionary = transfer_market.get_offers(1)[0]
	var roster_before_transfer: int = squad_view.squad_state.get_roster().size()
	transfer_view.call("_on_sign_pressed", String(first_offer["player"]["id"]))
	_check(squad_view.squad_state.get_roster().size() == roster_before_transfer + 1, "Transfer action should add player to managed roster")
	_check(not transfer_market.has_offer(String(first_offer["player"]["id"])), "Transfer action should remove signed offer")

	scene.call("_show_dashboard")
	_check(not squad_view.visible, "dashboard action should hide SquadView")
	_check(not tactics_view.visible, "dashboard action should hide TacticsView")
	_check(dashboard_nodes[0].visible, "dashboard action should show dashboard nodes")

	scene.call("_show_credits")
	_check(credits_view.visible, "Credits action should show CreditsView")
	_check(not dashboard_nodes[0].visible, "Credits action should hide dashboard nodes")
	_check(credits_view.source_label != null, "Credits view should expose source attribution label")
	_check(credits_view.policy_label != null, "Credits view should expose data policy label")
	if credits_view.source_label != null:
		_check(credits_view.source_label.text.contains("MIT"), "Credits view should explain MIT source-code scope")
	if credits_view.policy_label != null:
		_check(credits_view.policy_label.text.to_lower().contains("sentetik"), "Credits view should disclose synthetic data")
	scene.call("_show_dashboard")
	_check(not credits_view.visible, "dashboard action should hide CreditsView")
	_check(dashboard_nodes[0].visible, "dashboard action should restore dashboard nodes")

	var league = scene.get("league")
	var registered_context: Dictionary = league.team_contexts.get("kocaelispor", {})
	_check(registered_context.has("starting_xi"), "main scene should register managed starting XI context")
	_check(registered_context["starting_xi"].size() == 11, "managed context should contain 11 players")
	_check(String(registered_context["tactics"]["formation"]) == "4-3-3", "managed context should follow the applied formation")
	var initial_week: int = int(league.current_week)
	scene.call("_on_play_week_pressed")
	_check(int(league.current_week) == initial_week + 1, "weekly simulation should still advance one week")
	_check(league.fixtures[0]["result"].has("home_attack_strength"), "weekly result should include match profiles")
	_check(String(league.team_contexts["kocaelispor"]["tactics"]["formation"]) == "4-3-3", "play action should sync current tactics")
	_check(result_label.text.contains("Yönetilen maç:"), "match center should show managed match statistics")
	fixture_view.refresh()
	_check(fixture_view.summary_label.text.contains("1 oynandı"), "FixtureView should refresh after a played week")
	_check(String(fixture_view.fixture_list.get_child(0).get_child(3).text).contains("xG"), "FixtureView should show xG in played match row")
	scene.call("_on_save_pressed")
	_check(FileAccess.file_exists("user://tsl2027_save.json"), "save action should create the user save file")
	scene.call("_on_play_week_pressed")
	scene.call("_on_load_pressed")
	_check(int(league.current_week) == initial_week + 1, "load action should restore the saved week")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://tsl2027_save.json"))

	scene.call("_show_team_selection")
	_check(team_selection_view.visible, "Takım Seç action should show TeamSelectionView")
	_check(int(league.current_week) == initial_week + 1, "opening selector should not reset current season")
	team_selection_view.call("_on_team_selected", 1)
	team_selection_view.call("_on_start_pressed")
	league = scene.get("league")
	var selected_squad = scene.get("squad_state")
	_check(String(scene.get("managed_team_id")) == "fenerbahce", "new career should use selected team ID")
	_check(int(league.current_week) == 1, "new career should start at week one")
	_check(selected_squad.get_roster().size() == 18, "selected team should receive its own roster")
	_check(String(fixture_view.team_id) == "fenerbahce", "fixture view should follow selected team")
	_check(fixture_view.fixture_list.get_child_count() == 34, "selected team should receive 34 fixtures")

	scene.queue_free()
	if failures.is_empty():
		print("OK: main scene smoke test passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
