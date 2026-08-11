class_name ThirdPersonCamera
extends Node3D

@export_range(0.0001, 0.02, 0.0001) var mouse_sensitivity := 0.0025
@export_range(-89.0, 0.0, 1.0) var minimum_pitch_degrees := -55.0
@export_range(0.0, 89.0, 1.0) var maximum_pitch_degrees := 65.0
@export var capture_mouse_on_start := true

var _pitch := deg_to_rad(-12.0)
var _follow_target: Node3D
var _follow_offset := Vector3.ZERO


func _ready() -> void:
	_follow_target = get_parent_node_3d()
	_follow_offset = position
	top_level = true
	_update_follow_position()
	rotation.x = _pitch
	if capture_mouse_on_start and not Engine.is_editor_hint():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	_update_follow_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_camera(event.relative)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _rotate_camera(relative_motion: Vector2) -> void:
	rotation.y -= relative_motion.x * mouse_sensitivity
	_pitch = clampf(
		_pitch - relative_motion.y * mouse_sensitivity,
		deg_to_rad(minimum_pitch_degrees),
		deg_to_rad(maximum_pitch_degrees)
	)
	rotation.x = _pitch


func _update_follow_position() -> void:
	if is_instance_valid(_follow_target):
		global_position = _follow_target.global_position + _follow_offset
