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
	var dashboard_nodes: Array = scene.get("dashboard_nodes")
	_check(squad_view != null, "main scene should create SquadView")
	_check(tactics_view != null, "main scene should create TacticsView")
	_check(tactics_state != null, "main scene should create TacticsState")
	_check(String(tactics_state.formation) == "4-4-2", "main scene should use the default formation")
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
	_check(String(tactics_state.formation) == "4-3-3", "Taktikler view should update formation state")
	tactics_view.call("_on_parameter_changed", 80.0, "tempo")
	_check(int(tactics_state.tempo) == 80, "Taktikler view should update numeric state")

	scene.call("_show_dashboard")
	_check(not squad_view.visible, "dashboard action should hide SquadView")
	_check(not tactics_view.visible, "dashboard action should hide TacticsView")
	_check(dashboard_nodes[0].visible, "dashboard action should show dashboard nodes")

	var league = scene.get("league")
	var registered_context: Dictionary = league.team_contexts.get("kocaelispor", {})
	_check(registered_context.has("starting_xi"), "main scene should register managed starting XI context")
	_check(registered_context["starting_xi"].size() == 11, "managed context should contain 11 players")
	_check(String(registered_context["tactics"]["formation"]) == "4-3-3", "managed context should carry current tactics")
	var initial_week: int = int(league.current_week)
	scene.call("_on_play_week_pressed")
	_check(int(league.current_week) == initial_week + 1, "weekly simulation should still advance one week")
	_check(league.fixtures[0]["result"].has("home_attack_strength"), "weekly result should include match profiles")

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
