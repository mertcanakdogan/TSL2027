class_name LeagueState
extends RefCounted

const MatchEngineScript = preload("res://scripts/core/match_engine.gd")

var teams: Array = []
var standings: Dictionary = {}
var fixtures: Array = []
var current_week: int = 1
var season_seed: int = 2026
var team_contexts: Dictionary = {}
var error_message: String = ""
var match_engine = MatchEngineScript.new()

func initialize(team_records: Array, seed_value: int = 2026, context_records: Dictionary = {}) -> void:
	teams = team_records.duplicate(true)
	standings.clear()
	fixtures.clear()
	team_contexts = context_records.duplicate(true)
	current_week = 1
	season_seed = seed_value
	error_message = ""

	for team in teams:
		standings[String(team["id"])] = {
			"id": String(team["id"]),
			"name": String(team["name"]),
			"played": 0,
			"wins": 0,
			"draws": 0,
			"losses": 0,
			"goals_for": 0,
			"goals_against": 0,
			"points": 0
		}

	fixtures = _build_fixtures()

func _build_fixtures() -> Array:
	var circle: Array = teams.duplicate(true)
	var first_leg: Array = []
	var round_count: int = circle.size() - 1
	var matches_per_round: int = circle.size() / 2

	for round_index in range(round_count):
		for match_index in range(matches_per_round):
			var home: Dictionary = circle[match_index]
			var away: Dictionary = circle[circle.size() - 1 - match_index]

			if round_index % 2 == 1:
				var swapped: Dictionary = home
				home = away
				away = swapped

			first_leg.append({
				"id": "w%02d-%s-%s" % [round_index + 1, home["id"], away["id"]],
				"week": round_index + 1,
				"home_id": String(home["id"]),
				"away_id": String(away["id"]),
				"played": false,
				"result": {}
			})

		var last_team: Dictionary = circle.pop_back()
		circle.insert(1, last_team)

	var all_fixtures: Array = []
	for fixture in first_leg:
		all_fixtures.append(fixture)

	for fixture in first_leg:
		all_fixtures.append({
			"id": "%s-r" % fixture["id"],
			"week": int(fixture["week"]) + round_count,
			"home_id": String(fixture["away_id"]),
			"away_id": String(fixture["home_id"]),
			"played": false,
			"result": {}
		})

	return all_fixtures

func play_next_week() -> Array:
	if current_week > 34:
		return []

	var weekly_results: Array = []
	var week_fixtures: Array = []

	for fixture in fixtures:
		if int(fixture["week"]) == current_week:
			week_fixtures.append(fixture)

	for match_index in range(week_fixtures.size()):
		var fixture: Dictionary = week_fixtures[match_index]
		var home: Dictionary = get_team(String(fixture["home_id"]))
		var away: Dictionary = get_team(String(fixture["away_id"]))
		var seed_value: int = season_seed + (current_week * 100) + match_index

		var home_context: Dictionary = team_contexts.get(String(fixture["home_id"]), {})
		var away_context: Dictionary = team_contexts.get(String(fixture["away_id"]), {})
		var result: Dictionary = match_engine.simulate(home, away, seed_value, home_context, away_context)
		fixture["played"] = true
		fixture["result"] = result
		_apply_result(String(fixture["home_id"]), String(fixture["away_id"]), result)

		var enriched_result: Dictionary = result.duplicate(true)
		enriched_result["home_id"] = String(fixture["home_id"])
		enriched_result["away_id"] = String(fixture["away_id"])
		weekly_results.append(enriched_result)

	current_week += 1
	return weekly_results

func _apply_result(home_id: String, away_id: String, result: Dictionary) -> void:
	var home_row: Dictionary = standings[home_id]
	var away_row: Dictionary = standings[away_id]
	var home_goals: int = int(result["home_goals"])
	var away_goals: int = int(result["away_goals"])

	home_row["played"] += 1
	away_row["played"] += 1
	home_row["goals_for"] += home_goals
	home_row["goals_against"] += away_goals
	away_row["goals_for"] += away_goals
	away_row["goals_against"] += home_goals

	if home_goals > away_goals:
		home_row["wins"] += 1
		home_row["points"] += 3
		away_row["losses"] += 1
	elif away_goals > home_goals:
		away_row["losses"] += 1
		away_row["wins"] += 1
		away_row["points"] += 3
	else:
		home_row["draws"] += 1
		away_row["draws"] += 1
		home_row["points"] += 1
		away_row["points"] += 1

func get_team(team_id: String) -> Dictionary:
	for team in teams:
		if String(team["id"]) == team_id:
			return team
	return {}

func set_team_context(team_id: String, context: Dictionary) -> bool:
	if not standings.has(team_id):
		return false
	team_contexts[team_id] = context.duplicate(true)
	return true

func get_snapshot() -> Dictionary:
	return {
		"current_week": current_week,
		"season_seed": season_seed,
		"teams": teams.duplicate(true),
		"standings": standings.duplicate(true),
		"fixtures": fixtures.duplicate(true),
		"team_contexts": team_contexts.duplicate(true)
	}

func validate_snapshot(snapshot: Dictionary) -> bool:
	if not _is_integer_number(snapshot.get("current_week", null)) or int(snapshot["current_week"]) < 1 or int(snapshot["current_week"]) > 35:
		return _fail("Kayıt maç haftası geçersiz.")
	if not _is_integer_number(snapshot.get("season_seed", null)):
		return _fail("Kayıt sezon seed değeri geçersiz.")
	if typeof(snapshot.get("teams", null)) != TYPE_ARRAY or typeof(snapshot.get("standings", null)) != TYPE_DICTIONARY:
		return _fail("Kayıt lig verisi eksik.")
	if typeof(snapshot.get("fixtures", null)) != TYPE_ARRAY or typeof(snapshot.get("team_contexts", null)) != TYPE_DICTIONARY:
		return _fail("Kayıt fikstür/context verisi eksik.")
	var saved_teams: Array = snapshot["teams"]
	if saved_teams.size() != teams.size():
		return _fail("Kayıt takım sayısı mevcut sezonla eşleşmiyor.")
	var active_team_ids: Dictionary = {}
	for team in teams:
		active_team_ids[String(team.get("id", ""))] = true
	var saved_team_ids: Dictionary = {}
	for team in saved_teams:
		if typeof(team) != TYPE_DICTIONARY or not team.has("id"):
			return _fail("Kayıt takım listesinde geçersiz kayıt var.")
		saved_team_ids[String(team["id"])] = true
	if saved_team_ids != active_team_ids:
		return _fail("Kayıt takımları mevcut sezonla eşleşmiyor.")
	var saved_standings: Dictionary = snapshot["standings"]
	if saved_standings.size() != active_team_ids.size():
		return _fail("Kayıt puan durumu takım sayısıyla eşleşmiyor.")
	for team_id in active_team_ids:
		if not saved_standings.has(team_id):
			return _fail("Kayıt puan durumunda takım eksik: %s" % team_id)
	var saved_fixtures: Array = snapshot["fixtures"]
	if saved_fixtures.size() != fixtures.size():
		return _fail("Kayıt fikstür uzunluğu mevcut sezonla eşleşmiyor.")
	for fixture in saved_fixtures:
		if typeof(fixture) != TYPE_DICTIONARY:
			return _fail("Kayıt fikstüründe geçersiz maç var.")
		if not fixture.has("id") or not fixture.has("week") or not fixture.has("home_id") or not fixture.has("away_id") or not fixture.has("played") or not fixture.has("result"):
			return _fail("Kayıt fikstür maçı eksik alan içeriyor.")
		if int(fixture["week"]) < 1 or int(fixture["week"]) > 34:
			return _fail("Kayıt fikstür haftası geçersiz.")
		if not active_team_ids.has(String(fixture["home_id"])) or not active_team_ids.has(String(fixture["away_id"])):
			return _fail("Kayıt fikstürü bilinmeyen takım içeriyor.")
	return true

func restore_snapshot(snapshot: Dictionary) -> bool:
	if not validate_snapshot(snapshot):
		return false
	current_week = int(snapshot["current_week"])
	season_seed = int(snapshot["season_seed"])
	teams = snapshot["teams"].duplicate(true)
	standings = snapshot["standings"].duplicate(true)
	fixtures = snapshot["fixtures"].duplicate(true)
	team_contexts = snapshot["team_contexts"].duplicate(true)
	error_message = ""
	return true

func _fail(message: String) -> bool:
	error_message = message
	return false

func _is_integer_number(value) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	return float(value) == round(float(value))

func get_table() -> Array:
	var rows: Array = []

	for team in teams:
		var team_id: String = String(team["id"])
		var row: Dictionary = standings[team_id].duplicate(true)
		row["strength"] = int(team.get("strength", 50))
		row["goal_difference"] = int(row["goals_for"]) - int(row["goals_against"])
		rows.append(row)

	rows.sort_custom(_table_sorter)
	return rows

func _table_sorter(a: Dictionary, b: Dictionary) -> bool:
	if int(a["points"]) != int(b["points"]):
		return int(a["points"]) > int(b["points"])
	if int(a["goal_difference"]) != int(b["goal_difference"]):
		return int(a["goal_difference"]) > int(b["goal_difference"])
	if int(a["goals_for"]) != int(b["goals_for"]):
		return int(a["goals_for"]) > int(b["goals_for"])
	return int(a["strength"]) > int(b["strength"])

func get_season_summary() -> Dictionary:
	if current_week <= 34:
		return {}
	var table: Array = get_table()
	if table.is_empty():
		return {}
	var relegated: Array = []
	var relegation_start: int = max(1, table.size() - 3)
	for index in range(relegation_start, table.size()):
		relegated.append(table[index].duplicate(true))
	return {
		"champion": table[0].duplicate(true),
		"relegated": relegated
	}

func get_next_fixture_for_team(team_id: String) -> Dictionary:
	for fixture in fixtures:
		if bool(fixture["played"]):
			continue
		if String(fixture["home_id"]) == team_id or String(fixture["away_id"]) == team_id:
			return fixture
	return {}

func get_fixtures_for_team(team_id: String) -> Array:
	var team_fixtures: Array = []
	for fixture in fixtures:
		if String(fixture["home_id"]) == team_id or String(fixture["away_id"]) == team_id:
			team_fixtures.append(fixture.duplicate(true))
	return team_fixtures
