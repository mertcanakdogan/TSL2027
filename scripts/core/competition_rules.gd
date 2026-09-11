class_name CompetitionRules
extends RefCounted

const DEFAULT_SCHEMA_VERSION := "0.1.0"
const DEFAULT_SEASON := "2026-2027"
const DEFAULT_TEAM_COUNT := 18
const DEFAULT_ROUNDS := 2
const DEFAULT_WEEKS := 34
const DEFAULT_MATCHDAY_SQUAD_SIZE := 21
const DEFAULT_MAX_SUBSTITUTIONS := 5
const DEFAULT_MAX_ROSTER_SIZE := 28
const DEFAULT_BENCH_SIZE := 7
const DEFAULT_TRANSFER_WINDOW_END_WEEK := 8

var schema_version: String = DEFAULT_SCHEMA_VERSION
var season: String = DEFAULT_SEASON
var team_count: int = DEFAULT_TEAM_COUNT
var rounds: int = DEFAULT_ROUNDS
var weeks: int = DEFAULT_WEEKS
var matchday_squad_size: int = DEFAULT_MATCHDAY_SQUAD_SIZE
var max_substitutions: int = DEFAULT_MAX_SUBSTITUTIONS
var max_roster_size: int = DEFAULT_MAX_ROSTER_SIZE
var bench_size: int = DEFAULT_BENCH_SIZE
var max_foreign_players: int = 14
var min_national_team_eligible_players: int = 14
var min_young_national_team_eligible_players: int = 4
var max_goalkeepers: int = 3
var min_eligible_goalkeepers: int = 2
var transfer_window_end_week: int = DEFAULT_TRANSFER_WINDOW_END_WEEK
var error_message: String = ""

func initialize(payload: Dictionary = {}) -> bool:
	_reset()
	if payload.is_empty():
		return true
	if not payload.has("competition") or typeof(payload["competition"]) != TYPE_DICTIONARY:
		return _fail("Kural paketi competition bölümü içermiyor.")
	if not payload.has("squad") or typeof(payload["squad"]) != TYPE_DICTIONARY:
		return _fail("Kural paketi squad bölümü içermiyor.")
	if not payload.has("economy") or typeof(payload["economy"]) != TYPE_DICTIONARY:
		return _fail("Kural paketi economy bölümü içermiyor.")

	var competition: Dictionary = payload["competition"]
	var squad: Dictionary = payload["squad"]
	var economy: Dictionary = payload["economy"]
	schema_version = String(payload.get("schema_version", DEFAULT_SCHEMA_VERSION))
	season = String(payload.get("season", ""))
	if season.is_empty():
		return _fail("Kural paketi sezon kimliği içermiyor.")

	team_count = _required_int(competition, "team_count", "competition.team_count")
	if not error_message.is_empty():
		return false
	rounds = _required_int(competition, "rounds", "competition.rounds")
	if not error_message.is_empty():
		return false
	weeks = _required_int(competition, "weeks", "competition.weeks")
	if not error_message.is_empty():
		return false
	matchday_squad_size = _required_int(competition, "matchday_squad_size", "competition.matchday_squad_size")
	if not error_message.is_empty():
		return false
	max_substitutions = _required_int(competition, "max_substitutions", "competition.max_substitutions")
	if not error_message.is_empty():
		return false

	max_roster_size = _required_int(squad, "max_a_team_players", "squad.max_a_team_players")
	if not error_message.is_empty():
		return false
	bench_size = _required_int(squad, "bench_size", "squad.bench_size")
	if not error_message.is_empty():
		return false
	max_foreign_players = _required_int(squad, "max_foreign_players", "squad.max_foreign_players")
	if not error_message.is_empty():
		return false
	min_national_team_eligible_players = _required_int(squad, "min_national_team_eligible_players", "squad.min_national_team_eligible_players")
	if not error_message.is_empty():
		return false
	min_young_national_team_eligible_players = _required_int(squad, "min_young_national_team_eligible_players", "squad.min_young_national_team_eligible_players")
	if not error_message.is_empty():
		return false
	max_goalkeepers = _required_int(squad, "max_goalkeepers", "squad.max_goalkeepers")
	if not error_message.is_empty():
		return false
	min_eligible_goalkeepers = _required_int(squad, "min_eligible_goalkeepers", "squad.min_eligible_goalkeepers")
	if not error_message.is_empty():
		return false
	if economy.has("max_roster_size") and int(economy["max_roster_size"]) != max_roster_size:
		return _fail("economy.max_roster_size ve squad.max_a_team_players eşleşmiyor.")
	transfer_window_end_week = _required_int(economy, "transfer_window_end_week", "economy.transfer_window_end_week")
	if not error_message.is_empty():
		return false

	if team_count < 2 or team_count % 2 != 0:
		return _fail("competition.team_count çift ve en az 2 olmalıdır.")
	if rounds != 2:
		return _fail("Bu fikstür motoru iki devreli lig bekliyor.")
	if weeks != rounds * (team_count - 1):
		return _fail("competition.weeks, takım sayısı ve tur sayısıyla eşleşmiyor.")
	if matchday_squad_size < 11 or matchday_squad_size > max_roster_size:
		return _fail("competition.matchday_squad_size kadro sınırları dışında.")
	if max_substitutions < 0 or max_substitutions > bench_size:
		return _fail("competition.max_substitutions yedek kulübesi sınırları dışında.")
	if max_roster_size < 11:
		return _fail("squad.max_a_team_players ilk 11'den küçük olamaz.")
	if bench_size < 0 or bench_size > max_roster_size - 11:
		return _fail("squad.bench_size kadro sınırları dışında.")
	if transfer_window_end_week < 1 or transfer_window_end_week > weeks:
		return _fail("economy.transfer_window_end_week sezon haftaları dışında.")
	if max_foreign_players < 0 or min_national_team_eligible_players < 0 or min_young_national_team_eligible_players < 0:
		return _fail("squad uygunluk sınırları negatif olamaz.")
	if max_goalkeepers < min_eligible_goalkeepers or min_eligible_goalkeepers < 1:
		return _fail("squad kaleci uygunluk sınırları geçersiz.")
	return true

func get_snapshot() -> Dictionary:
	return {
		"schema_version": schema_version,
		"season": season,
		"team_count": team_count,
		"rounds": rounds,
		"weeks": weeks,
		"matchday_squad_size": matchday_squad_size,
		"max_substitutions": max_substitutions,
		"max_roster_size": max_roster_size,
		"bench_size": bench_size,
		"max_foreign_players": max_foreign_players,
		"min_national_team_eligible_players": min_national_team_eligible_players,
		"min_young_national_team_eligible_players": min_young_national_team_eligible_players,
		"max_goalkeepers": max_goalkeepers,
		"min_eligible_goalkeepers": min_eligible_goalkeepers,
		"transfer_window_end_week": transfer_window_end_week
	}

func _required_int(section: Dictionary, key: String, path: String) -> int:
	var value = section.get(key, null)
	if (typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT) or float(value) != round(float(value)):
		_fail("%s tam sayı olmalıdır." % path)
		return -1
	return int(value)

func _reset() -> void:
	schema_version = DEFAULT_SCHEMA_VERSION
	season = DEFAULT_SEASON
	team_count = DEFAULT_TEAM_COUNT
	rounds = DEFAULT_ROUNDS
	weeks = DEFAULT_WEEKS
	matchday_squad_size = DEFAULT_MATCHDAY_SQUAD_SIZE
	max_substitutions = DEFAULT_MAX_SUBSTITUTIONS
	max_roster_size = DEFAULT_MAX_ROSTER_SIZE
	bench_size = DEFAULT_BENCH_SIZE
	max_foreign_players = 14
	min_national_team_eligible_players = 14
	min_young_national_team_eligible_players = 4
	max_goalkeepers = 3
	min_eligible_goalkeepers = 2
	transfer_window_end_week = DEFAULT_TRANSFER_WINDOW_END_WEEK
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
