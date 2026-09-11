class_name TacticsState
extends RefCounted

const FormationRulesScript = preload("res://scripts/core/formation_rules.gd")
const FORMATIONS := FormationRulesScript.FORMATIONS
const MENTALITIES := ["cautious", "balanced", "positive", "attacking"]
const MARKING_APPROACHES := ["zonal", "man_oriented"]
const NUMERIC_PARAMETERS := [
	"width",
	"tempo",
	"defensive_line",
	"press_intensity",
	"build_up_risk",
	"directness",
	"transition_speed",
	"set_piece_focus"
]

var formation: String = "4-4-2"
var mentality: String = "balanced"
var marking_approach: String = "zonal"
var width: int = 50
var tempo: int = 50
var defensive_line: int = 50
var press_intensity: int = 50
var build_up_risk: int = 50
var directness: int = 50
var transition_speed: int = 50
var set_piece_focus: int = 50
var error_message: String = ""

func initialize(initial_values: Dictionary = {}) -> bool:
	var previous: Dictionary = get_snapshot()
	_reset()
	for key in initial_values:
		var value = initial_values[key]
		var changed: bool = false
		match String(key):
			"formation":
				changed = set_formation(String(value))
			"mentality":
				changed = set_mentality(String(value))
			"marking_approach":
				changed = set_marking_approach(String(value))
			_:
				if NUMERIC_PARAMETERS.has(String(key)):
					changed = set_parameter(String(key), float(value))
		if not changed:
			var validation_error: String = error_message
			_apply_snapshot(previous)
			error_message = validation_error
			return false
	return true

func set_formation(value: String) -> bool:
	if not FORMATIONS.has(value):
		return _fail("Geçersiz diziliş: %s" % value)
	formation = value
	error_message = ""
	return true

func set_mentality(value: String) -> bool:
	if not MENTALITIES.has(value):
		return _fail("Geçersiz zihniyet: %s" % value)
	mentality = value
	error_message = ""
	return true

func set_marking_approach(value: String) -> bool:
	if not MARKING_APPROACHES.has(value):
		return _fail("Geçersiz markaj yaklaşımı: %s" % value)
	marking_approach = value
	error_message = ""
	return true

func set_parameter(parameter: String, value: float) -> bool:
	if not NUMERIC_PARAMETERS.has(parameter):
		return _fail("Geçersiz taktik parametresi: %s" % parameter)
	if is_nan(value) or value < 0.0 or value > 100.0:
		return _fail("Taktik parametresi 0-100 aralığında olmalıdır: %s" % parameter)
	set(parameter, int(round(value)))
	error_message = ""
	return true

func get_parameter(parameter: String) -> int:
	if not NUMERIC_PARAMETERS.has(parameter):
		return -1
	return int(get(parameter))

func get_snapshot() -> Dictionary:
	var snapshot := {
		"formation": formation,
		"mentality": mentality,
		"marking_approach": marking_approach
	}
	for parameter in NUMERIC_PARAMETERS:
		snapshot[parameter] = get_parameter(parameter)
	return snapshot

func _reset() -> void:
	formation = "4-4-2"
	mentality = "balanced"
	marking_approach = "zonal"
	for parameter in NUMERIC_PARAMETERS:
		set(parameter, 50)
	error_message = ""

func _apply_snapshot(snapshot: Dictionary) -> void:
	formation = String(snapshot["formation"])
	mentality = String(snapshot["mentality"])
	marking_approach = String(snapshot["marking_approach"])
	for parameter in NUMERIC_PARAMETERS:
		set(parameter, int(snapshot[parameter]))

func _fail(message: String) -> bool:
	error_message = message
	return false
