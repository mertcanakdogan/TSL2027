class_name SaveGame
extends RefCounted

const TacticsStateScript = preload("res://scripts/core/tactics_state.gd")
const SAVE_SCHEMA_VERSION := 4
const LEGACY_SAVE_SCHEMA_VERSION := 3
const TEMP_SUFFIX := ".tmp"
const BACKUP_SUFFIX := ".bak"

var error_message: String = ""
var last_payload: Dictionary = {}
var last_load_source: String = ""

func save_to_file(path: String, league, squad, tactics, economy, transfer, data_schema_version: String) -> bool:
	error_message = ""
	if not _is_user_path(path):
		return _fail("Kayıt yalnızca user:// altında yazılabilir.")
	var payload: Dictionary = build_payload(league, squad, tactics, economy, transfer, data_schema_version)
	var temporary_path: String = path + TEMP_SUFFIX
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _fail("Geçici kayıt dosyası açılamadı: %s" % temporary_path)
	file.store_string(JSON.stringify(payload, "\t"))
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return _fail("Geçici kayıt dosyasına yazılamadı: %s" % write_error)
	if not _commit_temporary_save(path, temporary_path):
		return false
	last_payload = payload
	return true

func load_from_file(
	path: String,
	league,
	squad,
	tactics,
	economy,
	transfer,
	expected_data_schema_version: String,
	expected_team_id: String
) -> bool:
	error_message = ""
	last_load_source = ""
	var payload: Dictionary = _read_payload_with_backup(path)
	if payload.is_empty():
		return false
	payload = _migrate_payload(payload)
	if not _validate_payload(payload, league, squad, tactics, economy, transfer, expected_data_schema_version, expected_team_id):
		return false

	var old_league: Dictionary = league.get_snapshot()
	var old_squad: Dictionary = squad.get_snapshot()
	var old_tactics: Dictionary = tactics.get_snapshot()
	var old_economy: Dictionary = economy.get_snapshot()
	var old_transfer: Dictionary = transfer.get_snapshot()
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
	if not economy.restore_snapshot(payload["economy_state"]):
		league.restore_snapshot(old_league)
		squad.restore_snapshot(old_squad)
		tactics.initialize(old_tactics)
		economy.restore_snapshot(old_economy)
		return _fail(economy.error_message)
	if not transfer.restore_snapshot(payload["transfer_state"]):
		league.restore_snapshot(old_league)
		squad.restore_snapshot(old_squad)
		tactics.initialize(old_tactics)
		economy.restore_snapshot(old_economy)
		transfer.restore_snapshot(old_transfer)
		return _fail(transfer.error_message)
	last_payload = payload.duplicate(true)
	return true

func _migrate_payload(payload: Dictionary) -> Dictionary:
	if int(payload.get("save_schema_version", -1)) != LEGACY_SAVE_SCHEMA_VERSION:
		return payload
	var migrated: Dictionary = payload.duplicate(true)
	migrated["save_schema_version"] = SAVE_SCHEMA_VERSION
	var squad_payload = migrated.get("squad_state", {})
	if typeof(squad_payload) == TYPE_DICTIONARY and not squad_payload.has("condition"):
		var condition_payload: Dictionary = {}
		var roster = squad_payload.get("roster", [])
		if typeof(roster) == TYPE_ARRAY:
			for player in roster:
				if typeof(player) == TYPE_DICTIONARY:
					condition_payload[String(player.get("id", ""))] = 100
		squad_payload["condition"] = condition_payload
		migrated["squad_state"] = squad_payload
	return migrated

func _commit_temporary_save(path: String, temporary_path: String) -> bool:
	var target_absolute: String = ProjectSettings.globalize_path(path)
	var temporary_absolute: String = ProjectSettings.globalize_path(temporary_path)
	var backup_path: String = path + BACKUP_SUFFIX
	var backup_absolute: String = ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(backup_path):
		var remove_backup_error: Error = DirAccess.remove_absolute(backup_absolute)
		if remove_backup_error != OK:
			return _fail("Eski yedek kayıt silinemedi: %s" % remove_backup_error)

	var target_exists: bool = FileAccess.file_exists(path)
	if target_exists:
		var backup_error: Error = DirAccess.rename_absolute(target_absolute, backup_absolute)
		if backup_error != OK:
			return _fail("Mevcut kayıt yedeklenemedi: %s" % backup_error)

	var commit_error: Error = DirAccess.rename_absolute(temporary_absolute, target_absolute)
	if commit_error == OK:
		return true

	if target_exists:
		var restore_error: Error = DirAccess.rename_absolute(backup_absolute, target_absolute)
		if restore_error != OK:
			return _fail("Yeni kayıt yazılamadı ve eski kayıt geri alınamadı: %s / %s" % [commit_error, restore_error])
	return _fail("Geçici kayıt ana dosyaya taşınamadı: %s" % commit_error)

func build_payload(league, squad, tactics, economy, transfer, data_schema_version: String) -> Dictionary:
	return {
		"save_schema_version": SAVE_SCHEMA_VERSION,
		"data_schema_version": data_schema_version,
		"season": "2026-2027",
		"managed_team_id": squad.team_id,
		"league_state": league.get_snapshot(),
		"squad_state": squad.get_snapshot(),
		"tactics_state": tactics.get_snapshot(),
		"economy_state": economy.get_snapshot(),
		"transfer_state": transfer.get_snapshot()
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

func _read_payload_with_backup(path: String) -> Dictionary:
	var payload: Dictionary = _read_payload(path)
	if not payload.is_empty():
		last_load_source = "primary"
		return payload
	var primary_error: String = error_message
	var backup_path: String = path + BACKUP_SUFFIX
	if not FileAccess.file_exists(backup_path):
		return payload
	var backup_payload: Dictionary = _read_payload(backup_path)
	if not backup_payload.is_empty():
		last_load_source = "backup"
		error_message = "Ana kayıt okunamadı; yedek kayıt kullanıldı."
		return backup_payload
	error_message = "%s Yedek kayıt da okunamadı: %s" % [primary_error, error_message]
	return {}

func _validate_payload(
	payload: Dictionary,
	league,
	squad,
	tactics,
	economy,
	transfer,
	expected_data_schema_version: String,
	expected_team_id: String
) -> bool:
	if int(payload.get("save_schema_version", -1)) != SAVE_SCHEMA_VERSION:
		return _fail("Desteklenmeyen kayıt sürümü.")
	if String(payload.get("data_schema_version", "")) != expected_data_schema_version:
		return _fail("Kayıt veri paketi sürümüyle eşleşmiyor.")
	if String(payload.get("managed_team_id", "")) != expected_team_id or squad.team_id != expected_team_id:
		return _fail("Kayıt yönetilen takımla eşleşmiyor.")
	if typeof(payload.get("league_state", null)) != TYPE_DICTIONARY or typeof(payload.get("squad_state", null)) != TYPE_DICTIONARY or typeof(payload.get("tactics_state", null)) != TYPE_DICTIONARY or typeof(payload.get("economy_state", null)) != TYPE_DICTIONARY or typeof(payload.get("transfer_state", null)) != TYPE_DICTIONARY:
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
	if not economy.validate_snapshot(payload["economy_state"]):
		return _fail(economy.error_message)
	if not transfer.validate_snapshot(payload["transfer_state"]):
		return _fail(transfer.error_message)
	return true

func _is_user_path(path: String) -> bool:
	return path.begins_with("user://")

func _fail(message: String) -> bool:
	error_message = message
	return false
