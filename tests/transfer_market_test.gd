extends SceneTree

const EconomyStateScript = preload("res://scripts/core/economy_state.gd")
const SquadStateScript = preload("res://scripts/core/squad_state.gd")
const TransferMarketStateScript = preload("res://scripts/core/transfer_market_state.gd")

var failures: Array = []

func _init() -> void:
	var economy_rules := {
		"initial_balance_base": 100000000,
		"initial_balance_per_strength": 10000,
		"weekly_revenue_base": 100000,
		"weekly_revenue_per_strength": 1000,
		"weekly_wage_budget_base": 2000000,
		"weekly_wage_budget_per_strength": 1000
	}
	var roster := _build_roster("kocaelispor", 18)
	var catalog := roster.duplicate(true)
	catalog.append_array(_build_roster("galatasaray", 18))
	var squad = SquadStateScript.new()
	_check(squad.initialize("kocaelispor", roster), "squad should initialize")
	var economy = EconomyStateScript.new()
	_check(economy.initialize("kocaelispor", 61, economy_rules, roster), "economy should initialize")
	var market = TransferMarketStateScript.new()
	_check(market.initialize(catalog, "kocaelispor"), "market should initialize")
	_check(market.get_offers().size() == 18, "market should exclude managed team players")
	var repeat = TransferMarketStateScript.new()
	_check(repeat.initialize(catalog, "kocaelispor"), "repeat market should initialize")
	_check(market.get_offers() == repeat.get_offers(), "market offers should be deterministic")

	var offer: Dictionary = market.get_offers(1)[0]
	var player_id := String(offer["player"]["id"])
	var before_market: Dictionary = market.get_snapshot()
	var before_economy: Dictionary = economy.get_snapshot()
	var before_squad: Dictionary = squad.get_snapshot()
	_check(market.sign_player(player_id, squad, economy), "affordable offer should sign")
	_check(squad.get_roster().size() == 19, "signed player should join squad")
	_check(not market.has_offer(player_id), "signed player should leave market")
	_check(not economy.get_contract(player_id).is_empty(), "signed player should receive contract")
	_check(not market.sign_player(player_id, squad, economy), "signed player should not be signed twice")
	var window_offer: Dictionary = market.get_offers(1)[0]
	var window_before: Dictionary = market.get_snapshot()
	_check(market.set_current_week(9), "market week should advance")
	_check(not market.sign_player(String(window_offer["player"]["id"]), squad, economy), "closed transfer window should reject signings")
	_check(market.get_snapshot()["offers"] == window_before["offers"], "closed transfer window should not mutate offers")

	var poor_economy = EconomyStateScript.new()
	var poor_rules := economy_rules.duplicate(true)
	poor_rules["initial_balance_base"] = 0
	poor_rules["weekly_wage_budget_base"] = 0
	_check(poor_economy.initialize("kocaelispor", 61, poor_rules, roster), "poor economy should initialize")
	var poor_market = TransferMarketStateScript.new()
	_check(poor_market.initialize(catalog, "kocaelispor"), "poor market should initialize")
	var poor_offer: Dictionary = poor_market.get_offers(1)[0]
	var poor_player_id := String(poor_offer["player"]["id"])
	var poor_before_market: Dictionary = poor_market.get_snapshot()
	var poor_before_squad: Dictionary = squad.get_snapshot()
	_check(not poor_market.sign_player(poor_player_id, squad, poor_economy), "unaffordable offer should fail")
	_check(poor_market.get_snapshot() == poor_before_market, "failed transfer should not mutate market")
	_check(squad.get_snapshot() == poor_before_squad, "failed transfer should not mutate squad")

	if failures.is_empty():
		print("OK: transfer market tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(String(failure))
	quit(1)

func _build_roster(team_id: String, count: int) -> Array:
	var roster: Array = []
	var positions := ["GK", "GK", "DF", "DF", "DF", "DF", "DF", "DF", "MF", "MF", "MF", "MF", "MF", "MF", "FW", "FW", "FW", "FW"]
	for index in range(count):
		roster.append({
			"id": "%s_player_%02d" % [team_id, index],
			"team_id": team_id,
			"position": positions[index],
			"age": 20 + (index % 12),
			"attributes": {"rating": 70 + index}
		})
	return roster

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
