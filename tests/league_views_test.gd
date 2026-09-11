extends SceneTree

const LeagueStateScript = preload("res://scripts/core/league_state.gd")

var failures: Array = []

func _init() -> void:
	var league = LeagueStateScript.new()
	league.initialize([
		{"id": "a", "name": "A", "strength": 60},
		{"id": "b", "name": "B", "strength": 60},
		{"id": "c", "name": "C", "strength": 60},
		{"id": "d", "name": "D", "strength": 60}
	], 2026)

	var team_fixtures: Array = league.get_fixtures_for_team("a")
	_check(team_fixtures.size() == 6, "four-team double round robin should give six fixtures")
	for fixture in team_fixtures:
		_check(String(fixture["home_id"]) == "a" or String(fixture["away_id"]) == "a", "fixture query should only return managed matches")

	team_fixtures[0]["played"] = true
	_check(not bool(league.fixtures[0]["played"]), "fixture query should return deep copies")
	var results: Array = league.play_next_week()
	_check(not results.is_empty(), "league should produce results for the first week")
	_check(results[0].has("events") and results[0].has("match_stats"), "league result should preserve match events and stats")
	var played_fixture: Dictionary = league.get_fixtures_for_team("a")[0]
	_check(bool(played_fixture["played"]), "fixture query should expose played state")
	_check(played_fixture["result"].has("events"), "played fixture should retain event list")

	if failures.is_empty():
		print("OK: league view data tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
