extends Node

signal record_created(record: DayRecord)
signal records_reset

var completed_records: Array[DayRecord] = []


func _ready() -> void:
	GameState.state_reset.connect(reset_records)


func create_current_day_record() -> DayRecord:
	var record := DayRecord.new()
	record.day = GameState.current_day
	record.end_minutes = GameClock.current_minutes
	record.end_area = GameState.current_area
	record.caught_insects = BugCatchingManager.to_save_data()
	for event_id in EventManager.event_history:
		if EventManager.has_triggered(event_id):
			record.triggered_events.append(event_id)
	completed_records.append(record)
	record_created.emit(record)
	return record


func get_latest_record() -> DayRecord:
	if completed_records.is_empty():
		return null
	return completed_records.back()


func reset_records() -> void:
	completed_records.clear()
	records_reset.emit()


func to_save_data() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record in completed_records:
		records.append(record.to_save_data())
	return records


func restore_from_save_data(data: Array) -> void:
	completed_records.clear()
	for record_data in data:
		if not record_data is Dictionary:
			continue
		var record := DayRecord.new()
		record.restore_from_save_data(record_data)
		completed_records.append(record)

