class_name ProtagonistVisual
extends Node3D

@export var controller_path := NodePath("..")
@export_range(1.0, 20.0, 0.1) var walk_cycle_speed := 9.0
@export_range(0.0, 1.2, 0.01) var limb_swing_radians := 0.58

var _controller: CharacterBody3D
var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _base_position := Vector3.ZERO
var _cycle := 0.0


func _ready() -> void:
	_controller = get_node(controller_path) as CharacterBody3D
	_left_arm = find_child("LeftArm", true, false) as Node3D
	_right_arm = find_child("RightArm", true, false) as Node3D
	_left_leg = find_child("LeftLeg", true, false) as Node3D
	_right_leg = find_child("RightLeg", true, false) as Node3D
	_base_position = position
	if _left_arm == null or _right_arm == null or _left_leg == null or _right_leg == null:
		set_process(false)


func _process(delta: float) -> void:
	var horizontal_speed := Vector2(_controller.velocity.x, _controller.velocity.z).length()
	var movement_weight := clampf(horizontal_speed / 5.0, 0.0, 1.0)
	_cycle += delta * walk_cycle_speed * maxf(movement_weight, 0.2)
	var swing := sin(_cycle) * limb_swing_radians * movement_weight
	var smoothing := 1.0 - exp(-12.0 * delta)
	_left_arm.rotation.x = lerp_angle(_left_arm.rotation.x, swing, smoothing)
	_right_arm.rotation.x = lerp_angle(_right_arm.rotation.x, -swing, smoothing)
	_left_leg.rotation.x = lerp_angle(_left_leg.rotation.x, -swing, smoothing)
	_right_leg.rotation.x = lerp_angle(_right_leg.rotation.x, swing, smoothing)
	position.y = _base_position.y + absf(sin(_cycle * 2.0)) * 0.025 * movement_weight
