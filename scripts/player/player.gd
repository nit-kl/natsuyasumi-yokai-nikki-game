extends CharacterBody2D

signal facing_changed(facing: StringName)
signal movement_changed(is_moving: bool, is_running: bool)
signal interaction_candidate_changed(target: Node, prompt_text: String)
signal interaction_performed(target: Node)
signal bug_catch_succeeded(insect_id: StringName)
signal bug_catch_missed()

const FACING_DOWN: StringName = &"down"
const FACING_DOWN_LEFT: StringName = &"down_left"
const FACING_LEFT: StringName = &"left"
const FACING_UP_LEFT: StringName = &"up_left"
const FACING_UP: StringName = &"up"
const FACING_UP_RIGHT: StringName = &"up_right"
const FACING_RIGHT: StringName = &"right"
const FACING_DOWN_RIGHT: StringName = &"down_right"
const DIAGONAL_THRESHOLD := 0.41421356

@export_range(1.0, 300.0, 1.0, "or_greater") var walk_speed: float = 80.0
@export_range(1.0, 400.0, 1.0, "or_greater") var run_speed: float = 128.0

var facing: StringName = FACING_DOWN
var movement_locked: bool = false
var is_moving: bool = false
var is_running: bool = false

@onready var click_move_controller := get_node_or_null("%ClickMoveController") as ClickMoveController
@onready var click_action_controller := get_node_or_null("%ClickActionController") as ClickActionController


func _ready() -> void:
	GameState.register_player(self)
	refresh_depth_order()
	var interaction_detector := get_node_or_null("InteractionDetector")
	if interaction_detector != null:
		interaction_detector.candidate_changed.connect(_on_interaction_candidate_changed)
		interaction_detector.interaction_performed.connect(_on_interaction_performed)
	var bug_catcher := get_node_or_null("BugCatcher")
	if bug_catcher != null:
		bug_catcher.catch_succeeded.connect(bug_catch_succeeded.emit)
		bug_catcher.catch_missed.connect(bug_catch_missed.emit)


func _exit_tree() -> void:
	if GameState.player == self:
		GameState.player = null


func _physics_process(delta: float) -> void:
	if movement_locked or GameState.is_paused:
		if click_action_controller != null:
			click_action_controller.cancel_action()
		if click_move_controller != null:
			click_move_controller.cancel_movement()
		_apply_movement(Vector2.ZERO, false, delta)
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not input_direction.is_zero_approx():
		if click_action_controller != null:
			click_action_controller.cancel_action()
		if click_move_controller != null:
			click_move_controller.cancel_movement()
	elif click_move_controller != null:
		input_direction = click_move_controller.get_movement_direction()
	_apply_movement(input_direction, Input.is_action_pressed("run"), delta)


func set_movement_locked(value: bool) -> void:
	movement_locked = value
	if movement_locked:
		if click_action_controller != null:
			click_action_controller.cancel_action()
		if click_move_controller != null:
			click_move_controller.cancel_movement()
		_apply_movement(Vector2.ZERO, false, 0.0)


func get_move_speed(running: bool) -> float:
	return run_speed if running else walk_speed


func _apply_movement(direction: Vector2, wants_to_run: bool, delta: float = 1.0 / 60.0) -> void:
	var normalized_direction := direction.limit_length(1.0)
	var wants_to_move := not normalized_direction.is_zero_approx()
	velocity = normalized_direction * get_move_speed(wants_to_run and wants_to_move)
	if wants_to_move:
		_set_facing(direction_to_facing(normalized_direction, facing))
	var previous_position := global_position
	var walk_path := _get_walk_path_network()
	if walk_path != null and walk_path.has_paths():
		global_position = walk_path.constrain_step(global_position, normalized_direction, velocity.length() * delta)
	else:
		move_and_slide()
	var next_is_moving := global_position.distance_squared_to(previous_position) > 0.0001 \
		if walk_path != null and walk_path.has_paths() else wants_to_move
	var next_is_running := next_is_moving and wants_to_run
	if next_is_moving != is_moving or next_is_running != is_running:
		is_moving = next_is_moving
		is_running = next_is_running
		movement_changed.emit(is_moving, is_running)
	refresh_depth_order()


func snap_to_walk_path() -> void:
	var walk_path := _get_walk_path_network()
	if walk_path != null and walk_path.has_paths():
		global_position = walk_path.get_closest_point(global_position).round()


func _get_walk_path_network() -> Node:
	return get_tree().get_first_node_in_group(&"walk_path_network")


func refresh_depth_order() -> void:
	z_index = roundi(_get_foot_y())


func _get_foot_y() -> float:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return global_position.y
	return collision.to_global(Vector2(0.0, collision.shape.get_rect().end.y)).y


func _set_facing(value: StringName) -> void:
	if value == facing:
		return
	facing = value
	facing_changed.emit(facing)


func set_facing(value: StringName) -> void:
	if value not in [
		FACING_DOWN, FACING_DOWN_LEFT, FACING_LEFT, FACING_UP_LEFT,
		FACING_UP, FACING_UP_RIGHT, FACING_RIGHT, FACING_DOWN_RIGHT,
	]:
		return
	_set_facing(value)


static func direction_to_facing(direction: Vector2, fallback: StringName = FACING_DOWN) -> StringName:
	if direction.is_zero_approx():
		return fallback
	var horizontal_strength := absf(direction.x)
	var vertical_strength := absf(direction.y)
	if horizontal_strength < vertical_strength * DIAGONAL_THRESHOLD:
		return FACING_DOWN if direction.y > 0.0 else FACING_UP
	if vertical_strength < horizontal_strength * DIAGONAL_THRESHOLD:
		return FACING_RIGHT if direction.x > 0.0 else FACING_LEFT
	if direction.y > 0.0:
		return FACING_DOWN_RIGHT if direction.x > 0.0 else FACING_DOWN_LEFT
	return FACING_UP_RIGHT if direction.x > 0.0 else FACING_UP_LEFT


static func get_facing_vector(value: StringName) -> Vector2:
	match value:
		FACING_DOWN_LEFT:
			return Vector2(-1, 1).normalized()
		FACING_LEFT:
			return Vector2.LEFT
		FACING_UP_LEFT:
			return Vector2(-1, -1).normalized()
		FACING_UP:
			return Vector2.UP
		FACING_UP_RIGHT:
			return Vector2(1, -1).normalized()
		FACING_RIGHT:
			return Vector2.RIGHT
		FACING_DOWN_RIGHT:
			return Vector2(1, 1).normalized()
		_:
			return Vector2.DOWN


func _on_interaction_candidate_changed(target: Node, prompt_text: String) -> void:
	interaction_candidate_changed.emit(target, prompt_text)


func _on_interaction_performed(target: Node) -> void:
	interaction_performed.emit(target)
