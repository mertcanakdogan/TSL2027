class_name EconomyState
extends RefCounted

var team_id: String = ""
var balance: int = 0
var weekly_revenue: int = 0
var weekly_wage_budget: int = 0
var committed_wages: int = 0
var last_settled_week: int = 0
var contracts: Dictionary = {}
var error_message: String = ""

func initialize(team_id_value: String, team_strength: int, economy_rules: Dictionary, roster: Array) -> bool:
	_reset()
	if team_id_value.is_empty():
		return _fail("Ekonomi için takım kimliği boş olamaz.")
	if team_strength < 1 or team_strength > 99:
		return _fail("Takım gücü 1-99 aralığında olmalıdır.")
	for key in [
		"initial_balance_base",
		"initial_balance_per_strength",
		"weekly_revenue_base",
		"weekly_revenue_per_strength",
		"weekly_wage_budget_base",
		"weekly_wage_budget_per_strength"
	]:
		if not economy_rules.has(key):
			return _fail("Ekonomi kuralı eksik: %s" % key)

	team_id = team_id_value
	balance = int(economy_rules["initial_balance_base"]) + team_strength * int(economy_rules["initial_balance_per_strength"])
	weekly_revenue = int(economy_rules["weekly_revenue_base"]) + team_strength * int(economy_rules["weekly_revenue_per_strength"])
	weekly_wage_budget = int(economy_rules["weekly_wage_budget_base"]) + team_strength * int(economy_rules["weekly_wage_budget_per_strength"])
	for player in roster:
		if typeof(player) != TYPE_DICTIONARY:
			return _fail("Sözleşme başlangıç kadrosu sözlüklerden oluşmalıdır.")
		var player_id := String(player.get("id", ""))
		if player_id.is_empty() or contracts.has(player_id):
			return _fail("Başlangıç sözleşmesinde geçersiz oyuncu kimliği var.")
		var weekly_wage := estimate_weekly_wage(player)
		contracts[player_id] = {
			"player_id": player_id,
			"weekly_wage": weekly_wage,
			"weeks_remaining": 52
		}
		committed_wages += weekly_wage
	return true

func register_transfer(player_id: String, transfer_fee: int, weekly_wage: int, contract_weeks: int) -> bool:
	error_message = ""
	if player_id.is_empty() or contracts.has(player_id):
		return _fail("Oyuncu için zaten geçerli bir sözleşme bulunuyor.")
	if transfer_fee < 0 or weekly_wage <= 0 or contract_weeks <= 0:
		return _fail("Transfer ve sözleşme değerleri geçersiz.")
	if balance < transfer_fee:
		return _fail("Transfer bütçesi yetersiz.")
	if committed_wages + weekly_wage > weekly_wage_budget:
		return _fail("Maaş bütçesi yetersiz.")
	balance -= transfer_fee
	committed_wages += weekly_wage
	contracts[player_id] = {
		"player_id": player_id,
		"weekly_wage": weekly_wage,
		"weeks_remaining": contract_weeks
	}
	return true

func advance_week(week: int) -> bool:
	if week <= last_settled_week:
		return _fail("Ekonomi haftası tekrar tahsil edilemez: %d" % week)
	if week < 1:
		return _fail("Ekonomi haftası 1 veya daha büyük olmalıdır.")
	balance += weekly_revenue - committed_wages
	last_settled_week = week
	var expired_ids: Array = []
	for player_id in contracts:
		var contract: Dictionary = contracts[player_id]
		contract["weeks_remaining"] = int(contract.get("weeks_remaining", 0)) - 1
		contracts[player_id] = contract
		if int(contract["weeks_remaining"]) <= 0:
			expired_ids.append(player_id)
	for player_id in expired_ids:
		committed_wages -= int(contracts[player_id].get("weekly_wage", 0))
		contracts.erase(player_id)
	return true

func get_contract(player_id: String) -> Dictionary:
	return contracts.get(player_id, {}).duplicate(true)

func get_snapshot() -> Dictionary:
	return {
		"team_id": team_id,
		"balance": balance,
		"weekly_revenue": weekly_revenue,
		"weekly_wage_budget": weekly_wage_budget,
		"committed_wages": committed_wages,
		"last_settled_week": last_settled_week,
		"contracts": contracts.duplicate(true)
	}

func validate_snapshot(snapshot: Dictionary) -> bool:
	if String(snapshot.get("team_id", "")) != team_id:
		return _fail("Ekonomi kaydı yönetilen takımla eşleşmiyor.")
	for key in ["balance", "weekly_revenue", "weekly_wage_budget", "committed_wages", "last_settled_week"]:
		if not snapshot.has(key) or typeof(snapshot[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return _fail("Ekonomi kaydında alan eksik: %s" % key)
	if int(snapshot["last_settled_week"]) < 0 or int(snapshot["weekly_wage_budget"]) < 0:
		return _fail("Ekonomi kaydında negatif hafta veya maaş bütçesi var.")
	if typeof(snapshot.get("contracts", null)) != TYPE_DICTIONARY:
		return _fail("Ekonomi kaydında sözleşmeler bulunmuyor.")
	var calculated_wages := 0
	for player_id in snapshot["contracts"]:
		var contract = snapshot["contracts"][player_id]
		if typeof(contract) != TYPE_DICTIONARY or String(contract.get("player_id", "")) != String(player_id):
			return _fail("Ekonomi kaydında geçersiz sözleşme var.")
		if int(contract.get("weekly_wage", 0)) <= 0 or int(contract.get("weeks_remaining", 0)) <= 0:
			return _fail("Ekonomi kaydında geçersiz sözleşme süresi/ücreti var.")
		calculated_wages += int(contract["weekly_wage"])
	if calculated_wages != int(snapshot["committed_wages"]):
		return _fail("Ekonomi kaydının maaş toplamı sözleşmelerle eşleşmiyor.")
	return true

func restore_snapshot(snapshot: Dictionary) -> bool:
	if not validate_snapshot(snapshot):
		return false
	team_id = String(snapshot["team_id"])
	balance = int(snapshot["balance"])
	weekly_revenue = int(snapshot["weekly_revenue"])
	weekly_wage_budget = int(snapshot["weekly_wage_budget"])
	committed_wages = int(snapshot["committed_wages"])
	last_settled_week = int(snapshot["last_settled_week"])
	contracts = snapshot["contracts"].duplicate(true)
	error_message = ""
	return true

static func estimate_weekly_wage(player: Dictionary) -> int:
	var attributes: Dictionary = player.get("attributes", {})
	var total := 0
	for value in attributes.values():
		total += int(value)
	var average := 50 if attributes.is_empty() else int(round(float(total) / attributes.size()))
	return 15000 + average * 500

func _reset() -> void:
	team_id = ""
	balance = 0
	weekly_revenue = 0
	weekly_wage_budget = 0
	committed_wages = 0
	last_settled_week = 0
	contracts.clear()
	error_message = ""

func _fail(message: String) -> bool:
	error_message = message
	return false
