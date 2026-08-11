extends Node

signal event_registered(event: EventDefinition)
signal event_triggered(event: EventDefinition)
signal history_reset

var registered_events: Dictionary = {}
var event_history: Dictionary = {}


func register_event(event: EventDefinition) -> bool:
	if event == null or not event.is_valid():
		return false
	registered_events[event.event_id] = event
	event_registered.emit(event)
	return true


func unregister_event(event_id: StringName) -> void:
	registered_events.erase(event_id)


func get_candidates(
	location: StringName,
	minutes: int,
	world_flags: Dictionary = {}
) -> Array[EventDefinition]:
	var candidates: Array[EventDefinition] = []
	for event in registered_events.values():
		if event.one_shot and has_triggered(event.event_id):
			continue
		if event.matches(location, minutes, world_flags):
			candidates.append(event)
	candidates.sort_custom(
		func(a: EventDefinition, b: EventDefinition) -> bool: return a.priority > b.priority
	)
	return candidates


func try_trigger(
	event: EventDefinition,
	location: StringName,
	minutes: int,
	world_flags: Dictionary = {}
) -> bool:
	if event == null or not event.matches(location, minutes, world_flags):
		return false
	if event.one_shot and has_triggered(event.event_id):
		return false
	var trigger_count := int(event_history.get(event.event_id, 0)) + 1
	event_history[event.event_id] = trigger_count
	event_triggered.emit(event)
	return true


func has_triggered(event_id: StringName) -> bool:
	return int(event_history.get(event_id, 0)) > 0


func get_trigger_count(event_id: StringName) -> int:
	return int(event_history.get(event_id, 0))


func reset_history() -> void:
	event_history.clear()
	history_reset.emit()


func to_save_data() -> Dictionary:
	var data := {}
	for event_id in event_history:
		data[String(event_id)] = event_history[event_id]
	return data


func restore_from_save_data(data: Dictionary) -> void:
	event_history.clear()
	for event_id in data:
		event_history[StringName(event_id)] = maxi(int(data[event_id]), 0)

