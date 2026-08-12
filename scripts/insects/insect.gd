class_name Insect
extends CharacterBody2D

signal state_changed(state: State)
signal catch_requested(insect: Insect, actor: Node)
signal caught(insect_id: StringName)

enum State {
	PERCHED,
	MOVING,
	CAUGHT,
}

const PLACEHOLDER_COLOR := Color("3a2f27")

@export var data: InsectData
@export var starts_moving: bool = true

var state: State = State.PERCHED
var movement_direction := Vector2.RIGHT
var _direction_timer: float = 0.0


func _ready() -> void:
	set_state(State.MOVING if starts_moving else State.PERCHED)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if state != State.MOVING or data == null:
		velocity = Vector2.ZERO
		return
	_direction_timer -= delta
	if _direction_timer <= 0.0:
		choose_next_direction()
	velocity = movement_direction * data.move_speed
	move_and_slide()


func set_state(value: State) -> void:
	if value == state:
		return
	state = value
	if state != State.MOVING:
		velocity = Vector2.ZERO
	state_changed.emit(state)


func choose_next_direction(random_angle: float = NAN) -> void:
	if data == null:
		return
	var angle := random_angle
	if is_nan(angle):
		angle = randf_range(0.0, TAU)
	movement_direction = Vector2.from_angle(angle).normalized()
	_direction_timer = maxf(data.direction_change_seconds, 0.1)


func request_catch(actor: Node) -> bool:
	if state == State.CAUGHT or data == null or not data.is_valid_insect():
		return false
	catch_requested.emit(self, actor)
	return true


func confirm_caught() -> void:
	if state == State.CAUGHT:
		return
	set_state(State.CAUGHT)
	caught.emit(data.insect_id if data != null else &"")
	visible = false
	set_physics_process(false)


func get_insect_id() -> StringName:
	return data.insect_id if data != null else &""


func _draw() -> void:
	# Production insect sprite未制作時だけ使用するPlaceholder。
	draw_circle(Vector2.ZERO, 3.0, PLACEHOLDER_COLOR)
	draw_line(Vector2(-2, -2), Vector2(-5, -5), PLACEHOLDER_COLOR, 1.0)
	draw_line(Vector2(2, -2), Vector2(5, -5), PLACEHOLDER_COLOR, 1.0)
	draw_line(Vector2(-2, 2), Vector2(-5, 5), PLACEHOLDER_COLOR, 1.0)
	draw_line(Vector2(2, 2), Vector2(5, 5), PLACEHOLDER_COLOR, 1.0)
