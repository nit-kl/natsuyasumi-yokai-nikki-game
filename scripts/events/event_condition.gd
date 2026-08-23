class_name EventCondition
extends Resource

const TIME_RANGE_UNSET := -1

@export_range(1, 30, 1) var min_day: int = 1
@export_range(1, 30, 1) var max_day: int = 30
@export var locations: Array[StringName] = []
@export var time_periods: Array[StringName] = []
@export_range(-1, 1439, 1) var min_time_minutes: int = TIME_RANGE_UNSET
@export_range(-1, 1439, 1) var max_time_minutes: int = TIME_RANGE_UNSET
@export var weathers: Array[StringName] = []
@export var required_flags: Array[StringName] = []
@export var forbidden_flags: Array[StringName] = []
@export var required_items: Array[StringName] = []
@export var required_seen_events: Array[StringName] = []
@export var forbidden_seen_events: Array[StringName] = []
@export var required_npc_id: StringName
@export var required_npc_state: StringName
@export var required_yokai_id: StringName
@export var minimum_yokai_stage: StringName = &"UNKNOWN"
@export_range(0.0, 1.0, 0.01) var random_chance: float = 1.0


func evaluate(rng: RandomNumberGenerator = null) -> Dictionary:
	var reasons: Array[String] = []
	if CalendarManager.day_index < min_day or CalendarManager.day_index > max_day:
		reasons.append("day %d is outside %d-%d" % [CalendarManager.day_index, min_day, max_day])
	if not locations.is_empty() and not locations.has(GameState.current_area_id):
		reasons.append("location %s is not allowed" % GameState.current_area_id)
	if not time_periods.is_empty() and not time_periods.has(GameClock.get_period()):
		reasons.append("period %s is not allowed" % GameClock.get_period())
	if not is_within_time_range(GameClock.time_minutes, min_time_minutes, max_time_minutes):
		reasons.append("time %s is outside %s-%s" % [
			GameClock.get_time_text(),
			_format_time_bound(min_time_minutes),
			_format_time_bound(max_time_minutes),
		])
	if not weathers.is_empty() and not weathers.has(WeatherManager.get_weather()):
		reasons.append("weather %s is not allowed" % WeatherManager.get_weather())
	for item_id in required_items:
		if not InventoryManager.has(item_id):
			reasons.append("required item %s is missing" % item_id)
	for event_id in required_seen_events:
		if not EventManager.has_seen(event_id):
			reasons.append("required event %s has not been seen" % event_id)
	for event_id in forbidden_seen_events:
		if EventManager.has_seen(event_id):
			reasons.append("forbidden event %s is already in history" % event_id)
	if not required_npc_id.is_empty() and not required_npc_state.is_empty():
		var actual_state := NpcStateBook.get_state(required_npc_id)
		if actual_state != required_npc_state:
			reasons.append("npc %s is %s, needs %s" % [required_npc_id, actual_state, required_npc_state])
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
	if random_chance < 1.0:
		var roller := rng if rng != null else RandomNumberGenerator.new()
		if rng == null:
			roller.seed = hash("%d:%s" % [CalendarManager.day_index, GameClock.get_period()])
		var roll := roller.randf()
		if roll >= random_chance:
			reasons.append("random chance %.2f missed (rolled %.2f)" % [random_chance, roll])
	return {"matches": reasons.is_empty(), "reasons": reasons}


static func is_within_time_range(time_minutes: int, range_start: int, range_end: int) -> bool:
	if range_start < 0 and range_end < 0:
		return true
	var start := range_start
	var end := range_end
	if start < 0:
		start = 0
	if end < 0:
		end = GameClock.MINUTES_PER_DAY - 1
	var minutes := posmod(time_minutes, GameClock.MINUTES_PER_DAY)
	if start <= end:
		return minutes >= start and minutes <= end
	return minutes >= start or minutes <= end


static func _format_time_bound(value: int) -> String:
	if value < 0:
		return "--:--"
	return "%02d:%02d" % [value / 60, value % 60]
