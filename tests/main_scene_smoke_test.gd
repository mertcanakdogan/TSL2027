extends SceneTree

var failures: Array = []

func _init() -> void:
	_run()

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene._ready()

	var squad_view = scene.get("squad_view")
	var dashboard_nodes: Array = scene.get("dashboard_nodes")
	_check(squad_view != null, "main scene should create SquadView")
	_check(not squad_view.visible, "dashboard should be visible by default")
	_check(dashboard_nodes.size() > 0, "main scene should register dashboard nodes")

	scene.call("_show_squad")
	_check(squad_view.visible, "Kadro action should show SquadView")
	_check(not dashboard_nodes[0].visible, "Kadro action should hide dashboard nodes")

	scene.call("_show_dashboard")
	_check(not squad_view.visible, "dashboard action should hide SquadView")
	_check(dashboard_nodes[0].visible, "dashboard action should show dashboard nodes")

	var league = scene.get("league")
	var initial_week: int = int(league.current_week)
	scene.call("_on_play_week_pressed")
	_check(int(league.current_week) == initial_week + 1, "weekly simulation should still advance one week")

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
