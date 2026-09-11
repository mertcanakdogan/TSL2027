extends SceneTree

const MatchEngineScript = preload("res://scripts/core/match_engine.gd")
const LeagueStateScript = preload("res://scripts/core/league_state.gd")

var failures: Array = []

func _init() -> void:
	_run()

func _run() -> void:
	var engine = MatchEngineScript.new()
	var home := {"id": "home", "name": "Home", "strength": 60}
	var away := {"id": "away", "name": "Away", "strength": 60}
	var balanced_context := {
		"starting_xi": _build_xi(60),
		"tactics": _balanced_tactics()
	}
	var attacking_context := {
		"starting_xi": _build_xi(80),
		"tactics": _attacking_tactics()
	}
	var weak_context := {
		"starting_xi": _build_xi(40),
		"tactics": _balanced_tactics()
	}

	var first: Dictionary = engine.simulate(home, away, 4242, attacking_context, balanced_context)
	var replay: Dictionary = engine.simulate(home, away, 4242, attacking_context, balanced_context)
	_check(first == replay, "same seed and context should replay identically")
	_check(float(first["home_xg"]) > 0.0 and float(first["away_xg"]) > 0.0, "xG should stay positive")
	_check(float(first["home_possession"]) >= 35.0 and float(first["home_possession"]) <= 65.0, "home possession should be bounded")

	var fallback: Dictionary = engine.simulate(home, away, 4242)
	_check(fallback.has("home_attack_strength"), "fallback result should expose profile fields")
	_check(abs(float(fallback["home_attack_strength"]) - 63.0) < 0.001, "fallback home attack should include home advantage")
	_check(abs(float(fallback["away_defense_strength"]) - 60.0) < 0.001, "fallback away defense should use team strength")

	var strong_profile: Dictionary = engine.simulate(home, away, 100, attacking_context, balanced_context)
	var weak_profile: Dictionary = engine.simulate(home, away, 100, weak_context, balanced_context)
	_check(float(strong_profile["home_attack_strength"]) > float(weak_profile["home_attack_strength"]), "stronger XI should raise attack profile")
	_check(float(strong_profile["home_defense_strength"]) > float(weak_profile["home_defense_strength"]), "stronger XI should raise defense profile")
	_check(float(strong_profile["home_xg"]) > float(weak_profile["home_xg"]), "stronger XI should raise xG with same seed")
	_check(float(strong_profile["home_attack_strength"]) > float(strong_profile["home_defense_strength"]), "attacking context should favor attack profile")

	var league = LeagueStateScript.new()
	league.initialize([home, away], 2026)
	_check(league.set_team_context("home", attacking_context), "known team context should be accepted")
	_check(not league.set_team_context("missing", attacking_context), "unknown team context should be rejected")
	var stored_context: Dictionary = league.team_contexts["home"]
	attacking_context["tactics"]["formation"] = "mutated_after_registration"
	_check(String(stored_context["tactics"]["formation"]) == "4-3-3", "league should copy registered context")
	_check(league.fixtures.size() == 2, "context registration should not alter fixtures")

	if failures.is_empty():
		print("OK: match engine tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _build_xi(value: int) -> Array:
	var players: Array = []
	for index in range(11):
		players.append({
			"id": "xi_%d_%d" % [value, index],
			"position": "MF",
			"attributes": {"passing": value, "decisions": value}
		})
	return players

func _balanced_tactics() -> Dictionary:
	return {
		"formation": "4-4-2",
		"mentality": "balanced",
		"marking_approach": "zonal",
		"width": 50,
		"tempo": 50,
		"defensive_line": 50,
		"press_intensity": 50,
		"build_up_risk": 50,
		"directness": 50,
		"transition_speed": 50,
		"set_piece_focus": 50
	}

func _attacking_tactics() -> Dictionary:
	var tactics := _balanced_tactics()
	tactics["formation"] = "4-3-3"
	tactics["mentality"] = "attacking"
	tactics["tempo"] = 80
	tactics["press_intensity"] = 75
	tactics["build_up_risk"] = 70
	tactics["directness"] = 70
	tactics["transition_speed"] = 75
	return tactics

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
