extends SceneTree

const CompetitionRulesScript = preload("res://scripts/core/competition_rules.gd")
const DataPackScript = preload("res://scripts/core/data_pack.gd")

var failures: Array = []

func _init() -> void:
	_run()
	if failures.is_empty():
		print("OK: competition rules tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(String(failure))
	quit(1)

func _run() -> void:
	var data_pack = DataPackScript.new()
	_check(data_pack.load_from_files("res://data/teams.json", "res://data/players.json", "res://data/game_rules.json"), "data pack should expose valid competition rules: %s" % data_pack.error_message)
	_check(data_pack.competition_rules != null, "data pack should build a competition rules object: %s" % data_pack.error_message)
	if data_pack.competition_rules != null:
		var snapshot: Dictionary = data_pack.competition_rules.get_snapshot()
		_check(String(snapshot["season"]) == "2026-2027", "rules should expose the configured season")
		_check(int(snapshot["weeks"]) == 34, "rules should expose the configured season length")
		_check(int(snapshot["max_roster_size"]) == 28, "rules should expose the configured roster limit")
		_check(int(snapshot["bench_size"]) == 7, "rules should expose the configured bench size")

	var custom = CompetitionRulesScript.new()
	_check(custom.initialize(_custom_payload()), "a coherent alternate competition should be accepted: %s" % custom.error_message)
	_check(custom.weeks == 6, "alternate competition should preserve its week count")
	_check(custom.max_roster_size == 20, "alternate competition should preserve its roster limit")

	var invalid = CompetitionRulesScript.new()
	var invalid_payload := _custom_payload()
	invalid_payload["competition"]["weeks"] = 5
	_check(not invalid.initialize(invalid_payload), "a competition with inconsistent rounds and weeks should fail")

func _custom_payload() -> Dictionary:
	return {
		"schema_version": "0.1.0",
		"season": "test-season",
		"competition": {
			"team_count": 4,
			"rounds": 2,
			"weeks": 6,
			"matchday_squad_size": 20,
			"max_substitutions": 5
		},
		"squad": {
			"max_a_team_players": 20,
			"bench_size": 7,
			"max_foreign_players": 14,
			"min_national_team_eligible_players": 14,
			"min_young_national_team_eligible_players": 4,
			"max_goalkeepers": 3,
			"min_eligible_goalkeepers": 2
		},
		"economy": {
			"transfer_window_end_week": 2
		}
	}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
