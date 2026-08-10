extends Node

signal time_changed(hour: int, minute: int)
signal period_changed(period: DayPeriod)
signal day_ended

enum DayPeriod {
	MORNING,
	DAY,
	EVENING,
	NIGHT,
}

const MINUTES_PER_DAY := 24 * 60

@export_range(0, 1439, 1) var morning_start_minutes := 5 * 60
@export_range(0, 1439, 1) var day_start_minutes := 10 * 60
@export_range(0, 1439, 1) var evening_start_minutes := 16 * 60 + 30
@export_range(0, 1439, 1) var night_start_minutes := 19 * 60
@export_range(0.1, 120.0, 0.1) var game_minutes_per_real_second := 1.0

var current_minutes := 7 * 60
var time_scale := 1.0
var clock_paused := false
var _minute_accumulator := 0.0
var _current_period := DayPeriod.MORNING


func _ready() -> void:
	_current_period = get_period()
	time_changed.emit(get_hour(), get_minute())
	period_changed.emit(_current_period)


func _process(delta: float) -> void:
	if clock_paused or is_zero_approx(time_scale):
		return
	_minute_accumulator += delta * game_minutes_per_real_second * time_scale
	var whole_minutes := floori(_minute_accumulator)
	if whole_minutes <= 0:
		return
	_minute_accumulator -= whole_minutes
	advance_minutes(whole_minutes)


func advance_minutes(minutes: int) -> void:
	if minutes <= 0:
		return
	var total_minutes := current_minutes + minutes
	var elapsed_days := total_minutes / MINUTES_PER_DAY
	current_minutes = total_minutes % MINUTES_PER_DAY
	for _day in range(elapsed_days):
		day_ended.emit()
	_emit_time_updates()


func set_time(hour: int, minute: int) -> void:
	current_minutes = clampi(hour, 0, 23) * 60 + clampi(minute, 0, 59)
	_minute_accumulator = 0.0
	_emit_time_updates()


func set_paused(value: bool) -> void:
	clock_paused = value


func set_time_scale(value: float) -> void:
	time_scale = maxf(value, 0.0)


func get_hour() -> int:
	return current_minutes / 60


func get_minute() -> int:
	return current_minutes % 60


func get_period() -> DayPeriod:
	if current_minutes >= night_start_minutes or current_minutes < morning_start_minutes:
		return DayPeriod.NIGHT
	if current_minutes >= evening_start_minutes:
		return DayPeriod.EVENING
	if current_minutes >= day_start_minutes:
		return DayPeriod.DAY
	return DayPeriod.MORNING


func get_period_name() -> String:
	return DayPeriod.keys()[get_period()].capitalize()


func get_time_text() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]


func _emit_time_updates() -> void:
	time_changed.emit(get_hour(), get_minute())
	var next_period := get_period()
	if next_period == _current_period:
		return
	_current_period = next_period
	period_changed.emit(_current_period)

