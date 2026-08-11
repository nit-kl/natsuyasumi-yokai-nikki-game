class_name AmbientProfile
extends Resource

@export var area_id: StringName
@export var morning_stream: AudioStream
@export var day_stream: AudioStream
@export var evening_stream: AudioStream
@export var night_stream: AudioStream


func is_valid() -> bool:
	return not area_id.is_empty()


func get_stream(period: GameClock.DayPeriod) -> AudioStream:
	match period:
		GameClock.DayPeriod.MORNING:
			return morning_stream
		GameClock.DayPeriod.DAY:
			return day_stream
		GameClock.DayPeriod.EVENING:
			return evening_stream
		GameClock.DayPeriod.NIGHT:
			return night_stream
	return null
