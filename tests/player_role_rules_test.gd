extends SceneTree

const DataPackScript = preload("res://scripts/core/data_pack.gd")
const PlayerRoleRulesScript = preload("res://scripts/core/player_role_rules.gd")
const MatchEngineScript = preload("res://scripts/core/match_engine.gd")

var failures: Array = []

func _init() -> void:
	_run()

func _run() -> void:
	var data_pack = DataPackScript.new()
	_check(data_pack.load_from_files("res://data/teams.json", "res://data/players.json", "res://data/game_rules.json"), "data pack should load")
	for player in data_pack.players:
		var roles: Array = PlayerRoleRulesScript.get_role_scores(player)
		var ratings: Dictionary = PlayerRoleRulesScript.get_profile_ratings(player)
		_check(roles.size() == 3, "every prototype player should expose three secondary role scores")
		_check(float(PlayerRoleRulesScript.get_best_role(player).get("score", -1.0)) >= 1.0, "every player should have a valid best role score")
		for profile_name in ["overall", "attack", "defense", "control"]:
			_check(float(ratings.get(profile_name, -1.0)) >= 1.0, "every player should have a valid %s profile rating" % profile_name)

	var balanced_player := {
		"position": "FW",
		"attributes": {
			"finishing": 60,
			"composure": 60,
			"off_ball_movement": 60,
			"dribbling": 60,
			"acceleration": 60,
			"strength": 60,
			"aerial": 60,
			"decisions": 60
		}
	}
	var clinical_player: Dictionary = balanced_player.duplicate(true)
	clinical_player["attributes"]["finishing"] = 95
	_check(PlayerRoleRulesScript.get_profile_ratings(clinical_player)["attack"] > PlayerRoleRulesScript.get_profile_ratings(balanced_player)["attack"], "finishing should affect attacking profile")
	_check(PlayerRoleRulesScript.get_best_role(clinical_player)["role"] == "Poacher", "clinical finishing should identify the poacher role")

	var engine = MatchEngineScript.new()
	var home := {"id": "home", "name": "Home", "strength": 60}
	var away := {"id": "away", "name": "Away", "strength": 60}
	var strong_context := {"starting_xi": _build_xi(85), "tactics": _balanced_tactics()}
	var weak_context := {"starting_xi": _build_xi(45), "tactics": _balanced_tactics()}
	var strong_profile: Dictionary = engine.simulate(home, away, 77, strong_context, {})
	var weak_profile: Dictionary = engine.simulate(home, away, 77, weak_context, {})
	_check(float(strong_profile["home_attack_strength"]) > float(weak_profile["home_attack_strength"]), "all-team player attributes should affect match attack profile")
	_check(float(strong_profile["home_defense_strength"]) > float(weak_profile["home_defense_strength"]), "all-team player attributes should affect match defense profile")

	if failures.is_empty():
		print("OK: player role rules tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(String(failure))
	quit(1)

func _build_xi(value: int) -> Array:
	var players: Array = []
	for index in range(11):
		players.append({
			"id": "player_%d_%d" % [value, index],
			"position": "MF",
			"attributes": {
				"passing": value,
				"vision": value,
				"decisions": value,
				"ball_control": value,
				"press_resistance": value,
				"stamina": value,
				"work_rate": value,
				"tackling": value,
				"long_shots": value
			}
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

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
