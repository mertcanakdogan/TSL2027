extends SceneTree

const SquadStateScript = preload("res://scripts/core/squad_state.gd")

var failures: Array = []

func _init() -> void:
	_run_tests()
	if failures.is_empty():
		print("OK: squad state tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _run_tests() -> void:
	var roster: Array = _build_roster()
	var state = SquadStateScript.new()
	_check(state.initialize("kocaelispor", roster), "valid roster should initialize")
	_check(state.get_starting_xi().size() == 11, "starting XI should contain 11 players")
	_check(state.get_bench().size() == 7, "bench should contain 7 players")
	_check(_position_counts(state.get_starting_xi()) == {"GK": 1, "DF": 4, "MF": 4, "FW": 2}, "default XI should be 4-4-2")
	_check(state.get_active_formation() == "4-4-2", "default active formation should be 4-4-2")
	_check(_all_roster_players_are_grouped(state, roster), "every roster player should belong to one group")
	for formation in ["4-4-2", "4-3-3", "4-2-3-1", "3-5-2", "5-3-2"]:
		var requirements: Dictionary = state.get_formation_requirements(formation)
		_check(int(requirements.get("GK", 0)) == 1, "%s should require one goalkeeper" % formation)
		_check(_sum_counts(requirements) == 11, "%s should require exactly 11 players" % formation)
		_check(state.can_apply_formation(formation), "%s should be supported by the prototype roster" % formation)
	_check(state.apply_formation("4-3-3"), "supported formation should apply to the lineup")
	_check(state.get_active_formation() == "4-3-3", "applied formation should become active")
	_check(_position_counts(state.get_starting_xi()) == {"GK": 1, "DF": 4, "MF": 3, "FW": 3}, "4-3-3 should rebuild the XI by position")

	var formation_starter_ids: Array = state.starting_ids.duplicate()
	var formation_bench_ids: Array = state.bench_ids.duplicate()
	var starting_defender := _find_player_id(state.get_starting_xi(), "DF")
	var bench_midfielder := _find_player_id(state.get_bench(), "MF")
	_check(not starting_defender.is_empty() and not bench_midfielder.is_empty(), "test should find incompatible swap candidates")
	_check(not state.swap_players(starting_defender, bench_midfielder), "swap breaking active formation should fail")
	_check(state.starting_ids == formation_starter_ids and state.bench_ids == formation_bench_ids, "invalid formation swap should not mutate groups")
	_check(state.apply_formation("5-3-2"), "second supported formation should apply to the lineup")
	_check(_position_counts(state.get_starting_xi()) == {"GK": 1, "DF": 5, "MF": 3, "FW": 2}, "5-3-2 should rebuild the XI by position")

	var insufficient_roster: Array = roster.duplicate(true)
	insufficient_roster.pop_back()
	insufficient_roster.pop_back()
	var insufficient_state = SquadStateScript.new()
	_check(insufficient_state.initialize("kocaelispor", insufficient_roster), "roster with three forwards should support default formation")
	var insufficient_snapshot: Dictionary = insufficient_state.get_snapshot()
	_check(not insufficient_state.apply_formation("4-3-3"), "formation should fail when roster lacks a required position")
	_check(insufficient_state.get_snapshot() == insufficient_snapshot, "failed formation apply should not mutate state")

	var starter_id := String(state.get_starting_xi()[0]["id"])
	var bench_id := String(state.get_bench()[0]["id"])
	_check(not state.swap_players("missing", bench_id), "unknown player swap should fail")
	_check(not state.swap_players(starter_id, String(state.get_starting_xi()[1]["id"])), "same-group swap should fail")
	_check(state.swap_players(starter_id, bench_id), "starter and bench swap should succeed")
	_check(state.get_player_group(starter_id) == "bench", "old starter should move to bench")
	_check(state.get_player_group(bench_id) == "starting", "old bench player should move to starting XI")
	_check(state.get_starting_xi().size() == 11 and state.get_bench().size() == 7, "swap should preserve group sizes")

	var duplicate_roster: Array = roster.duplicate(true)
	duplicate_roster[1]["id"] = duplicate_roster[0]["id"]
	var duplicate_state = SquadStateScript.new()
	_check(not duplicate_state.initialize("kocaelispor", duplicate_roster), "duplicate IDs should fail initialization")
	_check(not duplicate_state.error_message.is_empty(), "invalid initialization should expose an error")

func _build_roster() -> Array:
	var positions := [
		"GK", "GK",
		"DF", "DF", "DF", "DF", "DF", "DF",
		"MF", "MF", "MF", "MF", "MF", "MF",
		"FW", "FW", "FW", "FW"
	]
	var roster: Array = []
	for index in range(positions.size()):
		roster.append({
			"id": "player_%02d" % index,
			"team_id": "kocaelispor",
			"position": positions[index],
			"display_name": "Test Player %02d" % index
		})
	return roster

func _position_counts(players: Array) -> Dictionary:
	var counts := {"GK": 0, "DF": 0, "MF": 0, "FW": 0}
	for player in players:
		var position := String(player["position"])
		counts[position] = int(counts.get(position, 0)) + 1
	return counts

func _all_roster_players_are_grouped(state, roster: Array) -> bool:
	for player in roster:
		var group: String = state.get_player_group(String(player["id"]))
		if group != "starting" and group != "bench":
			return false
	return true

func _sum_counts(counts: Dictionary) -> int:
	var total := 0
	for value in counts.values():
		total += int(value)
	return total

func _find_player_id(players: Array, position: String) -> String:
	for player in players:
		if String(player.get("position", "")) == position:
			return String(player.get("id", ""))
	return ""

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
