class_name SaveGame
extends RefCounted

const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")
const SAVE_SCHEMA_VERSION := 2

var error_message: String = ""
var last_payload: Dictionary = {}

func save_to_file(path: String, league, squad, tactics, data_schema_version: String) -> bool:
	error_message = ""
	if not _is_user_path(path):
		return _fail("Kayıt yalnızca user:// altında yazılabilir.")
	last_payload = build_payload(league, squad, tactics, data_schema_version)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _fail("Kayıt dosyası açılamadı: %s" % path)
	file.store_string(JSON.stringify(last_payload, "\t"))
	file.close()
	return true

func load_from_file(
	path: String,
	league,
	squad,
	tactics,
	expected_data_schema_version: String,
	expected_team_id: String
) -> bool:
	error_message = ""
	var payload: Dictionary = _read_payload(path)
	if payload.is_empty():
		return false
	if not _validate_payload(payload, league, squad, tactics, expected_data_schema_version, expected_team_id):
		return false

	var old_league: Dictionary = league.get_snapshot()
	var old_squad: Dictionary = squad.get_snapshot()
	var old_tactics: Dictionary = tactics.get_snapshot()
	if not league.restore_snapshot(payload["league_state"]):
		return _fail(league.error_message)
	if not squad.restore_snapshot(payload["squad_state"]):
		league.restore_snapshot(old_league)
		return _fail(squad.error_message)
	if not tactics.initialize(payload["tactics_state"]):
		league.restore_snapshot(old_league)
		squad.restore_snapshot(old_squad)
		tactics.initialize(old_tactics)
		return _fail(tactics.error_message)
	last_payload = payload.duplicate(true)
	return true

func build_payload(league, squad, tactics, data_schema_version: String) -> Dictionary:
	return {
		"save_schema_version": SAVE_SCHEMA_VERSION,
		"data_schema_version": data_schema_version,
		"season": "2026-2027",
		"managed_team_id": squad.team_id,
		"league_state": league.get_snapshot(),
		"squad_state": squad.get_snapshot(),
		"tactics_state": tactics.get_snapshot()
	}

func _read_payload(path: String) -> Dictionary:
	if not _is_user_path(path):
		_fail("Kayıt yalnızca user:// altında okunabilir.")
		return {}
	if not FileAccess.file_exists(path):
		_fail("Kayıt dosyası bulunamadı: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Kayıt dosyası açılamadı: %s" % path)
		return {}
	var parser := JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or typeof(parser.data) != TYPE_DICTIONARY:
		_fail("Kayıt dosyası geçerli bir JSON nesnesi değil: %s" % parser.get_error_message())
		return {}
	return parser.data

func _validate_payload(
	payload: Dictionary,
	league,
	squad,
	tactics,
	expected_data_schema_version: String,
	expected_team_id: String
) -> bool:
	if int(payload.get("save_schema_version", -1)) != SAVE_SCHEMA_VERSION:
		return _fail("Desteklenmeyen kayıt sürümü.")
	if String(payload.get("data_schema_version", "")) != expected_data_schema_version:
		return _fail("Kayıt veri paketi sürümüyle eşleşmiyor.")
	if String(payload.get("managed_team_id", "")) != expected_team_id or squad.team_id != expected_team_id:
		return _fail("Kayıt yönetilen takımla eşleşmiyor.")
	if typeof(payload.get("league_state", null)) != TYPE_DICTIONARY or typeof(payload.get("squad_state", null)) != TYPE_DICTIONARY or typeof(payload.get("tactics_state", null)) != TYPE_DICTIONARY:
		return _fail("Kayıt state bölümleri eksik.")
	if not league.validate_snapshot(payload["league_state"]):
		return _fail(league.error_message)
	if not squad.validate_snapshot(payload["squad_state"]):
		return _fail(squad.error_message)
	var tactics_probe = TacticsStateScript.new()
	if not tactics_probe.initialize(payload["tactics_state"]):
		return _fail(tactics_probe.error_message)
	var saved_formation := String(payload["squad_state"].get("formation", "4-4-2"))
	if saved_formation != tactics_probe.formation:
		return _fail("Kayıt kadro ve taktik dizilişiyle eşleşmiyor.")
	return true

func _is_user_path(path: String) -> bool:
	return path.begins_with("user://")

func _fail(message: String) -> bool:
	error_message = message
	return false
