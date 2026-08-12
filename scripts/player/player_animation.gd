class_name PlayerAnimationController
extends AnimatedSprite2D

signal visual_state_changed(animation_name: StringName)

const PLACEHOLDER_COLOR := Color("4f86c6")
const PLACEHOLDER_OUTLINE := Color("183153")
const PLACEHOLDER_SKIN := Color("f1c27d")
const WALK_STEP_SECONDS := 0.14
const RUN_STEP_SECONDS := 0.09

var desired_animation: StringName = &"idle_down"
var _facing: StringName = &"down"
var _is_moving := false
var _is_running := false
var _step_elapsed := 0.0
var _step_index := 0
var _uses_production_frames := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	var player := get_parent()
	if player != null:
		player.facing_changed.connect(_on_facing_changed)
		player.movement_changed.connect(_on_movement_changed)
		_facing = StringName(player.get("facing"))
		_is_moving = bool(player.get("is_moving"))
		_is_running = bool(player.get("is_running"))
	_update_visual_state()


func _process(delta: float) -> void:
	if _uses_production_frames or not _is_moving:
		return
	_step_elapsed += delta
	var step_seconds := RUN_STEP_SECONDS if _is_running else WALK_STEP_SECONDS
	if _step_elapsed < step_seconds:
		return
	_step_elapsed = fmod(_step_elapsed, step_seconds)
	_step_index = (_step_index + 1) % 2
	queue_redraw()


func set_visual_state(facing: StringName, moving: bool, running: bool) -> void:
	_facing = facing
	_is_moving = moving
	_is_running = moving and running
	_update_visual_state()


static func make_animation_name(facing: StringName, moving: bool, running: bool) -> StringName:
	var movement_name := "idle"
	if moving:
		movement_name = "run" if running else "walk"
	return StringName("%s_%s" % [movement_name, facing])


func is_using_production_frames() -> bool:
	return _uses_production_frames


func _update_visual_state() -> void:
	var next_animation := make_animation_name(_facing, _is_moving, _is_running)
	if next_animation == desired_animation and _uses_production_frames == _has_frames(next_animation):
		return
	desired_animation = next_animation
	_uses_production_frames = _play_best_available_animation(desired_animation)
	if not _is_moving:
		_step_elapsed = 0.0
		_step_index = 0
	queue_redraw()
	visual_state_changed.emit(desired_animation)


func _play_best_available_animation(requested: StringName) -> bool:
	for candidate in _get_animation_fallbacks(requested):
		if not _has_frames(candidate):
			continue
		play(candidate)
		return true
	stop()
	return false


func _get_animation_fallbacks(requested: StringName) -> Array[StringName]:
	var parts := String(requested).split("_", false, 1)
	if parts.size() != 2:
		return [requested]
	var movement := parts[0]
	var direction := parts[1]
	var cardinal := _diagonal_fallback(StringName(direction))
	var candidates: Array[StringName] = [requested]
	if cardinal != StringName(direction):
		candidates.append(StringName("%s_%s" % [movement, cardinal]))
	if movement != "idle":
		candidates.append(StringName("idle_%s" % direction))
		if cardinal != StringName(direction):
			candidates.append(StringName("idle_%s" % cardinal))
	return candidates


func _has_frames(animation_name: StringName) -> bool:
	return sprite_frames != null \
		and sprite_frames.has_animation(animation_name) \
		and sprite_frames.get_frame_count(animation_name) > 0


static func _diagonal_fallback(facing: StringName) -> StringName:
	match facing:
		&"down_left", &"up_left":
			return &"left"
		&"down_right", &"up_right":
			return &"right"
		_:
			return facing


func _draw() -> void:
	if _uses_production_frames:
		return
	var step_offset := 0
	if _is_moving:
		step_offset = -1 if _step_index == 0 else 1
	# Development-only placeholder. It is intentionally code-drawn, not production art.
	draw_circle(Vector2(0, -13), 6.0, PLACEHOLDER_SKIN)
	draw_rect(Rect2(-7, -7, 14, 15), PLACEHOLDER_COLOR)
	draw_rect(Rect2(-7, -7, 14, 15), PLACEHOLDER_OUTLINE, false, 1.0)
	draw_line(Vector2(-4, 8), Vector2(-4, 13 + step_offset), PLACEHOLDER_OUTLINE, 3.0)
	draw_line(Vector2(4, 8), Vector2(4, 13 - step_offset), PLACEHOLDER_OUTLINE, 3.0)
	draw_line(Vector2.ZERO, _get_facing_vector(_facing) * 5.0, Color.WHITE, 1.0)


static func _get_facing_vector(facing: StringName) -> Vector2:
	match facing:
		&"down_left":
			return Vector2(-1, 1).normalized()
		&"left":
			return Vector2.LEFT
		&"up_left":
			return Vector2(-1, -1).normalized()
		&"up":
			return Vector2.UP
		&"up_right":
			return Vector2(1, -1).normalized()
		&"right":
			return Vector2.RIGHT
		&"down_right":
			return Vector2(1, 1).normalized()
		_:
			return Vector2.DOWN


func _on_facing_changed(facing: StringName) -> void:
	_facing = facing
	_update_visual_state()


func _on_movement_changed(moving: bool, running: bool) -> void:
	_is_moving = moving
	_is_running = running
	_update_visual_state()
