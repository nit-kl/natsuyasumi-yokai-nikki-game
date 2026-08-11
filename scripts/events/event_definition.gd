class_name EventDefinition
extends Resource

@export var event_id: StringName
@export var display_name := ""
@export_multiline var hint_text := ""
@export var priority := 0
@export var location_id: StringName
@export_range(0, 1439, 1) var start_minutes := 0
@export_range(0, 1439, 1) var end_minutes := 1439
@export var required_flags: Array[StringName] = []
@export var forbidden_flags: Array[StringName] = []
@export var one_shot := true


func is_valid() -> bool:
	return not event_id.is_empty() and not location_id.is_empty()


func matches(location: StringName, minutes: int, world_flags: Dictionary = {}) -> bool:
	if not is_valid() or location != location_id or not _matches_time(minutes):
		return false
	for flag in required_flags:
		if not bool(world_flags.get(flag, false)):
			return false
	for flag in forbidden_flags:
		if bool(world_flags.get(flag, false)):
			return false
	return true


func _matches_time(minutes: int) -> bool:
	var normalized_minutes := posmod(minutes, GameClock.MINUTES_PER_DAY)
	if start_minutes <= end_minutes:
		return normalized_minutes >= start_minutes and normalized_minutes <= end_minutes
	return normalized_minutes >= start_minutes or normalized_minutes <= end_minutes
