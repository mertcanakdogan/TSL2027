class_name MatchEngine
extends RefCounted

const HOME_ADVANTAGE := 3.0
const HOME_CONTROL_ADVANTAGE := 1.5
const LINEUP_STRENGTH_BLEND := 0.35
const MENTALITY_MODIFIERS := {
	"cautious": {"attack": -3.0, "defense": 2.0, "control": -1.0},
	"balanced": {"attack": 0.0, "defense": 0.0, "control": 0.0},
	"positive": {"attack": 1.5, "defense": -0.5, "control": 0.5},
	"attacking": {"attack": 3.0, "defense": -2.0, "control": 0.5}
}

var rng := RandomNumberGenerator.new()

func simulate(
	home: Dictionary,
	away: Dictionary,
	seed_value: int,
	home_context: Dictionary = {},
	away_context: Dictionary = {}
) -> Dictionary:
	rng.seed = seed_value if seed_value != 0 else 1

	var home_profile: Dictionary = _build_profile(home, home_context)
	var away_profile: Dictionary = _build_profile(away, away_context)
	var home_attack_strength: float = float(home_profile["attack_strength"]) + HOME_ADVANTAGE
	var away_attack_strength: float = float(away_profile["attack_strength"])
	var home_defense_strength: float = float(home_profile["defense_strength"])
	var away_defense_strength: float = float(away_profile["defense_strength"])
	var home_control_strength: float = float(home_profile["control_strength"]) + HOME_CONTROL_ADVANTAGE
	var away_control_strength: float = float(away_profile["control_strength"])
	var attack_gap: float = home_attack_strength - away_defense_strength
	var away_attack_gap: float = away_attack_strength - home_defense_strength
	var control_gap: float = home_control_strength - away_control_strength

	var home_xg: float = clampf(
		1.25 + (attack_gap * 0.035) + rng.randf_range(-0.12, 0.12),
		0.25,
		3.60
	)
	var away_xg: float = clampf(
		1.05 + (away_attack_gap * 0.030) + rng.randf_range(-0.12, 0.12),
		0.20,
		3.40
	)

	var home_goals: int = _poisson(home_xg)
	var away_goals: int = _poisson(away_xg)
	var home_possession: float = clampf(
		50.0 + (control_gap * 0.35) + rng.randf_range(-3.0, 3.0),
		35.0,
		65.0
	)
	var home_shots: int = clampi(int(round(home_xg * 4.0 + rng.randf_range(3.0, 8.0))), 1, 25)
	var away_shots: int = clampi(int(round(away_xg * 4.0 + rng.randf_range(3.0, 8.0))), 1, 25)
	var home_shots_on_target: int = clampi(int(round(home_xg * 1.8 + rng.randf_range(0.0, 2.0))), 0, home_shots)
	var away_shots_on_target: int = clampi(int(round(away_xg * 1.8 + rng.randf_range(0.0, 2.0))), 0, away_shots)
	var home_corners: int = clampi(int(round(home_xg * 2.0 + rng.randf_range(0.0, 4.0))), 0, 12)
	var away_corners: int = clampi(int(round(away_xg * 2.0 + rng.randf_range(0.0, 4.0))), 0, 12)
	var home_fouls: int = rng.randi_range(7, 20)
	var away_fouls: int = rng.randi_range(7, 20)
	var home_yellow_cards: int = rng.randi_range(0, 5)
	var away_yellow_cards: int = rng.randi_range(0, 5)
	var events: Array = _build_events(
		home,
		away,
		home_context,
		away_context,
		home_goals,
		away_goals,
		home_yellow_cards,
		away_yellow_cards
	)
	var match_stats := {
		"home_shots": home_shots,
		"away_shots": away_shots,
		"home_shots_on_target": home_shots_on_target,
		"away_shots_on_target": away_shots_on_target,
		"home_corners": home_corners,
		"away_corners": away_corners,
		"home_fouls": home_fouls,
		"away_fouls": away_fouls,
		"home_yellow_cards": home_yellow_cards,
		"away_yellow_cards": away_yellow_cards,
		"home_possession": home_possession,
		"away_possession": 100.0 - home_possession,
		"home_xg": home_xg,
		"away_xg": away_xg
	}

	return {
		"home_goals": home_goals,
		"away_goals": away_goals,
		"home_xg": home_xg,
		"away_xg": away_xg,
		"home_possession": home_possession,
		"away_possession": 100.0 - home_possession,
		"home_attack_strength": home_attack_strength,
		"away_attack_strength": away_attack_strength,
		"home_defense_strength": home_defense_strength,
		"away_defense_strength": away_defense_strength,
		"home_control_strength": home_control_strength,
		"away_control_strength": away_control_strength,
		"events": events,
		"match_stats": match_stats,
		"seed": seed_value
	}

func _build_events(
	home: Dictionary,
	away: Dictionary,
	home_context: Dictionary,
	away_context: Dictionary,
	home_goals: int,
	away_goals: int,
	home_yellow_cards: int,
	away_yellow_cards: int
) -> Array:
	var events: Array = []
	for index in range(home_goals):
		events.append({
			"minute": rng.randi_range(1, 90),
			"type": "goal",
			"team_id": String(home.get("id", "home")),
			"team_name": String(home.get("name", home.get("id", "Ev sahibi"))),
			"actor": _event_actor(home_context, index, String(home.get("name", "Ev sahibi")))
		})
	for index in range(away_goals):
		events.append({
			"minute": rng.randi_range(1, 90),
			"type": "goal",
			"team_id": String(away.get("id", "away")),
			"team_name": String(away.get("name", away.get("id", "Deplasman"))),
			"actor": _event_actor(away_context, index, String(away.get("name", "Deplasman")))
		})
	for index in range(home_yellow_cards):
		events.append({
			"minute": rng.randi_range(1, 90),
			"type": "yellow_card",
			"team_id": String(home.get("id", "home")),
			"team_name": String(home.get("name", home.get("id", "Ev sahibi"))),
			"actor": _event_actor(home_context, index + home_goals, String(home.get("name", "Ev sahibi")))
		})
	for index in range(away_yellow_cards):
		events.append({
			"minute": rng.randi_range(1, 90),
			"type": "yellow_card",
			"team_id": String(away.get("id", "away")),
			"team_name": String(away.get("name", away.get("id", "Deplasman"))),
			"actor": _event_actor(away_context, index + away_goals, String(away.get("name", "Deplasman")))
		})
	events.sort_custom(_event_sorter)
	return events

func _event_actor(context: Dictionary, index: int, fallback: String) -> String:
	var starting_xi = context.get("starting_xi", [])
	if typeof(starting_xi) != TYPE_ARRAY or starting_xi.is_empty():
		return fallback
	var player: Dictionary = starting_xi[index % starting_xi.size()]
	return String(player.get("display_name", player.get("id", fallback)))

func _event_sorter(first: Dictionary, second: Dictionary) -> bool:
	if int(first["minute"]) != int(second["minute"]):
		return int(first["minute"]) < int(second["minute"])
	return String(first["type"]) < String(second["type"])

func _build_profile(team: Dictionary, context: Dictionary) -> Dictionary:
	var base_strength: float = float(team.get("strength", 50))
	var lineup_strength: float = _lineup_strength(context.get("starting_xi", []))
	if lineup_strength >= 0.0:
		base_strength = base_strength + ((lineup_strength - base_strength) * LINEUP_STRENGTH_BLEND)

	var attack_modifier: float = 0.0
	var defense_modifier: float = 0.0
	var control_modifier: float = 0.0
	var tactics = context.get("tactics", {})
	if typeof(tactics) == TYPE_DICTIONARY:
		var mentality: String = String(tactics.get("mentality", "balanced"))
		var mentality_modifier: Dictionary = MENTALITY_MODIFIERS.get(mentality, MENTALITY_MODIFIERS["balanced"])
		attack_modifier += float(mentality_modifier["attack"])
		defense_modifier += float(mentality_modifier["defense"])
		control_modifier += float(mentality_modifier["control"])

		attack_modifier += (_parameter(tactics, "tempo") - 50.0) * 0.020
		attack_modifier += (_parameter(tactics, "directness") - 50.0) * 0.012
		attack_modifier += (_parameter(tactics, "build_up_risk") - 50.0) * 0.010
		attack_modifier += (_parameter(tactics, "transition_speed") - 50.0) * 0.010
		attack_modifier += (_parameter(tactics, "set_piece_focus") - 50.0) * 0.004

		defense_modifier += (_parameter(tactics, "press_intensity") - 50.0) * 0.018
		defense_modifier -= (_parameter(tactics, "defensive_line") - 50.0) * 0.012
		if String(tactics.get("marking_approach", "zonal")) == "man_oriented":
			defense_modifier += 1.0

		control_modifier += (_parameter(tactics, "width") - 50.0) * 0.012
		control_modifier += (_parameter(tactics, "tempo") - 50.0) * 0.010
		control_modifier -= (_parameter(tactics, "directness") - 50.0) * 0.008
		control_modifier += (_parameter(tactics, "press_intensity") - 50.0) * 0.005

	return {
		"base_strength": clampf(base_strength, 1.0, 99.0),
		"attack_strength": clampf(base_strength + attack_modifier, 1.0, 99.0),
		"defense_strength": clampf(base_strength + defense_modifier, 1.0, 99.0),
		"control_strength": clampf(base_strength + control_modifier, 1.0, 99.0)
	}

func _lineup_strength(players) -> float:
	if typeof(players) != TYPE_ARRAY or players.is_empty():
		return -1.0
	var player_ratings: Array = []
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var attributes = player.get("attributes", {})
		if typeof(attributes) != TYPE_DICTIONARY or attributes.is_empty():
			continue
		var total: float = 0.0
		var count: int = 0
		for attribute in attributes:
			var value = attributes[attribute]
			if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
				total += float(value)
				count += 1
		if count > 0:
			player_ratings.append(total / count)
	if player_ratings.is_empty():
		return -1.0
	var sum_rating: float = 0.0
	for rating in player_ratings:
		sum_rating += float(rating)
	return sum_rating / player_ratings.size()

func _parameter(tactics: Dictionary, name: String) -> float:
	return clampf(float(tactics.get(name, 50)), 0.0, 100.0)

func _poisson(lambda_value: float) -> int:
	var threshold: float = exp(-lambda_value)
	var product: float = 1.0
	var events: int = 0

	while product > threshold and events < 8:
		events += 1
		product *= rng.randf()

	return max(events - 1, 0)
