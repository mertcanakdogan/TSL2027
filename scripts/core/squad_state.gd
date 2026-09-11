class_name SquadState
extends RefCounted

const DEFAULT_STARTING_COUNTS := {
	"GK": 1,
	"DF": 4,
	"MF": 4,
	"FW": 2
}
const VALID_POSITIONS := ["GK", "DF", "MF", "FW"]

var team_id: String = ""
var roster: Array = []
var starting_ids: Array = []
var bench_ids: Array = []
var error_message: String = ""

func initialize(team_id_value: String, roster_records: Array, bench_size: int = 7) -> bool:
	_reset()
	if team_id_value.is_empty():
		return _fail("Kadro için takım kimliği boş olamaz.")
	if roster_records.size() < 11:
		return _fail("İlk 11 oluşturmak için en az 11 oyuncu gerekir.")
	if bench_size < 0:
		return _fail("Yedek kulübesi boyutu negatif olamaz.")

	var new_roster: Array = []
	var seen_ids: Dictionary = {}
	for record in roster_records:
		if typeof(record) != TYPE_DICTIONARY:
			return _fail("Kadro kaydı sözlük tipinde olmalıdır.")
		var player_id: String = String(record.get("id", ""))
		var record_team_id: String = String(record.get("team_id", ""))
		var position: String = String(record.get("position", ""))
		if player_id.is_empty():
			return _fail("Kadroda kimliksiz oyuncu bulunuyor.")
		if seen_ids.has(player_id):
			return _fail("Tekrarlanan oyuncu kimliği: %s" % player_id)
		if record_team_id != team_id_value:
			return _fail("Oyuncu kadro takımıyla eşleşmiyor: %s" % player_id)
		if not VALID_POSITIONS.has(position):
			return _fail("Geçersiz oyuncu pozisyonu: %s" % position)

		seen_ids[player_id] = true
		new_roster.append(record.duplicate(true))

	var position_counts := _count_positions(new_roster)
	for position in DEFAULT_STARTING_COUNTS:
		if int(position_counts.get(position, 0)) < int(DEFAULT_STARTING_COUNTS[position]):
			return _fail("4-4-2 başlangıcı için %s pozisyonunda yeterli oyuncu yok." % position)

	team_id = team_id_value
	roster = new_roster
	starting_ids = _build_default_starting_ids()
	var effective_bench_size: int = min(bench_size, roster.size() - starting_ids.size())
	for player in roster:
		var player_id: String = String(player["id"])
		if starting_ids.has(player_id):
			continue
		if bench_ids.size() >= effective_bench_size:
			break
		bench_ids.append(player_id)

	return true

func get_starting_xi() -> Array:
	return _records_for_ids(starting_ids)

func get_bench() -> Array:
	return _records_for_ids(bench_ids)

func get_roster() -> Array:
	return roster.duplicate(true)

func get_player_group(player_id: String) -> String:
	if starting_ids.has(player_id):
		return "starting"
	if bench_ids.has(player_id):
		return "bench"
	for player in roster:
		if String(player["id"]) == player_id:
			return "unselected"
	return "unknown"

func swap_players(first_player_id: String, second_player_id: String) -> bool:
	error_message = ""
	var first_group: String = get_player_group(first_player_id)
	var second_group: String = get_player_group(second_player_id)
	if first_group == "unknown" or second_group == "unknown":
		return _fail("Swap için iki geçerli oyuncu seçilmelidir.")
	if first_player_id == second_player_id:
		return _fail("Aynı oyuncu kendiyle değiştirilemez.")
	if first_group == second_group or first_group == "unselected" or second_group == "unselected":
		return _fail("Swap yalnızca ilk 11 ile yedek arasında yapılabilir.")

	if first_group == "starting":
		var starting_index: int = starting_ids.find(first_player_id)
		var bench_index: int = bench_ids.find(second_player_id)
		starting_ids[starting_index] = second_player_id
		bench_ids[bench_index] = first_player_id
	else:
		var starting_index: int = starting_ids.find(second_player_id)
		var bench_index: int = bench_ids.find(first_player_id)
		starting_ids[starting_index] = first_player_id
		bench_ids[bench_index] = second_player_id

	return true

func _build_default_starting_ids() -> Array:
	var selected: Array = []
	var selected_counts: Dictionary = {}
	for player in roster:
		var position: String = String(player["position"])
		var selected_for_position: int = int(selected_counts.get(position, 0))
		var required_for_position: int = int(DEFAULT_STARTING_COUNTS.get(position, 0))
		if selected_for_position >= required_for_position:
			continue
		selected.append(String(player["id"]))
		selected_counts[position] = selected_for_position + 1
	return selected

func _count_positions(players: Array) -> Dictionary:
	var counts: Dictionary = {}
	for player in players:
		var position: String = String(player.get("position", ""))
		counts[position] = int(counts.get(position, 0)) + 1
	return counts

func _records_for_ids(player_ids: Array) -> Array:
	var records: Array = []
	for player_id in player_ids:
		for player in roster:
			if String(player["id"]) == String(player_id):
				records.append(player.duplicate(true))
				break
	return records

func _reset() -> void:
	team_id = ""
	roster.clear()
	starting_ids.clear()
	bench_ids.clear()
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
