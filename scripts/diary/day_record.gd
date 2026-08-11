class_name DayRecord
extends Resource

@export var day := 1
@export var end_minutes := 0
@export var end_area: StringName
@export var caught_insects: Dictionary = {}
@export var triggered_events: Array[StringName] = []


func get_total_insects() -> int:
	var total := 0
	for count in caught_insects.values():
		total += int(count)
	return total


func get_end_time_text() -> String:
	return "%02d:%02d" % [end_minutes / 60, end_minutes % 60]


func to_save_data() -> Dictionary:
	var event_ids: Array[String] = []
	for event_id in triggered_events:
		event_ids.append(String(event_id))
	return {
		"day": day,
		"end_minutes": end_minutes,
		"end_area": String(end_area),
		"caught_insects": caught_insects.duplicate(true),
		"triggered_events": event_ids,
	}


func restore_from_save_data(data: Dictionary) -> void:
	day = maxi(int(data.get("day", 1)), 1)
	end_minutes = clampi(int(data.get("end_minutes", 0)), 0, GameClock.MINUTES_PER_DAY - 1)
	end_area = StringName(data.get("end_area", "grandma_house"))
	caught_insects = data.get("caught_insects", {}).duplicate(true)
	triggered_events.clear()
	for event_id in data.get("triggered_events", []):
		triggered_events.append(StringName(event_id))

