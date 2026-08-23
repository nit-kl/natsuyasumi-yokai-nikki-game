class_name WeatherVisualPalette
extends Resource

@export var sunny_tint := Color(1, 1, 1, 1)
@export var cloudy_tint := Color("e1e6ef")
@export var rain_tint := Color("ccd8e8")
@export var thunderstorm_tint := Color("bdcce0")
@export_range(0.2, 1.0, 0.01) var minimum_night_luminance := 0.38


func get_tint(weather: StringName) -> Color:
	match weather:
		&"cloudy":
			return cloudy_tint
		&"rain":
			return rain_tint
		&"thunderstorm":
			return thunderstorm_tint
		_:
			return sunny_tint


func compose(period_color: Color, weather: StringName, period: StringName) -> Color:
	var composed := period_color * get_tint(weather)
	composed.a = 1.0
	if period != GameClock.PERIOD_NIGHT:
		return composed
	var luminance := composed.get_luminance()
	if luminance >= minimum_night_luminance or luminance <= 0.0:
		return composed
	var lift := minimum_night_luminance / luminance
	return Color(
		minf(composed.r * lift, 1.0),
		minf(composed.g * lift, 1.0),
		minf(composed.b * lift, 1.0),
		1.0,
	)
