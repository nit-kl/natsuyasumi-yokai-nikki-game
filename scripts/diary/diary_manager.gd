extends Node

signal record_changed(day_index: int)

var _records: Dictionary = {}


func get_or_create_record(day_index: int = CalendarManager.day_index) -> DayRecord:
	var valid_day := clampi(day_index, 1, 30)
	if not _records.has(valid_day):
		var record := DayRecord.new()
		record.day_index = valid_day
		record.wake_time = GameClock.time_minutes
		if valid_day == CalendarManager.day_index:
			record.weather = WeatherManager.get_weather()
		_records[valid_day] = record
	return _records[valid_day]


func has_record(day_index: int) -> bool:
	return _records.has(clampi(day_index, 1, 30))


func apply_weather(weather: StringName, day_index: int = CalendarManager.day_index) -> void:
	var record := get_or_create_record(day_index)
	if record.weather == weather:
		return
	record.weather = weather
	record_changed.emit(record.day_index)


func record_location(location_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.visited_locations, location_id)
	record_changed.emit(record.day_index)


func record_npc(npc_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.met_npcs, npc_id)
	record_changed.emit(record.day_index)


func record_yokai(yokai_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.met_yokai, yokai_id)
	record_changed.emit(record.day_index)


func record_insect(insect_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.caught_insects, insect_id)
	record_changed.emit(record.day_index)


func record_event(event_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.events_seen, event_id)
	record_changed.emit(record.day_index)


func add_fragment(fragment_id: StringName) -> void:
	var record := get_or_create_record()
	record.add_unique(record.diary_fragments, fragment_id)
	record_changed.emit(record.day_index)


func serialize() -> Dictionary:
	var days: Array[Dictionary] = []
	var keys := _records.keys()
	keys.sort()
	for day: Variant in keys:
		days.append((_records[day] as DayRecord).serialize())
	return {"days": days}


func deserialize(data: Dictionary) -> void:
	_records.clear()
	var days: Variant = data.get("days", [])
	if not days is Array:
		return
	for day_data: Variant in days:
		if day_data is Dictionary:
			var record := DayRecord.deserialize(day_data)
			_records[record.day_index] = record


func reset_state() -> void:
	_records.clear()
