class_name BugCatchPresenter
extends Node2D

const SWING_START_OFFSET := -0.85
const SWING_IMPACT_OFFSET := 0.22
const SWING_RETURN_OFFSET := -0.18
const SWING_SECONDS := 0.16
const RETURN_SECONDS := 0.12
const FEEDBACK_DELAY_SECONDS := 0.1
const FEEDBACK_SECONDS := 0.32
const NET_SOURCE_ANGLE := -PI / 4.0
const SUCCESS_COLOR := Color("ffe27a")
const MISS_COLOR := Color("d7edf0")

@onready var net_sprite: Sprite2D = %NetSprite
@onready var swing_audio: AudioStreamPlayer2D = %SwingAudio
@onready var success_audio: AudioStreamPlayer2D = %SuccessAudio

var _actor: CharacterBody2D
var _catcher: BugCatcher
var _swing_tween: Tween
var _feedback_tween: Tween
var _feedback_position := Vector2.ZERO
var _feedback_strength := 0.0
var _feedback_succeeded := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_actor = get_parent() as CharacterBody2D
	_catcher = _actor.get_node_or_null("BugCatcher") as BugCatcher if _actor != null else null
	if _catcher == null:
		return
	_catcher.tool_used.connect(_play_swing)
	_catcher.catch_succeeded.connect(_on_catch_succeeded)
	_catcher.catch_missed.connect(_on_catch_missed)
	net_sprite.visible = false


static func get_net_rotation_for_direction(direction: Vector2) -> float:
	return direction.angle() - NET_SOURCE_ANGLE


func _play_swing() -> void:
	if _actor == null:
		return
	if _swing_tween != null:
		_swing_tween.kill()
	var direction: Vector2 = _actor.get_facing_vector(_actor.facing)
	var base_rotation := get_net_rotation_for_direction(direction)
	swing_audio.play()
	z_index = -1 if direction.y < -0.25 else 2
	net_sprite.visible = true
	rotation = base_rotation + SWING_START_OFFSET
	_swing_tween = create_tween()
	_swing_tween.set_trans(Tween.TRANS_QUAD)
	_swing_tween.set_ease(Tween.EASE_OUT)
	_swing_tween.tween_property(self, "rotation", base_rotation + SWING_IMPACT_OFFSET, SWING_SECONDS)
	_swing_tween.set_ease(Tween.EASE_IN)
	_swing_tween.tween_property(self, "rotation", base_rotation + SWING_RETURN_OFFSET, RETURN_SECONDS)
	_swing_tween.tween_callback(func() -> void: net_sprite.visible = false)


func _on_catch_succeeded(_insect_id: StringName) -> void:
	_play_feedback(true)


func _on_catch_missed() -> void:
	_play_feedback(false)


func _play_feedback(succeeded: bool) -> void:
	if _actor == null:
		return
	if _feedback_tween != null:
		_feedback_tween.kill()
	_feedback_succeeded = succeeded
	_feedback_position = _actor.get_facing_vector(_actor.facing) * 28.0
	_feedback_strength = 0.0
	queue_redraw()
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(FEEDBACK_DELAY_SECONDS)
	if succeeded:
		_feedback_tween.tween_callback(success_audio.play)
	_feedback_tween.tween_method(_set_feedback_strength, 1.0, 0.0, FEEDBACK_SECONDS)


func _set_feedback_strength(value: float) -> void:
	_feedback_strength = value
	queue_redraw()


func _draw() -> void:
	if _feedback_strength <= 0.0:
		return
	var color := SUCCESS_COLOR if _feedback_succeeded else MISS_COLOR
	color.a = _feedback_strength
	var radius := lerpf(8.0, 15.0, 1.0 - _feedback_strength)
	if _feedback_succeeded:
		for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
			draw_line(
				_feedback_position + direction * (radius - 3.0),
				_feedback_position + direction * radius,
				color,
				1.0,
			)
		draw_arc(_feedback_position, radius * 0.45, 0.0, TAU, 12, color, 1.0)
	else:
		draw_arc(_feedback_position, radius * 0.55, -2.7, -0.45, 8, color, 1.0)
		draw_arc(_feedback_position + Vector2(3, 2), radius * 0.35, -2.7, -0.45, 6, color, 1.0)
