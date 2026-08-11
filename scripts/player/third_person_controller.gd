class_name ThirdPersonController
extends CharacterBody3D

const FALLBACK_SPAWN_POSITION := Vector3(0.0, 0.15, 15.75)
const SAFE_WORLD_BOUNDS := AABB(Vector3(-22.0, -3.0, -33.0), Vector3(44.0, 15.0, 68.0))

@export_range(0.0, 20.0, 0.1) var move_speed := 5.0
@export_range(0.0, 50.0, 0.1) var ground_acceleration := 24.0
@export_range(0.0, 50.0, 0.1) var ground_deceleration := 30.0
@export_range(0.0, 20.0, 0.1) var jump_velocity := 5.5
@export_range(0.0, 30.0, 0.1) var rotation_speed := 12.0

@onready var camera_pivot: Node3D = %CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _ready() -> void:
	SaveManager.save_started.connect(_store_player_state)
	SaveManager.load_completed.connect(_on_load_completed)


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


func _store_player_state() -> void:
	GameState.player_state = {
		"position": [global_position.x, global_position.y, global_position.z],
		"rotation_y": rotation.y,
	}


func _on_load_completed(_path: String) -> void:
	var position_data = GameState.player_state.get("position", [])
	if position_data is Array and position_data.size() == 3:
		var loaded_position := Vector3(
			float(position_data[0]),
			float(position_data[1]),
			float(position_data[2])
		)
		global_position = loaded_position if _is_safe_loaded_position(loaded_position) else FALLBACK_SPAWN_POSITION
	var loaded_rotation := float(GameState.player_state.get("rotation_y", rotation.y))
	rotation.y = loaded_rotation if is_finite(loaded_rotation) else 0.0
	var diorama_camera := camera_pivot as DioramaCamera
	if diorama_camera != null:
		diorama_camera.snap_to_target()
	velocity = Vector3.ZERO


func _is_safe_loaded_position(candidate: Vector3) -> bool:
	return candidate.is_finite() and SAFE_WORLD_BOUNDS.has_point(candidate)
