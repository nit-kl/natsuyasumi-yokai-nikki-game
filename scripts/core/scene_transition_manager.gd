extends Node

signal transition_started(scene_path: String)
signal transition_finished(scene_path: String)
signal transition_failed(scene_path: String, error: Error)

var is_transitioning: bool = false
var _pending_spawn_id: StringName


func change_scene(scene_path: String, spawn_id: StringName = &"") -> Error:
	if is_transitioning or not ResourceLoader.exists(scene_path, "PackedScene"):
		var validation_error := ERR_BUSY if is_transitioning else ERR_FILE_NOT_FOUND
		transition_failed.emit(scene_path, validation_error)
		return validation_error
	is_transitioning = true
	_pending_spawn_id = spawn_id
	transition_started.emit(scene_path)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		is_transitioning = false
		_pending_spawn_id = &""
		transition_failed.emit(scene_path, error)
		return error
	await get_tree().process_frame
	is_transitioning = false
	transition_finished.emit(scene_path)
	return OK


func consume_spawn_id(fallback: StringName = &"default") -> StringName:
	var result := _pending_spawn_id if not _pending_spawn_id.is_empty() else fallback
	_pending_spawn_id = &""
	return result
