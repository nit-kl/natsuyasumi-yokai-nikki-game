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


func _ready() -> void:
	GameState.register_player(self)
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


func _physics_process(_delta: float) -> void:
	if movement_locked or GameState.is_paused:
		_apply_movement(Vector2.ZERO, false)
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_apply_movement(input_direction, Input.is_action_pressed("run"))


func set_movement_locked(value: bool) -> void:
	movement_locked = value
	if movement_locked:
		_apply_movement(Vector2.ZERO, false)


func get_move_speed(running: bool) -> float:
	return run_speed if running else walk_speed


func _apply_movement(direction: Vector2, wants_to_run: bool) -> void:
	var normalized_direction := direction.limit_length(1.0)
	var next_is_moving := not normalized_direction.is_zero_approx()
	var next_is_running := next_is_moving and wants_to_run
	velocity = normalized_direction * get_move_speed(next_is_running)
	if next_is_moving:
		_set_facing(direction_to_facing(normalized_direction, facing))
	if next_is_moving != is_moving or next_is_running != is_running:
		is_moving = next_is_moving
		is_running = next_is_running
		movement_changed.emit(is_moving, is_running)
	move_and_slide()


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
