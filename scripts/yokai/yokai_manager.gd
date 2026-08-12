extends Node

signal stage_changed(yokai_id: StringName, stage: StringName)

const STAGES: Array[StringName] = [
	&"UNKNOWN", &"TRACE", &"SEEN", &"CONTACTED", &"FRIENDLY", &"CLOSE",
]

var _states: Dictionary = {}


func get_stage(yokai_id: StringName) -> StringName:
	return StringName(_states.get(yokai_id, {}).get("stage", &"UNKNOWN"))


func get_stage_index(stage: StringName) -> int:
	return STAGES.find(stage)


func set_stage(yokai_id: StringName, stage: StringName, allow_regression: bool = false) -> bool:
	var next_index := get_stage_index(stage)
	if yokai_id.is_empty() or next_index < 0:
		return false
	var current_index := get_stage_index(get_stage(yokai_id))
	if not allow_regression and next_index < current_index:
		return false
	if next_index == current_index:
		return true
	var state: Dictionary = _states.get(yokai_id, {}).duplicate(true)
	state["stage"] = stage
	_states[yokai_id] = state
	stage_changed.emit(yokai_id, stage)
	return true


func serialize() -> Dictionary:
	var result := {}
	for yokai_id: Variant in _states:
		result[String(yokai_id)] = (_states[yokai_id] as Dictionary).duplicate(true)
	return result


func deserialize(data: Dictionary) -> void:
	_states.clear()
	for yokai_id: Variant in data:
		var state: Variant = data[yokai_id]
		if not state is Dictionary:
			continue
		var stage := StringName(state.get("stage", &"UNKNOWN"))
		if get_stage_index(stage) < 0:
			stage = &"UNKNOWN"
		var clean_state := (state as Dictionary).duplicate(true)
		clean_state["stage"] = stage
		_states[StringName(yokai_id)] = clean_state


func reset_state() -> void:
	_states.clear()
