extends Node

signal event_started(event: EventDefinition)
signal event_completed(event_id: StringName)

var _events: Dictionary = {}
var _event_history: Dictionary = {}


func register_event(event: EventDefinition) -> bool:
	if event == null or not event.is_valid_event() or _events.has(event.event_id):
		return false
	_events[event.event_id] = event
	return true


func register_events(events: Array[EventDefinition]) -> void:
	for event in events:
		register_event(event)


func unregister_event(event_id: StringName) -> void:
	_events.erase(event_id)


func has_seen(event_id: StringName) -> bool:
	return bool(_event_history.get(event_id, false))


func explain_event(event: EventDefinition) -> Dictionary:
	if event == null or not event.is_valid_event():
		return {"matches": false, "reasons": ["invalid event"]}
	if event.one_shot and has_seen(event.event_id):
		return {"matches": false, "reasons": ["one-shot event already completed"]}
	return event.condition.evaluate(_rng_for_event(event.event_id))


func get_candidates() -> Array[EventDefinition]:
	var candidates: Array[EventDefinition] = []
	for event: EventDefinition in _events.values():
		if bool(explain_event(event).get("matches", false)):
			candidates.append(event)
	candidates.sort_custom(func(a: EventDefinition, b: EventDefinition) -> bool:
		if a.priority == b.priority:
			return String(a.event_id) < String(b.event_id)
		return a.priority > b.priority
	)
	var filtered: Array[EventDefinition] = []
	var used_groups: Dictionary = {}
	for event in candidates:
		if not event.exclusive_group.is_empty() and used_groups.has(event.exclusive_group):
			continue
		filtered.append(event)
		if not event.exclusive_group.is_empty():
			used_groups[event.exclusive_group] = true
	return filtered


func trigger_event(event_id: StringName, force: bool = false) -> bool:
	var event: EventDefinition = _events.get(event_id)
	if event == null or (not force and not bool(explain_event(event).get("matches", false))):
		return false
	event_started.emit(event)
	for action in event.actions:
		if action != null:
			action.execute()
	_event_history[event.event_id] = true
	event_completed.emit(event.event_id)
	return true


func trigger_highest_priority() -> bool:
	var candidates := get_candidates()
	return not candidates.is_empty() and trigger_event(candidates[0].event_id)


func get_debug_report() -> Array[Dictionary]:
	var report: Array[Dictionary] = []
	for event: EventDefinition in _events.values():
		var result := explain_event(event)
		report.append({
			"event_id": event.event_id,
			"priority": event.priority,
			"matches": result.get("matches", false),
			"reasons": result.get("reasons", []),
		})
	report.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.priority) > int(b.priority))
	return report


func serialize_history() -> Array[String]:
	var keys: Array = _event_history.keys()
	keys.sort()
	return keys.map(func(value: Variant) -> String: return String(value))


func deserialize_history(history: Array) -> void:
	_event_history.clear()
	for event_id: Variant in history:
		var id := StringName(event_id)
		if not id.is_empty():
			_event_history[id] = true


func reset_runtime() -> void:
	_events.clear()
	_event_history.clear()


func _rng_for_event(event_id: StringName) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%s:%s" % [CalendarManager.day_index, GameClock.get_period(), String(event_id)])
	return rng
