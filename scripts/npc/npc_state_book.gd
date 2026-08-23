extends Node

const DEFAULT_STATE: StringName = &"normal"

var _states: Dictionary = {}


func get_state(npc_id: StringName) -> StringName:
	if npc_id.is_empty():
		return &""
	return StringName(_states.get(npc_id, DEFAULT_STATE))


func set_state(npc_id: StringName, state: StringName) -> bool:
	if npc_id.is_empty() or state.is_empty():
		return false
	_states[npc_id] = state
	return true


func reset_state() -> void:
	_states.clear()


func serialize() -> Dictionary:
	var data := {}
	var keys := _states.keys()
	keys.sort()
	for npc_id: Variant in keys:
		data[String(npc_id)] = {
			"state": String(_states[npc_id]),
		}
	return data


func deserialize(data: Variant) -> void:
	_states.clear()
	if not data is Dictionary:
		return
	for npc_id: Variant in data:
		var entry: Variant = data[npc_id]
		var state := &""
		if entry is Dictionary:
			state = StringName(entry.get("state", DEFAULT_STATE))
		else:
			state = StringName(entry)
		if StringName(npc_id).is_empty() or state.is_empty():
			continue
		_states[StringName(npc_id)] = state
