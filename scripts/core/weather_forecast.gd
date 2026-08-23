class_name WeatherForecast
extends Resource

const ID_SUNNY: StringName = &"sunny"
const ID_CLOUDY: StringName = &"cloudy"
const ID_RAIN: StringName = &"rain"
const ID_THUNDERSTORM: StringName = &"thunderstorm"

const ALL_IDS: Array[StringName] = [
	ID_SUNNY,
	ID_CLOUDY,
	ID_RAIN,
	ID_THUNDERSTORM,
]

@export var first_day_weather: StringName = ID_SUNNY
@export var sunny_weight: float = 50.0
@export var cloudy_weight: float = 27.0
@export var rain_weight: float = 18.0
@export var thunderstorm_weight: float = 5.0
@export var override_day_indexes: Array[int] = []
@export var override_weathers: Array[StringName] = []


static func is_valid_id(weather: StringName) -> bool:
	return ALL_IDS.has(weather)


static func sanitize(weather: StringName, fallback: StringName = ID_SUNNY) -> StringName:
	return weather if is_valid_id(weather) else fallback


func get_override(day_index: int) -> StringName:
	var count := mini(override_day_indexes.size(), override_weathers.size())
	for index in range(count):
		if override_day_indexes[index] == day_index:
			return sanitize(override_weathers[index], &"")
	return &""


func choose(day_index: int, _previous_weather: StringName, rng: RandomNumberGenerator) -> StringName:
	var override_weather := get_override(day_index)
	if not override_weather.is_empty():
		return override_weather
	if day_index <= CalendarManager.FIRST_DAY:
		return sanitize(first_day_weather)
	return _pick_weighted(rng)


func _pick_weighted(rng: RandomNumberGenerator) -> StringName:
	var entries: Array[Array] = [
		[ID_SUNNY, maxf(sunny_weight, 0.0)],
		[ID_CLOUDY, maxf(cloudy_weight, 0.0)],
		[ID_RAIN, maxf(rain_weight, 0.0)],
		[ID_THUNDERSTORM, maxf(thunderstorm_weight, 0.0)],
	]
	var total := 0.0
	for entry in entries:
		total += float(entry[1])
	if total <= 0.0:
		return sanitize(first_day_weather)
	var roll := rng.randf() * total
	var accumulated := 0.0
	for entry in entries:
		accumulated += float(entry[1])
		if roll <= accumulated:
			return entry[0]
	return entries[entries.size() - 1][0]
