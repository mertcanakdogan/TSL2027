extends SceneTree

const DataPackScript = preload("res://scripts/core/data_pack.gd")
const LeagueStateScript = preload("res://scripts/core/league_state.gd")
const SquadStateScript = preload("res://scripts/core/squad_state.gd")
const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")
const EconomyStateScript = preload("res://scripts/core/economy_state.gd")
const TransferMarketStateScript = preload("res://scripts/core/transfer_market_state.gd")
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
	_check(squad.apply_formation("4-3-3"), "test lineup should follow the saved formation")
	_check(tactics.set_mentality("positive"), "test mentality should update")
	var economy = EconomyStateScript.new()
	_check(economy.initialize("kocaelispor", 61, data_pack.rules["economy"], data_pack.get_team_squad("kocaelispor")), "test economy should initialize")
	var transfer_market = TransferMarketStateScript.new()
	_check(transfer_market.initialize(data_pack.players, "kocaelispor"), "test transfer market should initialize")
	var signed_offer: Dictionary = transfer_market.get_offers(1)[0]
	_check(transfer_market.sign_player(String(signed_offer["player"]["id"]), squad, economy), "test transfer should update saved dynamic roster")
	var first_player_id: String = String(squad.get_starting_xi()[0]["id"])
	var bench_player_id: String = String(squad.get_bench()[0]["id"])
	_check(squad.swap_players(first_player_id, bench_player_id), "test lineup should update")

	var league = LeagueStateScript.new()
	league.initialize(data_pack.teams, 2026)
	_check(league.play_next_week().size() == 9, "one week should produce nine results")
	var saved_week: int = league.current_week
	var saved_starting: Array = squad.starting_ids.duplicate()
	var saver = SaveGameScript.new()
	_check(saver.save_to_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version), "save should succeed")
	_check(saver.last_load_source == "", "save should not set load source")
	var saved_payload: Dictionary = saver.last_payload
	_check(int(saved_payload["save_schema_version"]) == SaveGameScript.SAVE_SCHEMA_VERSION, "save schema version should be explicit")
	_check(String(saved_payload["data_schema_version"]) == data_pack.schema_version, "data schema version should be explicit")
	_check(String(saved_payload["squad_state"]["formation"]) == "4-3-3", "save should include the active squad formation")
	_check(saved_payload["squad_state"]["roster"].size() == 19, "save should include the dynamic roster")
	_check(saved_payload.has("economy_state") and saved_payload.has("transfer_state"), "save should include economy and transfer state")
	_check(saver.save_to_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version), "second save should succeed")
	_check(FileAccess.file_exists(SAVE_PATH + SaveGameScript.BACKUP_SUFFIX), "second save should preserve a backup")

	_check(league.play_next_week().size() == 9, "runtime mutation should advance another week")
	_check(tactics.set_mentality("attacking"), "runtime mutation should change mentality")
	_check(saver.load_from_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version, "kocaelispor"), "load should restore saved state")
	_check(saver.last_load_source == "primary", "valid load should use the primary save")
	_check(league.current_week == saved_week, "load should restore current week")
	_check(squad.starting_ids == saved_starting, "load should restore starting IDs")
	_check(tactics.mentality == "positive", "load should restore tactics")
	_check(squad.get_active_formation() == "4-3-3", "load should restore active squad formation")
	_check(squad.get_roster().size() == 19, "load should restore the dynamic roster")
	_check(not economy.get_contract(String(signed_offer["player"]["id"])).is_empty(), "load should restore signed player contract")
	_check(not transfer_market.has_offer(String(signed_offer["player"]["id"])), "load should restore signed player market removal")
	_check(bool(league.fixtures[0]["played"]), "load should restore played fixture state")

	var week_before_bad_load: int = league.current_week
	var tactics_before_bad_load: String = tactics.mentality
	_check(not saver.load_from_file("user://missing-tsl2027-save.json", league, squad, tactics, economy, transfer_market, data_pack.schema_version, "kocaelispor"), "missing save should fail")
	_check(league.current_week == week_before_bad_load and tactics.mentality == tactics_before_bad_load, "missing save should not mutate state")

	var corrupt_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()
	_check(saver.load_from_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version, "kocaelispor"), "corrupt primary save should recover from backup")
	_check(saver.last_load_source == "backup", "corrupt primary save should report backup source")
	_check(league.current_week == week_before_bad_load and tactics.mentality == tactics_before_bad_load, "backup recovery should restore the saved state")

	var wrong_version_payload: Dictionary = saved_payload.duplicate(true)
	wrong_version_payload["data_schema_version"] = "future-99"
	var wrong_version_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	wrong_version_file.store_string(JSON.stringify(wrong_version_payload))
	wrong_version_file.close()
	var wrong_version_backup := FileAccess.open(SAVE_PATH + SaveGameScript.BACKUP_SUFFIX, FileAccess.WRITE)
	wrong_version_backup.store_string(JSON.stringify(wrong_version_payload))
	wrong_version_backup.close()
	_check(not saver.load_from_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version, "kocaelispor"), "wrong data schema should fail")
	_check(league.current_week == week_before_bad_load and tactics.mentality == tactics_before_bad_load, "wrong schema should not mutate state")

	var mismatch_payload: Dictionary = saved_payload.duplicate(true)
	mismatch_payload["tactics_state"]["formation"] = "4-4-2"
	var mismatch_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	mismatch_file.store_string(JSON.stringify(mismatch_payload))
	mismatch_file.close()
	var mismatch_backup := FileAccess.open(SAVE_PATH + SaveGameScript.BACKUP_SUFFIX, FileAccess.WRITE)
	mismatch_backup.store_string(JSON.stringify(mismatch_payload))
	mismatch_backup.close()
	_check(not saver.load_from_file(SAVE_PATH, league, squad, tactics, economy, transfer_market, data_pack.schema_version, "kocaelispor"), "mismatched squad and tactics formation should fail")
	_check(squad.get_active_formation() == "4-3-3" and tactics.formation == "4-3-3" and tactics.mentality == tactics_before_bad_load, "mismatched load should not mutate current state")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + SaveGameScript.BACKUP_SUFFIX))
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
