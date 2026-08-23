extends Node

signal weather_changed(weather: StringName)

enum Weather {
	SUNNY,
	CLOUDY,
	RAIN,
	THUNDERSTORM,
}

const DEFAULT_FORECAST_PATH := "res://resources/weather/default_weather_forecast.tres"
const WEATHER_SUNNY: StringName = &"sunny"
const WEATHER_CLOUDY: StringName = &"cloudy"
const WEATHER_RAIN: StringName = &"rain"
const WEATHER_THUNDERSTORM: StringName = &"thunderstorm"
const WEATHER_IDS: Array[StringName] = [
	WEATHER_SUNNY,
	WEATHER_CLOUDY,
	WEATHER_RAIN,
	WEATHER_THUNDERSTORM,
]

var forecast: WeatherForecast
var current_weather: StringName = WEATHER_SUNNY
var _rng := RandomNumberGenerator.new()
var _restore_depth := 0


func _ready() -> void:
	_rng.randomize()
	if forecast == null:
		forecast = load(DEFAULT_FORECAST_PATH) as WeatherForecast
	if forecast == null:
		forecast = WeatherForecast.new()
	current_weather = WeatherForecast.sanitize(forecast.first_day_weather)
	if not CalendarManager.day_changed.is_connected(_on_day_changed):
		CalendarManager.day_changed.connect(_on_day_changed)
	if not CalendarManager.day_advanced.is_connected(_on_day_advanced):
		CalendarManager.day_advanced.connect(_on_day_advanced)


func get_weather() -> StringName:
	return current_weather


func is_valid_weather(weather: StringName) -> bool:
	return WeatherForecast.is_valid_id(weather)


func weather_id_from_enum(value: Weather) -> StringName:
	if int(value) < 0 or int(value) >= WEATHER_IDS.size():
		return WEATHER_SUNNY
	return WEATHER_IDS[int(value)]


func set_weather(weather: StringName) -> bool:
	if not WeatherForecast.is_valid_id(weather):
		return false
	if weather == current_weather:
		return true
	current_weather = weather
	if _restore_depth == 0:
		weather_changed.emit(current_weather)
		_sync_current_day_record()
	return true


func debug_set_weather(weather: StringName) -> bool:
	return set_weather(weather)


func begin_restore() -> void:
	_restore_depth += 1


func end_restore() -> void:
	_restore_depth = maxi(_restore_depth - 1, 0)
	if _restore_depth == 0:
		weather_changed.emit(current_weather)
		_sync_current_day_record()


func serialize() -> String:
	return String(current_weather)


func deserialize(value: Variant) -> void:
	set_weather(WeatherForecast.sanitize(StringName(value)))


func reset_state() -> void:
	_restore_depth = 0
	var next_weather := WEATHER_SUNNY
	if forecast != null:
		next_weather = WeatherForecast.sanitize(forecast.first_day_weather)
	if next_weather == current_weather:
		_sync_current_day_record()
		return
	current_weather = next_weather
	weather_changed.emit(current_weather)
	_sync_current_day_record()


func _on_day_changed(day_index: int) -> void:
	if _restore_depth > 0:
		return
	if DiaryManager.has_record(day_index):
		set_weather(WeatherForecast.sanitize(DiaryManager.get_or_create_record(day_index).weather))


func _on_day_advanced(day_index: int) -> void:
	if _restore_depth > 0 or forecast == null:
		return
	set_weather(forecast.choose(day_index, current_weather, _rng))


func _sync_current_day_record() -> void:
	DiaryManager.apply_weather(current_weather)
