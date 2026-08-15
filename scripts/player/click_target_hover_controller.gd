class_name ClickTargetHoverController
extends Node2D

signal hover_changed(target: Node)

const HOVER_COLOR := Color(1.0, 0.84, 0.42, 0.9)
const HOVER_SHADOW_COLOR := Color(0.18, 0.14, 0.08, 0.7)
const CORNER_LENGTH := 4.0

var hovered_target: Node2D

var _actor: CharacterBody2D
var _click_action: ClickActionController
var _visual_center := Vector2.ZERO
var _visual_half_size := Vector2(10.0, 8.0)
var _cursor_claimed := false


func _ready() -> void:
	top_level = true
	_actor = get_parent() as CharacterBody2D
	_click_action = get_node_or_null("../ClickActionController") as ClickActionController
	visible = false


func _exit_tree() -> void:
	_set_cursor_claimed(false)


func _physics_process(_delta: float) -> void:
	if _is_pointer_over_ui():
		clear_hover()
		return
	update_hover_at(_actor.get_global_mouse_position() if is_instance_valid(_actor) else Vector2.ZERO)


func update_hover_at(world_position: Vector2) -> Node:
	if not _can_show_hover():
		clear_hover()
		return null
	var next_target := _click_action.pick_target_at(world_position) as Node2D
	_set_hovered_target(next_target)
	return hovered_target


func clear_hover() -> void:
	_set_hovered_target(null)


func _set_hovered_target(value: Node2D) -> void:
	if hovered_target == value and is_instance_valid(value):
		global_position = value.global_position
		return
	if hovered_target == null and value == null and not visible and not _cursor_claimed:
		return
	hovered_target = value
	visible = is_instance_valid(hovered_target)
	_set_cursor_claimed(visible)
	if visible:
		global_position = hovered_target.global_position
		_update_visual_bounds()
		queue_redraw()
	hover_changed.emit(hovered_target)


func _update_visual_bounds() -> void:
	_visual_center = Vector2.ZERO
	_visual_half_size = Vector2(10.0, 8.0)
	if hovered_target is NPCInteractionArea:
		_visual_center = Vector2(0.0, -14.0)
		_visual_half_size = Vector2(11.0, 18.0)
	elif hovered_target is Insect:
		_visual_half_size = Vector2(7.0, 7.0)
	elif hovered_target is MapDoorway:
		_visual_half_size = Vector2(18.0, 7.0)


func _draw() -> void:
	if not is_instance_valid(hovered_target):
		return
	_draw_corners(_visual_center + Vector2(0.0, 1.0), HOVER_SHADOW_COLOR, 2.0)
	_draw_corners(_visual_center, HOVER_COLOR, 1.0)


func _draw_corners(center: Vector2, color: Color, width: float) -> void:
	var left := center.x - _visual_half_size.x
	var right := center.x + _visual_half_size.x
	var top := center.y - _visual_half_size.y
	var bottom := center.y + _visual_half_size.y
	draw_line(Vector2(left, top), Vector2(left + CORNER_LENGTH, top), color, width)
	draw_line(Vector2(left, top), Vector2(left, top + CORNER_LENGTH), color, width)
	draw_line(Vector2(right, top), Vector2(right - CORNER_LENGTH, top), color, width)
	draw_line(Vector2(right, top), Vector2(right, top + CORNER_LENGTH), color, width)
	draw_line(Vector2(left, bottom), Vector2(left + CORNER_LENGTH, bottom), color, width)
	draw_line(Vector2(left, bottom), Vector2(left, bottom - CORNER_LENGTH), color, width)
	draw_line(Vector2(right, bottom), Vector2(right - CORNER_LENGTH, bottom), color, width)
	draw_line(Vector2(right, bottom), Vector2(right, bottom - CORNER_LENGTH), color, width)


func _can_show_hover() -> bool:
	return is_instance_valid(_actor) \
		and _click_action != null \
		and not bool(_actor.get("movement_locked")) \
		and not GameState.is_paused


func _is_pointer_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


func _set_cursor_claimed(value: bool) -> void:
	if _cursor_claimed == value:
		return
	_cursor_claimed = value
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if value else Input.CURSOR_ARROW)
