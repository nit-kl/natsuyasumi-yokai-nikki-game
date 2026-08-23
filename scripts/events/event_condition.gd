class_name EventCondition
extends Resource

@export_range(1, 30, 1) var min_day: int = 1
@export_range(1, 30, 1) var max_day: int = 30
@export var locations: Array[StringName] = []
@export var time_periods: Array[StringName] = []
@export var weathers: Array[StringName] = []
@export var required_flags: Array[StringName] = []
@export var forbidden_flags: Array[StringName] = []
@export var required_yokai_id: StringName
@export var minimum_yokai_stage: StringName = &"UNKNOWN"


func evaluate() -> Dictionary:
	var reasons: Array[String] = []
	if CalendarManager.day_index < min_day or CalendarManager.day_index > max_day:
		reasons.append("day %d is outside %d-%d" % [CalendarManager.day_index, min_day, max_day])
	if not locations.is_empty() and not locations.has(GameState.current_area_id):
		reasons.append("location %s is not allowed" % GameState.current_area_id)
	if not time_periods.is_empty() and not time_periods.has(GameClock.get_period()):
		reasons.append("period %s is not allowed" % GameClock.get_period())
	if not weathers.is_empty() and not weathers.has(WeatherManager.get_weather()):
		reasons.append("weather %s is not allowed" % WeatherManager.get_weather())
	for flag_id in required_flags:
		if not WorldState.has_flag(flag_id):
			reasons.append("required flag %s is missing" % flag_id)
	for flag_id in forbidden_flags:
		if WorldState.has_flag(flag_id):
			reasons.append("forbidden flag %s is set" % flag_id)
	if not required_yokai_id.is_empty():
		var actual_index := YokaiManager.get_stage_index(YokaiManager.get_stage(required_yokai_id))
		var required_index := YokaiManager.get_stage_index(minimum_yokai_stage)
		if required_index < 0 or actual_index < required_index:
			reasons.append("yokai %s has not reached %s" % [required_yokai_id, minimum_yokai_stage])
	return {"matches": reasons.is_empty(), "reasons": reasons}
