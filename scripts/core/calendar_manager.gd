extends Node

signal day_changed(day_index: int)
signal final_day_reached()

const FIRST_DAY := 1
const LAST_DAY := 30

var day_index: int = FIRST_DAY


func next_day() -> bool:
	if day_index >= LAST_DAY:
		final_day_reached.emit()
		return false
	set_day(day_index + 1)
	return true


func set_day(value: int) -> void:
	var clamped_day := clampi(value, FIRST_DAY, LAST_DAY)
	if clamped_day == day_index:
		return
	day_index = clamped_day
	day_changed.emit(day_index)


func debug_set_day(value: int) -> void:
	set_day(value)


func is_final_day() -> bool:
	return day_index == LAST_DAY


func serialize() -> Dictionary:
	return {"day_index": day_index}


func deserialize(data: Dictionary) -> void:
	set_day(int(data.get("day_index", FIRST_DAY)))
