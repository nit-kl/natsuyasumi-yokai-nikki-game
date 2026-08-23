class_name EnvironmentAudioProfile
extends Resource

@export var area_id: StringName
@export var default_stream: AudioStream
@export var morning_stream: AudioStream
@export var daytime_stream: AudioStream
@export var evening_stream: AudioStream
@export var night_stream: AudioStream
@export var apply_weather_streams := false
@export var rain_stream: AudioStream
@export var thunderstorm_stream: AudioStream
@export_range(-40.0, 6.0, 0.5) var volume_db := -8.0


func get_stream(period: StringName, weather: StringName = &"sunny") -> AudioStream:
	if apply_weather_streams:
		match weather:
			&"rain":
				if rain_stream != null:
					return rain_stream
			&"thunderstorm":
				if thunderstorm_stream != null:
					return thunderstorm_stream
				if rain_stream != null:
					return rain_stream
	var period_stream: AudioStream
	match period:
		&"morning":
			period_stream = morning_stream
		&"daytime":
			period_stream = daytime_stream
		&"evening":
			period_stream = evening_stream
		&"night":
			period_stream = night_stream
	return period_stream if period_stream != null else default_stream


func is_valid_profile() -> bool:
	return not area_id.is_empty()
