extends Node

signal minute_changed(total_minutes: int)
signal period_changed(period: StringName)
signal day_end_requested()
signal pause_changed(is_paused: bool)

const MINUTES_PER_DAY := 1440
const DEFAULT_START_MINUTES := 420
const DEFAULT_MINUTES_PER_REAL_SECOND := 1.0
const PERIOD_MORNING: StringName = &"morning"
const PERIOD_DAYTIME: StringName = &"daytime"
const PERIOD_EVENING: StringName = &"evening"
const PERIOD_NIGHT: StringName = &"night"

var time_minutes: int = DEFAULT_START_MINUTES
var time_scale: float = 1.0
var is_paused: bool = false
var minutes_per_real_second: float = DEFAULT_MINUTES_PER_REAL_SECOND
var _minute_accumulator: float = 0.0
var _current_period: StringName = PERIOD_MORNING


func _ready() -> void:
	_current_period = get_period_for_minutes(time_minutes)


func _process(delta: float) -> void:
	if is_paused or time_scale <= 0.0:
		return
	_minute_accumulator += delta * minutes_per_real_second * time_scale
	var whole_minutes := int(_minute_accumulator)
	if whole_minutes > 0:
		_minute_accumulator -= whole_minutes
		advance_minutes(whole_minutes)


func advance_minutes(amount: int) -> void:
	if amount <= 0:
		return
	var unwrapped_minutes := time_minutes + amount
	var crossed_days := unwrapped_minutes / MINUTES_PER_DAY
	set_time_minutes(unwrapped_minutes % MINUTES_PER_DAY)
	for day in range(crossed_days):
		day_end_requested.emit()


func set_time_minutes(value: int) -> void:
	var normalized := posmod(value, MINUTES_PER_DAY)
	if normalized == time_minutes:
		return
	time_minutes = normalized
	minute_changed.emit(time_minutes)
	var next_period := get_period_for_minutes(time_minutes)
	if next_period != _current_period:
		_current_period = next_period
		period_changed.emit(_current_period)


func debug_set_time(hour: int, minute: int) -> void:
	set_time_minutes(clampi(hour, 0, 23) * 60 + clampi(minute, 0, 59))


func set_clock_paused(value: bool) -> void:
	if value == is_paused:
		return
	is_paused = value
	pause_changed.emit(is_paused)


func set_time_scale(value: float) -> void:
	time_scale = maxf(value, 0.0)


func get_period() -> StringName:
	return _current_period


func get_period_for_minutes(value: int) -> StringName:
	var normalized := posmod(value, MINUTES_PER_DAY)
	if normalized >= 300 and normalized < 600:
		return PERIOD_MORNING
	if normalized >= 600 and normalized < 990:
		return PERIOD_DAYTIME
	if normalized >= 990 and normalized < 1140:
		return PERIOD_EVENING
	return PERIOD_NIGHT


func get_time_text() -> String:
	return "%02d:%02d" % [time_minutes / 60, time_minutes % 60]


func serialize() -> Dictionary:
	return {"time_minutes": time_minutes}


func deserialize(data: Dictionary) -> void:
	set_time_minutes(int(data.get("time_minutes", DEFAULT_START_MINUTES)))
