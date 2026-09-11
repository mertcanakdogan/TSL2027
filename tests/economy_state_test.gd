extends SceneTree

const EconomyStateScript = preload("res://scripts/core/economy_state.gd")

var failures: Array = []

func _init() -> void:
	var rules := {
		"initial_balance_base": 1000000,
		"initial_balance_per_strength": 10000,
		"weekly_revenue_base": 100000,
		"weekly_revenue_per_strength": 1000,
		"weekly_wage_budget_base": 1000000,
		"weekly_wage_budget_per_strength": 1000
	}
	var roster := _build_roster()
	var state = EconomyStateScript.new()
	_check(state.initialize("kocaelispor", 61, rules, roster), "economy should initialize")
	var repeat = EconomyStateScript.new()
	_check(repeat.initialize("kocaelispor", 61, rules, roster), "same economy should initialize")
	_check(state.get_snapshot() == repeat.get_snapshot(), "same inputs should create deterministic economy")
	_check(state.committed_wages > 0, "initial contracts should commit wages")

	var before_settlement: Dictionary = state.get_snapshot()
	_check(state.advance_week(1), "week one settlement should succeed")
	var after_settlement: Dictionary = state.get_snapshot()
	_check(after_settlement["last_settled_week"] == 1, "settlement should record week one")
	_check(after_settlement["balance"] != before_settlement["balance"], "settlement should change balance")
	var settled_again: Dictionary = after_settlement.duplicate(true)
	_check(not state.advance_week(1), "same week should not settle twice")
	_check(state.get_snapshot() == settled_again, "duplicate settlement should not mutate economy")

	var before_failed_transfer: Dictionary = state.get_snapshot()
	_check(not state.register_transfer("new_player", 999999999, 999999999, 52), "over-budget transfer should fail")
	_check(state.get_snapshot() == before_failed_transfer, "failed transfer should not mutate economy")
	_check(state.register_transfer("new_player", 1000, 1000, 52), "affordable transfer should succeed")
	_check(state.get_contract("new_player").get("weekly_wage", 0) == 1000, "signed contract should be stored")

	var restored = EconomyStateScript.new()
	_check(restored.initialize("kocaelispor", 61, rules, roster), "restore target should initialize")
	_check(restored.restore_snapshot(state.get_snapshot()), "economy snapshot should restore")
	_check(restored.get_snapshot() == state.get_snapshot(), "economy snapshot round trip should be exact")

	if failures.is_empty():
		print("OK: economy state tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(String(failure))
	quit(1)

func _build_roster() -> Array:
	var roster: Array = []
	for index in range(18):
		roster.append({
			"id": "player_%02d" % index,
			"team_id": "kocaelispor",
			"position": "GK" if index < 2 else ("DF" if index < 8 else ("MF" if index < 14 else "FW")),
			"age": 20 + index,
			"attributes": {"rating": 60 + index}
		})
	return roster

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
