class_name SquadState
extends RefCounted

const FormationRulesScript = preload("res://scripts/core/formation_rules.gd")
const MAX_ROSTER_SIZE := 28
const BENCH_SIZE := 7
const INITIAL_CONDITION := 100
const STARTING_CONDITION_COST := 8
const BENCH_CONDITION_RECOVERY := 5
const UNUSED_CONDITION_RECOVERY := 8

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
var max_roster_size: int = MAX_ROSTER_SIZE
var bench_limit: int = BENCH_SIZE
var condition: Dictionary = {}
var active_formation: String = "4-4-2"
var error_message: String = ""

func initialize(team_id_value: String, roster_records: Array, bench_size: int = BENCH_SIZE, squad_rules: Dictionary = {}) -> bool:
	_reset()
	if squad_rules.has("max_roster_size"):
		if typeof(squad_rules["max_roster_size"]) != TYPE_INT:
			return _fail("Kadro üst sınırı tam sayı olmalıdır.")
		max_roster_size = int(squad_rules["max_roster_size"])
	elif squad_rules.has("max_a_team_players"):
		if typeof(squad_rules["max_a_team_players"]) != TYPE_INT:
			return _fail("Kadro üst sınırı tam sayı olmalıdır.")
		max_roster_size = int(squad_rules["max_a_team_players"])
	if squad_rules.has("bench_size"):
		if typeof(squad_rules["bench_size"]) != TYPE_INT:
			return _fail("Yedek kulübesi boyutu tam sayı olmalıdır.")
		bench_size = int(squad_rules["bench_size"])
	if max_roster_size < 11:
		return _fail("A takım kadrosu ilk 11'den küçük olamaz.")
	if bench_size < 0 or bench_size > max_roster_size - 11:
		return _fail("Yedek kulübesi boyutu kadro sınırları dışında.")
	bench_limit = bench_size
	if team_id_value.is_empty():
		return _fail("Kadro için takım kimliği boş olamaz.")
	if roster_records.size() < 11:
		return _fail("İlk 11 oluşturmak için en az 11 oyuncu gerekir.")

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
	if new_roster.size() > max_roster_size:
		return _fail("A takım kadrosu %d oyuncuyla sınırlıdır." % max_roster_size)

	var position_counts := _count_positions(new_roster)
	for position in DEFAULT_STARTING_COUNTS:
		if int(position_counts.get(position, 0)) < int(DEFAULT_STARTING_COUNTS[position]):
			return _fail("4-4-2 başlangıcı için %s pozisyonunda yeterli oyuncu yok." % position)

	team_id = team_id_value
	roster = new_roster
	for player in roster:
		condition[String(player["id"])] = INITIAL_CONDITION
	starting_ids = _build_default_starting_ids()
	var effective_bench_size: int = min(bench_limit, roster.size() - starting_ids.size())
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

func can_add_player(player_record: Dictionary) -> bool:
	if roster.size() >= max_roster_size:
		return _fail("A takım kadrosu %d oyuncuyla sınırlıdır." % max_roster_size)
	var player_id := String(player_record.get("id", ""))
	var record_team_id := String(player_record.get("team_id", ""))
	var position := String(player_record.get("position", ""))
	if player_id.is_empty() or _roster_has_id(player_id):
		return _fail("Oyuncu kimliği boş veya kadroda zaten var.")
	if record_team_id != team_id:
		return _fail("Transfer oyuncusu yönetilen takımla eşleşmiyor.")
	if not VALID_POSITIONS.has(position):
		return _fail("Transfer oyuncusunda geçersiz pozisyon var: %s" % position)
	return true

func add_player(player_record: Dictionary) -> bool:
	if not can_add_player(player_record):
		return false
	var player_id := String(player_record["id"])
	roster.append(player_record.duplicate(true))
	condition[player_id] = INITIAL_CONDITION
	if bench_ids.size() < bench_limit:
		bench_ids.append(player_id)
	error_message = ""
	return true

func get_starting_position_counts() -> Dictionary:
	return _position_counts_for_ids(starting_ids)

func get_active_formation() -> String:
	return active_formation

func get_formation_requirements(formation: String) -> Dictionary:
	return FormationRulesScript.get_requirements(formation)

func can_apply_formation(formation: String) -> bool:
	return _validate_roster_for_formation(formation)

func apply_formation(formation: String) -> bool:
	if not _validate_roster_for_formation(formation):
		return false

	var requirements: Dictionary = get_formation_requirements(formation)
	var new_starting_ids: Array = []
	var selected_counts: Dictionary = {}
	var candidates: Array = starting_ids.duplicate()
	for player in roster:
		var player_id := String(player["id"])
		if not candidates.has(player_id):
			candidates.append(player_id)

	for player_id in candidates:
		var player := _record_for_id(player_id)
		if player.is_empty():
			continue
		var position := String(player["position"])
		var selected_for_position := int(selected_counts.get(position, 0))
		if selected_for_position >= int(requirements.get(position, 0)):
			continue
		new_starting_ids.append(player_id)
		selected_counts[position] = selected_for_position + 1

	if new_starting_ids.size() != 11:
		return _fail("%s için ilk 11 oluşturulamadı." % formation)

	var target_bench_size: int = min(bench_ids.size(), roster.size() - new_starting_ids.size())
	var new_bench_ids: Array = []
	for player in roster:
		var player_id := String(player["id"])
		if new_starting_ids.has(player_id) or new_bench_ids.size() >= target_bench_size:
			continue
		new_bench_ids.append(player_id)

	starting_ids = new_starting_ids
	bench_ids = new_bench_ids
	active_formation = formation
	error_message = ""
	return true

func get_bench() -> Array:
	return _records_for_ids(bench_ids)

func get_roster() -> Array:
	var records: Array = []
	for player in roster:
		var record: Dictionary = player.duplicate(true)
		record["condition"] = get_player_condition(String(player.get("id", "")))
		records.append(record)
	return records

func get_player_condition(player_id: String) -> int:
	return clampi(int(condition.get(player_id, INITIAL_CONDITION)), 0, INITIAL_CONDITION)

func apply_match_fatigue() -> void:
	for player in roster:
		var player_id: String = String(player.get("id", ""))
		var current_condition: int = get_player_condition(player_id)
		if starting_ids.has(player_id):
			condition[player_id] = max(0, current_condition - STARTING_CONDITION_COST)
		elif bench_ids.has(player_id):
			condition[player_id] = min(INITIAL_CONDITION, current_condition + BENCH_CONDITION_RECOVERY)
		else:
			condition[player_id] = min(INITIAL_CONDITION, current_condition + UNUSED_CONDITION_RECOVERY)

func get_snapshot() -> Dictionary:
	return {
		"team_id": team_id,
		"formation": active_formation,
		"max_roster_size": max_roster_size,
		"bench_size": bench_limit,
		"roster": roster.duplicate(true),
		"starting_ids": starting_ids.duplicate(),
		"bench_ids": bench_ids.duplicate(),
		"condition": condition.duplicate(true)
	}

func validate_snapshot(snapshot: Dictionary) -> bool:
	if not snapshot.has("team_id") or String(snapshot["team_id"]) != team_id:
		return _fail("Kayıt takımı mevcut kadroyla eşleşmiyor.")
	var candidate_roster: Array = roster
	if snapshot.has("roster"):
		if typeof(snapshot["roster"]) != TYPE_ARRAY:
			return _fail("Kayıt kadrosu liste tipinde olmalıdır.")
		candidate_roster = snapshot["roster"]
		if not _validate_roster_records(candidate_roster, team_id):
			return false
	if snapshot.has("max_roster_size"):
		if not _is_integer_number(snapshot["max_roster_size"]) or int(snapshot["max_roster_size"]) != max_roster_size:
			return _fail("Kayıt kadro üst sınırı aktif kurallarla eşleşmiyor.")
	if snapshot.has("bench_size"):
		if not _is_integer_number(snapshot["bench_size"]) or int(snapshot["bench_size"]) != bench_limit:
			return _fail("Kayıt yedek kulübesi boyutu aktif kurallarla eşleşmiyor.")
	var saved_formation := String(snapshot.get("formation", "4-4-2"))
	if not FormationRulesScript.is_supported(saved_formation):
		return _fail("Kayıt kadrosunda geçersiz diziliş var: %s" % saved_formation)
	if typeof(snapshot.get("starting_ids", null)) != TYPE_ARRAY or typeof(snapshot.get("bench_ids", null)) != TYPE_ARRAY:
		return _fail("Kadro kaydında starter/bench listesi bulunmuyor.")
	var saved_starting: Array = snapshot["starting_ids"]
	var saved_bench: Array = snapshot["bench_ids"]
	var saved_condition: Dictionary = snapshot.get("condition", {})
	if typeof(saved_condition) != TYPE_DICTIONARY:
		return _fail("Kayıt kondisyon state'i sözlük tipinde olmalıdır.")
	if saved_starting.size() != 11:
		return _fail("Kayıt ilk 11 için 11 oyuncu içermiyor.")
	if saved_bench.size() > candidate_roster.size() - saved_starting.size():
		return _fail("Kayıt yedek kulübesi mevcut kadrodan büyük.")
	if saved_bench.size() > bench_limit:
		return _fail("Kayıt yedek kulübesi aktif kurallardan büyük.")
	var seen_ids: Dictionary = {}
	for player_id in saved_starting + saved_bench:
		var normalized_id: String = String(player_id)
		if normalized_id.is_empty() or seen_ids.has(normalized_id):
			return _fail("Kayıt kadrosunda geçersiz veya tekrarlanan oyuncu var.")
		if not _roster_has_id_in(normalized_id, candidate_roster):
			return _fail("Kayıt oyuncusu mevcut kadroda bulunmuyor: %s" % normalized_id)
		seen_ids[normalized_id] = true
	for player in candidate_roster:
		var player_id: String = String(player.get("id", ""))
		var saved_value = saved_condition.get(player_id, INITIAL_CONDITION)
		if (typeof(saved_value) != TYPE_INT and typeof(saved_value) != TYPE_FLOAT) or float(saved_value) < 0.0 or float(saved_value) > INITIAL_CONDITION:
			return _fail("Kayıt kondisyon değeri 0-100 aralığında olmalıdır: %s" % player_id)
	for player_id in saved_condition:
		if not _roster_has_id_in(String(player_id), candidate_roster):
			return _fail("Kayıt kondisyonu bilinmeyen oyuncu içeriyor: %s" % player_id)
	if _position_counts_for_ids(saved_starting, candidate_roster) != get_formation_requirements(saved_formation):
		return _fail("Kayıt ilk 11'i diziliş pozisyonlarıyla eşleşmiyor.")
	return true

func restore_snapshot(snapshot: Dictionary) -> bool:
	if not validate_snapshot(snapshot):
		return false
	if snapshot.has("roster"):
		roster = snapshot["roster"].duplicate(true)
	condition.clear()
	var saved_condition: Dictionary = snapshot.get("condition", {})
	for player in roster:
		var player_id: String = String(player.get("id", ""))
		condition[player_id] = int(saved_condition.get(player_id, INITIAL_CONDITION))
	active_formation = String(snapshot.get("formation", "4-4-2"))
	starting_ids = snapshot["starting_ids"].duplicate()
	bench_ids = snapshot["bench_ids"].duplicate()
	error_message = ""
	return true

func get_player_group(player_id: String) -> String:
	if starting_ids.has(player_id):
		return "starting"
	if bench_ids.has(player_id):
		return "bench"
	for player in roster:
		if String(player["id"]) == player_id:
			return "unselected"
	return "unknown"
func promote_to_bench(player_id: String, displaced_bench_id: String = "") -> bool:
	error_message = ""
	if get_player_group(player_id) != "unselected":
		return _fail("Yalnızca kadro dışı oyuncu yedeğe alınabilir.")
	if bench_ids.size() < bench_limit:
		if not displaced_bench_id.is_empty():
			return _fail("Dolu olmayan yedek kulübesinde değiştirilecek oyuncu yok.")
		bench_ids.append(player_id)
		return true
	if displaced_bench_id.is_empty() or get_player_group(displaced_bench_id) != "bench":
		return _fail("Dolu yedek kulübesinde geçerli bir oyuncu seçilmelidir.")
	var displaced_index: int = bench_ids.find(displaced_bench_id)
	if displaced_index < 0:
		return _fail("Değiştirilecek yedek oyuncu bulunamadı.")
	bench_ids[displaced_index] = player_id
	return true


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
		var next_starting_ids: Array = starting_ids.duplicate()
		next_starting_ids[starting_index] = second_player_id
		if _position_counts_for_ids(next_starting_ids) != get_formation_requirements(active_formation):
			return _fail("Değişim %s dizilişinin pozisyon dağılımını bozuyor." % active_formation)
		starting_ids = next_starting_ids
		bench_ids[bench_index] = first_player_id
	else:
		var starting_index: int = starting_ids.find(second_player_id)
		var bench_index: int = bench_ids.find(first_player_id)
		var next_starting_ids: Array = starting_ids.duplicate()
		next_starting_ids[starting_index] = first_player_id
		if _position_counts_for_ids(next_starting_ids) != get_formation_requirements(active_formation):
			return _fail("Değişim %s dizilişinin pozisyon dağılımını bozuyor." % active_formation)
		starting_ids = next_starting_ids
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
	var counts: Dictionary = {"GK": 0, "DF": 0, "MF": 0, "FW": 0}
	for player in players:
		var position: String = String(player.get("position", ""))
		counts[position] = int(counts.get(position, 0)) + 1
	return counts

func _position_counts_for_ids(player_ids: Array, source_roster: Array = []) -> Dictionary:
	var active_roster: Array = roster if source_roster.is_empty() else source_roster
	return _count_positions(_records_for_ids_from_roster(player_ids, active_roster))

func _validate_roster_for_formation(formation: String) -> bool:
	if not FormationRulesScript.is_supported(formation):
		return _fail("Geçersiz diziliş: %s" % formation)
	var requirements: Dictionary = get_formation_requirements(formation)
	var roster_counts := _count_positions(roster)
	for position in FormationRulesScript.POSITION_ORDER:
		if int(roster_counts.get(position, 0)) < int(requirements.get(position, 0)):
			return _fail("%s için %s pozisyonunda yeterli oyuncu yok." % [formation, position])
	return true

func _record_for_id(player_id: String) -> Dictionary:
	for player in roster:
		if String(player.get("id", "")) == player_id:
			return player
	return {}

func _validate_roster_records(roster_records: Array, expected_team_id: String) -> bool:
	if roster_records.size() < 11 or roster_records.size() > max_roster_size:
		return _fail("Kayıt kadrosu 11-%d oyuncu arasında olmalıdır." % max_roster_size)
	var seen_ids: Dictionary = {}
	for record in roster_records:
		if typeof(record) != TYPE_DICTIONARY:
			return _fail("Kayıt kadrosu sözlük tipinde olmalıdır.")
		var player_id := String(record.get("id", ""))
		if player_id.is_empty() or seen_ids.has(player_id):
			return _fail("Kayıt kadrosunda geçersiz veya tekrarlanan oyuncu var.")
		if String(record.get("team_id", "")) != expected_team_id:
			return _fail("Kayıt oyuncusu yönetilen takımla eşleşmiyor: %s" % player_id)
		if not VALID_POSITIONS.has(String(record.get("position", ""))):
			return _fail("Kayıt oyuncusunda geçersiz pozisyon var: %s" % player_id)
		seen_ids[player_id] = true
	return true

func _records_for_ids_from_roster(player_ids: Array, source_roster: Array) -> Array:
	var records: Array = []
	for player_id in player_ids:
		for player in source_roster:
			if String(player.get("id", "")) == String(player_id):
				records.append(player.duplicate(true))
				break
	return records

func _records_for_ids(player_ids: Array) -> Array:
	var records: Array = []
	for player_id in player_ids:
		for player in roster:
			if String(player["id"]) == String(player_id):
				var record: Dictionary = player.duplicate(true)
				record["condition"] = get_player_condition(String(player_id))
				records.append(record)
				break
	return records

func _roster_has_id(player_id: String) -> bool:
	return _roster_has_id_in(player_id, roster)

func _roster_has_id_in(player_id: String, source_roster: Array) -> bool:
	for player in source_roster:
		if String(player.get("id", "")) == player_id:
			return true
	return false

func _is_integer_number(value) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	return float(value) == round(float(value))

func _reset() -> void:
	max_roster_size = MAX_ROSTER_SIZE
	bench_limit = BENCH_SIZE
	team_id = ""
	roster.clear()
	starting_ids.clear()
	bench_ids.clear()
	condition.clear()
	active_formation = "4-4-2"
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
