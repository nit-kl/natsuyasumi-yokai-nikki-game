class_name DioramaCamera
extends Node3D

@export_range(-80.0, -20.0, 1.0) var pitch_degrees := -50.0
@export_range(-180.0, 180.0, 1.0) var yaw_degrees := -40.0
@export_range(0.0, 30.0, 0.5) var follow_sharpness := 9.0

var _follow_target: Node3D
var _follow_offset := Vector3.ZERO


func _ready() -> void:
	_follow_target = get_parent_node_3d()
	_follow_offset = position
	top_level = true
	rotation_degrees = Vector3(pitch_degrees, yaw_degrees, 0.0)
	snap_to_target()
	if not Engine.is_editor_hint():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	if not is_instance_valid(_follow_target):
		return
	var target_position := _follow_target.global_position + _follow_offset
	var weight := 1.0 - exp(-follow_sharpness * delta)
	global_position = global_position.lerp(target_position, weight)


func snap_to_target() -> void:
	if is_instance_valid(_follow_target):
		global_position = _follow_target.global_position + _follow_offset
