extends SceneTree

const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")

var failures: Array = []

func _init() -> void:
	_run()

func _run() -> void:
	var state = TacticsStateScript.new()
	_check(state.initialize(), "tactics state should initialize")

	var defaults: Dictionary = state.get_snapshot()
	_check(String(defaults["formation"]) == "4-4-2", "default formation should be 4-4-2")
	_check(String(defaults["mentality"]) == "balanced", "default mentality should be balanced")
	_check(String(defaults["marking_approach"]) == "zonal", "default marking should be zonal")
	for parameter in state.NUMERIC_PARAMETERS:
		_check(int(defaults[parameter]) == 50, "%s should default to 50" % parameter)

	_check(state.set_formation("4-3-3"), "supported formation should be accepted")
	_check(state.set_mentality("positive"), "supported mentality should be accepted")
	_check(state.set_marking_approach("man_oriented"), "supported marking should be accepted")
	_check(state.set_parameter("tempo", 0), "numeric lower bound should be accepted")
	_check(state.set_parameter("press_intensity", 100), "numeric upper bound should be accepted")

	var changed: Dictionary = state.get_snapshot()
	_check(String(changed["formation"]) == "4-3-3", "formation update should persist")
	_check(String(changed["mentality"]) == "positive", "mentality update should persist")
	_check(String(changed["marking_approach"]) == "man_oriented", "marking update should persist")
	_check(int(changed["tempo"]) == 0, "lower-bound value should persist")
	_check(int(changed["press_intensity"]) == 100, "upper-bound value should persist")

	var before_invalid: Dictionary = state.get_snapshot()
	_check(not state.set_formation("2-2-6"), "unsupported formation should be rejected")
	_check(not state.set_mentality("chaos"), "unsupported mentality should be rejected")
	_check(not state.set_marking_approach("random"), "unsupported marking should be rejected")
	_check(not state.set_parameter("tempo", -1), "numeric value below zero should be rejected")
	_check(not state.set_parameter("tempo", 101), "numeric value above 100 should be rejected")
	_check(state.get_snapshot() == before_invalid, "invalid changes should not mutate state")
	_check(not state.initialize({"formation": "3-5-2", "tempo": 101}), "invalid initialization should be rejected")
	_check(state.get_snapshot() == before_invalid, "invalid initialization should be atomic")

	var snapshot: Dictionary = state.get_snapshot()
	snapshot["formation"] = "mutated_outside_state"
	_check(String(state.get_snapshot()["formation"]) == "4-3-3", "snapshot should not expose mutable state")

	if failures.is_empty():
		print("OK: tactics state tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
