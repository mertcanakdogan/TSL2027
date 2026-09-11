class_name TransferMarketState
extends RefCounted

const EconomyStateScript = preload("res://scripts/core/economy_state.gd")

var managed_team_id: String = ""
var current_week: int = 1
var transfer_window_end_week: int = 8
var offers: Array = []
var transactions: Array = []
var error_message: String = ""

func initialize(player_records: Array, managed_team_id_value: String, window_end_week: int = 8) -> bool:
	_reset()
	if managed_team_id_value.is_empty():
		return _fail("Transfer pazarı için yönetilen takım boş olamaz.")
	if window_end_week < 1:
		return _fail("Transfer penceresi en az bir hafta açık olmalıdır.")
	managed_team_id = managed_team_id_value
	transfer_window_end_week = window_end_week
	for player in player_records:
		if typeof(player) != TYPE_DICTIONARY:
			return _fail("Transfer pazarı oyuncu kaydı sözlük tipinde olmalıdır.")
		var player_id := String(player.get("id", ""))
		if player_id.is_empty():
			return _fail("Transfer pazarı kimliksiz oyuncu içeriyor.")
		if String(player.get("team_id", "")) == managed_team_id:
			continue
		var average_rating := _average_attribute(player)
		offers.append({
			"player": player.duplicate(true),
			"asking_fee": 200000 + average_rating * 10000,
			"weekly_wage": EconomyStateScript.estimate_weekly_wage(player),
			"contract_weeks": 52
		})
	return true

func get_offers(limit: int = -1) -> Array:
	var result: Array = []
	var count: int = offers.size() if limit < 0 else min(limit, offers.size())
	for index in range(count):
		result.append(offers[index].duplicate(true))
	return result

func has_offer(player_id: String) -> bool:
	return _offer_index(player_id) >= 0

func set_current_week(week: int) -> bool:
	if week < 1:
		return _fail("Transfer pazarı haftası 1 veya daha büyük olmalıdır.")
	current_week = week
	error_message = ""
	return true

func sign_player(player_id: String, squad, economy) -> bool:
	error_message = ""
	if current_week > transfer_window_end_week:
		return _fail("Transfer penceresi 1-%d. haftalar arasında açık." % transfer_window_end_week)
	var offer_index := _offer_index(player_id)
	if offer_index < 0:
		return _fail("Oyuncu transfer pazarında bulunamadı.")
	var offer: Dictionary = offers[offer_index]
	var source_player: Dictionary = offer["player"].duplicate(true)
	var signed_player: Dictionary = source_player.duplicate(true)
	signed_player["origin_team_id"] = String(source_player.get("team_id", ""))
	signed_player["team_id"] = squad.team_id
	if not squad.can_add_player(signed_player):
		return _fail(squad.error_message)
	var economy_before: Dictionary = economy.get_snapshot()
	if not economy.register_transfer(
		player_id,
		int(offer["asking_fee"]),
		int(offer["weekly_wage"]),
		int(offer["contract_weeks"])
	):
		return _fail(economy.error_message)
	if not squad.add_player(signed_player):
		economy.restore_snapshot(economy_before)
		return _fail(squad.error_message)
	offers.remove_at(offer_index)
	transactions.append({
		"player_id": player_id,
		"transfer_fee": int(offer["asking_fee"]),
		"weekly_wage": int(offer["weekly_wage"]),
		"contract_weeks": int(offer["contract_weeks"])
	})
	return true

func get_snapshot() -> Dictionary:
	return {
		"managed_team_id": managed_team_id,
		"current_week": current_week,
		"transfer_window_end_week": transfer_window_end_week,
		"offers": offers.duplicate(true),
		"transactions": transactions.duplicate(true)
	}

func validate_snapshot(snapshot: Dictionary) -> bool:
	if String(snapshot.get("managed_team_id", "")) != managed_team_id:
		return _fail("Transfer kaydı yönetilen takımla eşleşmiyor.")
	if int(snapshot.get("current_week", 0)) < 1 or int(snapshot.get("transfer_window_end_week", 0)) < 1:
		return _fail("Transfer kaydında geçersiz hafta penceresi var.")
	if typeof(snapshot.get("offers", null)) != TYPE_ARRAY or typeof(snapshot.get("transactions", null)) != TYPE_ARRAY:
		return _fail("Transfer kaydında teklifler veya işlemler bulunmuyor.")
	var seen_offer_ids: Dictionary = {}
	for offer in snapshot["offers"]:
		if not _validate_offer(offer):
			return false
		var player_id := String(offer["player"]["id"])
		if seen_offer_ids.has(player_id):
			return _fail("Transfer kaydında tekrarlanan teklif var.")
		seen_offer_ids[player_id] = true
	var seen_transaction_ids: Dictionary = {}
	for transaction in snapshot["transactions"]:
		if typeof(transaction) != TYPE_DICTIONARY or String(transaction.get("player_id", "")).is_empty():
			return _fail("Transfer kaydında geçersiz işlem var.")
		var transaction_player_id := String(transaction["player_id"])
		if seen_offer_ids.has(transaction_player_id):
			return _fail("İmzalanan oyuncu transfer tekliflerinde kalmış.")
		if seen_transaction_ids.has(transaction_player_id):
			return _fail("Transfer kaydında aynı oyuncu iki kez imzalanmış.")
		seen_transaction_ids[transaction_player_id] = true
	return true

func restore_snapshot(snapshot: Dictionary) -> bool:
	if not validate_snapshot(snapshot):
		return false
	managed_team_id = String(snapshot["managed_team_id"])
	current_week = int(snapshot["current_week"])
	transfer_window_end_week = int(snapshot["transfer_window_end_week"])
	offers = snapshot["offers"].duplicate(true)
	transactions = snapshot["transactions"].duplicate(true)
	error_message = ""
	return true

func _validate_offer(offer) -> bool:
	if typeof(offer) != TYPE_DICTIONARY or typeof(offer.get("player", null)) != TYPE_DICTIONARY:
		return _fail("Transfer kaydında geçersiz teklif var.")
	if String(offer["player"].get("id", "")).is_empty() or String(offer["player"].get("team_id", "")) == managed_team_id:
		return _fail("Transfer teklifinde oyuncu kimliği eksik.")
	if int(offer.get("asking_fee", 0)) < 0 or int(offer.get("weekly_wage", 0)) <= 0 or int(offer.get("contract_weeks", 0)) <= 0:
		return _fail("Transfer teklifinde geçersiz ücret var.")
	return true

func _average_attribute(player: Dictionary) -> int:
	var attributes: Dictionary = player.get("attributes", {})
	var total := 0
	for value in attributes.values():
		total += int(value)
	return 50 if attributes.is_empty() else int(round(float(total) / attributes.size()))

func _offer_index(player_id: String) -> int:
	for index in range(offers.size()):
		if String(offers[index]["player"].get("id", "")) == player_id:
			return index
	return -1

func _reset() -> void:
	managed_team_id = ""
	current_week = 1
	transfer_window_end_week = 8
	offers.clear()
	transactions.clear()
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
