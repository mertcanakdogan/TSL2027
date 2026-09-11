class_name MatchEngine
extends RefCounted

var rng := RandomNumberGenerator.new()

func simulate(home: Dictionary, away: Dictionary, seed_value: int) -> Dictionary:
	rng.seed = seed_value if seed_value != 0 else 1

	var home_strength: float = float(home.get("strength", 50))
	var away_strength: float = float(away.get("strength", 50))
	var strength_gap: float = home_strength - away_strength

	var home_xg: float = clampf(
		1.25 + (strength_gap * 0.035) + rng.randf_range(-0.12, 0.12),
		0.25,
		3.60
	)
	var away_xg: float = clampf(
		1.05 - (strength_gap * 0.030) + rng.randf_range(-0.12, 0.12),
		0.20,
		3.40
	)

	var home_goals: int = _poisson(home_xg)
	var away_goals: int = _poisson(away_xg)
	var home_possession: float = clampf(
		50.0 + (strength_gap * 0.35) + rng.randf_range(-3.0, 3.0),
		35.0,
		65.0
	)

	return {
		"home_goals": home_goals,
		"away_goals": away_goals,
		"home_xg": home_xg,
		"away_xg": away_xg,
		"home_possession": home_possession,
		"away_possession": 100.0 - home_possession,
		"seed": seed_value
	}

func _poisson(lambda_value: float) -> int:
	var threshold: float = exp(-lambda_value)
	var product: float = 1.0
	var events: int = 0

	while product > threshold and events < 8:
		events += 1
		product *= rng.randf()

	return max(events - 1, 0)
