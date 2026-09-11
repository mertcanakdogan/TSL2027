class_name DataPack
extends RefCounted

var teams: Array = []
var players: Array = []
var rules: Dictionary = {}
var players_by_team: Dictionary = {}
var schema_version: String = ""
var error_message: String = ""

func load_from_files(team_path: String, player_path: String, rules_path: String) -> bool:
	_reset()

	var team_payload: Dictionary = _read_payload(team_path)
	if not error_message.is_empty():
		return false
	var player_payload: Dictionary = _read_payload(player_path)
	if not error_message.is_empty():
		return false
	var rules_payload: Dictionary = _read_payload(rules_path)
	if not error_message.is_empty():
		return false

	if not team_payload.has("teams") or typeof(team_payload["teams"]) != TYPE_ARRAY:
		return _fail("Takım veri paketi 'teams' listesi içermiyor.")
	if not player_payload.has("players") or typeof(player_payload["players"]) != TYPE_ARRAY:
		return _fail("Oyuncu veri paketi 'players' listesi içermiyor.")
	if not rules_payload.has("competition") or not rules_payload.has("squad") or not rules_payload.has("economy"):
		return _fail("Kural veri paketi competition, squad ve economy bölümlerini içermiyor.")

	teams = team_payload["teams"].duplicate(true)
	players = player_payload["players"].duplicate(true)
	rules = rules_payload.duplicate(true)
	schema_version = String(player_payload.get("schema_version", "unknown"))

	for team in teams:
		if typeof(team) != TYPE_DICTIONARY or not team.has("id"):
			return _fail("Takım veri paketinde geçersiz takım kaydı var.")
		players_by_team[String(team["id"])] = []

	for player in players:
		if typeof(player) != TYPE_DICTIONARY or not player.has("id") or not player.has("team_id"):
			return _fail("Oyuncu veri paketinde geçersiz oyuncu kaydı var.")
		var team_id := String(player["team_id"])
		if not players_by_team.has(team_id):
			return _fail("Oyuncu bilinmeyen takıma bağlı: %s" % team_id)
		players_by_team[team_id].append(player)

	return true

func get_team_squad(team_id: String) -> Array:
	if not players_by_team.has(team_id):
		return []
	return players_by_team[team_id].duplicate(true)

func _read_payload(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_fail("Veri dosyası bulunamadı: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Veri dosyası açılamadı: %s" % path)
		return {}

	var payload = JSON.parse_string(file.get_as_text())
	if typeof(payload) != TYPE_DICTIONARY:
		_fail("Veri dosyası JSON nesnesi değil: %s" % path)
		return {}
	return payload

func _reset() -> void:
	teams.clear()
	players.clear()
	rules.clear()
	players_by_team.clear()
	schema_version = ""
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
