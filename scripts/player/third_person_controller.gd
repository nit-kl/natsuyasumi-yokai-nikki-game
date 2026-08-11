class_name ThirdPersonController
extends CharacterBody3D

@export_range(0.0, 20.0, 0.1) var move_speed := 5.0
@export_range(0.0, 50.0, 0.1) var ground_acceleration := 24.0
@export_range(0.0, 50.0, 0.1) var ground_deceleration := 30.0
@export_range(0.0, 20.0, 0.1) var jump_velocity := 5.5
@export_range(0.0, 30.0, 0.1) var rotation_speed := 12.0

@onready var camera_pivot: Node3D = %CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	if (
		DialogueManager.is_active
		or DayFlowManager.is_summary_active
		or DiaryManager.is_editing
		or GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE
	):
		_stop_horizontal_movement(delta)
		move_and_slide()
		return
	_apply_jump()
	_apply_horizontal_movement(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _apply_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


func _apply_horizontal_movement(delta: float) -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)
	var direction := get_camera_relative_direction(input_vector)
	var target_velocity := direction * move_speed
	var acceleration := ground_acceleration if not direction.is_zero_approx() else ground_deceleration

	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if not direction.is_zero_approx():
		var target_rotation := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)


func _stop_horizontal_movement(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
	velocity.z = move_toward(velocity.z, 0.0, ground_deceleration * delta)


func get_camera_relative_direction(input_vector: Vector2) -> Vector3:
	if input_vector.is_zero_approx():
		return Vector3.ZERO

	var camera_forward := camera_pivot.global_basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()

	var camera_right := camera_pivot.global_basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()

	return (camera_right * input_vector.x + camera_forward * input_vector.y).normalized()
