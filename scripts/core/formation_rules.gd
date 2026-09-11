class_name FormationRules
extends RefCounted

const POSITION_ORDER := ["GK", "DF", "MF", "FW"]
const FORMATIONS := ["4-4-2", "4-3-3", "4-2-3-1", "3-5-2", "5-3-2"]
const FORMATION_REQUIREMENTS := {
	"4-4-2": {"GK": 1, "DF": 4, "MF": 4, "FW": 2},
	"4-3-3": {"GK": 1, "DF": 4, "MF": 3, "FW": 3},
	"4-2-3-1": {"GK": 1, "DF": 4, "MF": 5, "FW": 1},
	"3-5-2": {"GK": 1, "DF": 3, "MF": 5, "FW": 2},
	"5-3-2": {"GK": 1, "DF": 5, "MF": 3, "FW": 2}
}

static func is_supported(formation: String) -> bool:
	return FORMATIONS.has(formation)

static func get_requirements(formation: String) -> Dictionary:
	return FORMATION_REQUIREMENTS.get(formation, {}).duplicate()
