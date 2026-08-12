class_name DayRecord
extends Resource

@export var day_index: int = 1
@export var weather: StringName = &"sunny"
@export var wake_time: int = 420
@export var sleep_time: int = -1
@export var visited_locations: Array[StringName] = []
@export var met_npcs: Array[StringName] = []
@export var met_yokai: Array[StringName] = []
@export var caught_insects: Array[StringName] = []
@export var caught_fish: Array[StringName] = []
@export var events_seen: Array[StringName] = []
@export var diary_fragments: Array[StringName] = []
@export var photos: Array[String] = []


func add_unique(collection: Array[StringName], value: StringName) -> void:
	if not value.is_empty() and not collection.has(value):
		collection.append(value)


func serialize() -> Dictionary:
	return {
		"day_index": day_index,
		"weather": String(weather),
		"wake_time": wake_time,
		"sleep_time": sleep_time,
		"visited_locations": _to_strings(visited_locations),
		"met_npcs": _to_strings(met_npcs),
		"met_yokai": _to_strings(met_yokai),
		"caught_insects": _to_strings(caught_insects),
		"caught_fish": _to_strings(caught_fish),
		"events_seen": _to_strings(events_seen),
		"diary_fragments": _to_strings(diary_fragments),
		"photos": photos.duplicate(),
	}


static func deserialize(data: Dictionary) -> DayRecord:
	var record := DayRecord.new()
	record.day_index = clampi(int(data.get("day_index", 1)), 1, 30)
	record.weather = StringName(data.get("weather", "sunny"))
	record.wake_time = clampi(int(data.get("wake_time", 420)), 0, 1439)
	record.sleep_time = clampi(int(data.get("sleep_time", -1)), -1, 1439)
	record.visited_locations = _to_string_names(data.get("visited_locations", []))
	record.met_npcs = _to_string_names(data.get("met_npcs", []))
	record.met_yokai = _to_string_names(data.get("met_yokai", []))
	record.caught_insects = _to_string_names(data.get("caught_insects", []))
	record.caught_fish = _to_string_names(data.get("caught_fish", []))
	record.events_seen = _to_string_names(data.get("events_seen", []))
	record.diary_fragments = _to_string_names(data.get("diary_fragments", []))
	var saved_photos: Variant = data.get("photos", [])
	if saved_photos is Array:
		for photo: Variant in saved_photos:
			record.photos.append(String(photo))
	return record


static func _to_strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result


static func _to_string_names(values: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if values is Array:
		for value: Variant in values:
			var id := StringName(value)
			if not id.is_empty() and not result.has(id):
				result.append(id)
	return result
