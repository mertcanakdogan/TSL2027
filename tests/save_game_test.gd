extends SceneTree

const DataPackScript = preload("res://scripts/core/data_pack.gd")
const LeagueStateScript = preload("res://scripts/core/league_state.gd")
const SquadStateScript = preload("res://scripts/core/squad_state.gd")
const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")
const SaveGameScript = preload("res://scripts/core/save_game.gd")

var failures: Array = []
const SAVE_PATH := "user://tsl2027_save_game_test.json"

func _init() -> void:
	var data_pack = DataPackScript.new()
	_check(data_pack.load_from_files("res://data/teams.json", "res://data/players.json", "res://data/game_rules.json"), "test data pack should load")

	var squad = SquadStateScript.new()
	_check(squad.initialize("kocaelispor", data_pack.get_team_squad("kocaelispor")), "test squad should initialize")
	var tactics = TacticsStateScript.new()
	_check(tactics.initialize(), "test tactics should initialize")
	_check(tactics.set_formation("4-3-3"), "test formation should update")
	_check(tactics.set_mentality("positive"), "test mentality should update")
	var first_player_id: String = String(squad.get_starting_xi()[0]["id"])
	var bench_player_id: String = String(squad.get_bench()[0]["id"])
	_check(squad.swap_players(first_player_id, bench_player_id), "test lineup should update")

	var league = LeagueStateScript.new()
	league.initialize(data_pack.teams, 2026)
	_check(league.play_next_week().size() == 9, "one week should produce nine results")
	var saved_week: int = league.current_week
	var saved_starting: Array = squad.starting_ids.duplicate()
	var saver = SaveGameScript.new()
	_check(saver.save_to_file(SAVE_PATH, league, squad, tactics, data_pack.schema_version), "save should succeed")
	var saved_payload: Dictionary = saver.last_payload
	_check(int(saved_payload["save_schema_version"]) == SaveGameScript.SAVE_SCHEMA_VERSION, "save schema version should be explicit")
	_check(String(saved_payload["data_schema_version"]) == data_pack.schema_version, "data schema version should be explicit")

	_check(league.play_next_week().size() == 9, "runtime mutation should advance another week")
	_check(tactics.set_mentality("attacking"), "runtime mutation should change mentality")
	_check(saver.load_from_file(SAVE_PATH, league, squad, tactics, data_pack.schema_version, "kocaelispor"), "load should restore saved state")
	_check(league.current_week == saved_week, "load should restore current week")
	_check(squad.starting_ids == saved_starting, "load should restore starting IDs")
	_check(tactics.mentality == "positive", "load should restore tactics")
	_check(bool(league.fixtures[0]["played"]), "load should restore played fixture state")

	var week_before_bad_load: int = league.current_week
	var tactics_before_bad_load: String = tactics.mentality
	_check(not saver.load_from_file("user://missing-tsl2027-save.json", league, squad, tactics, data_pack.schema_version, "kocaelispor"), "missing save should fail")
	_check(league.current_week == week_before_bad_load and tactics.mentality == tactics_before_bad_load, "missing save should not mutate state")

	var corrupt_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()
	_check(not saver.load_from_file(SAVE_PATH, league, squad, tactics, data_pack.schema_version, "kocaelispor"), "corrupt save should fail")
	_check(not saver.error_message.is_empty(), "corrupt save should expose an error")

	var wrong_version_payload: Dictionary = saved_payload.duplicate(true)
	wrong_version_payload["data_schema_version"] = "future-99"
	var wrong_version_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	wrong_version_file.store_string(JSON.stringify(wrong_version_payload))
	wrong_version_file.close()
	_check(not saver.load_from_file(SAVE_PATH, league, squad, tactics, data_pack.schema_version, "kocaelispor"), "wrong data schema should fail")
	_check(league.current_week == week_before_bad_load and tactics.mentality == tactics_before_bad_load, "wrong schema should not mutate state")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if failures.is_empty():
		print("OK: save game tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
