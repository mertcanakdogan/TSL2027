class_name PlayerRoleRules
extends RefCounted

const POSITION_ROLES := {
	"GK": {
		"Sweeper Keeper": ["distribution", "decisions", "positioning"],
		"Shot Stopper": ["reflexes", "handling", "one_on_one"],
		"Aerial Keeper": ["aerial_control", "handling", "positioning"]
	},
	"DF": {
		"Ball Playing Defender": ["passing", "interceptions", "positioning"],
		"Stopper": ["tackling", "strength", "aerial"],
		"Full Back": ["pace", "passing", "interceptions"]
	},
	"MF": {
		"Playmaker": ["passing", "vision", "ball_control", "decisions"],
		"Ball Winner": ["tackling", "work_rate", "stamina", "decisions"],
		"Box to Box": ["stamina", "work_rate", "decisions", "long_shots"]
	},
	"FW": {
		"Poacher": ["finishing", "composure", "off_ball_movement"],
		"Target Forward": ["strength", "aerial", "composure", "finishing"],
		"Inside Forward": ["dribbling", "acceleration", "off_ball_movement", "decisions"]
	}
}

const PROFILE_ATTRIBUTES := {
	"GK": {
		"attack": ["distribution", "decisions"],
		"defense": ["reflexes", "handling", "aerial_control", "one_on_one", "positioning"],
		"control": ["distribution", "positioning", "decisions"]
	},
	"DF": {
		"attack": ["passing", "pace", "decisions", "aerial"],
		"defense": ["positioning", "marking", "tackling", "interceptions", "strength"],
		"control": ["passing", "positioning", "interceptions", "pace"]
	},
	"MF": {
		"attack": ["passing", "vision", "ball_control", "long_shots", "decisions"],
		"defense": ["tackling", "stamina", "work_rate", "press_resistance", "decisions"],
		"control": ["passing", "vision", "ball_control", "press_resistance", "decisions"]
	},
	"FW": {
		"attack": ["finishing", "composure", "off_ball_movement", "dribbling", "acceleration", "decisions"],
		"defense": ["strength", "aerial", "off_ball_movement", "decisions"],
		"control": ["dribbling", "composure", "off_ball_movement", "decisions"]
	}
}

static func get_role_names(position: String) -> Array:
	var role_map: Dictionary = POSITION_ROLES.get(position, {})
	return role_map.keys()

static func get_role_score(player: Dictionary, role: String) -> float:
	var position: String = String(player.get("position", ""))
	var role_map: Dictionary = POSITION_ROLES.get(position, {})
	if not role_map.has(role):
		return -1.0
	return _average_attributes(player.get("attributes", {}), role_map[role])

static func get_role_scores(player: Dictionary) -> Array:
	var scores: Array = []
	for role in get_role_names(String(player.get("position", ""))):
		scores.append({"role": String(role), "score": get_role_score(player, String(role))})
	scores.sort_custom(_role_score_sorter)
	return scores

static func get_best_role(player: Dictionary) -> Dictionary:
	var scores: Array = get_role_scores(player)
	if scores.is_empty():
		return {"role": "", "score": -1.0}
	return scores[0].duplicate(true)

static func get_profile_ratings(player: Dictionary) -> Dictionary:
	var position: String = String(player.get("position", ""))
	var attributes = player.get("attributes", {})
	var overall: float = _average_attributes(attributes)
	if overall < 0.0:
		return {"overall": -1.0, "attack": -1.0, "defense": -1.0, "control": -1.0}

	var profile_map: Dictionary = PROFILE_ATTRIBUTES.get(position, {})
	var ratings := {"overall": overall}
	for profile_name in ["attack", "defense", "control"]:
		var rating: float = _average_attributes(attributes, profile_map.get(profile_name, []))
		ratings[profile_name] = overall if rating < 0.0 else rating
	return ratings

static func _average_attributes(attributes, selected_names: Array = []) -> float:
	if typeof(attributes) != TYPE_DICTIONARY or attributes.is_empty():
		return -1.0
	var names: Array = selected_names
	if names.is_empty():
		names = attributes.keys()
	var total: float = 0.0
	var count: int = 0
	for attribute in names:
		var value = attributes.get(attribute, null)
		if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			total += float(value)
			count += 1
	if count == 0:
		return -1.0
	return total / count

static func _role_score_sorter(first: Dictionary, second: Dictionary) -> bool:
	if abs(float(first["score"]) - float(second["score"])) > 0.001:
		return float(first["score"]) > float(second["score"])
	return String(first["role"]) < String(second["role"])
