class_name NPC
extends CharacterBody2D

signal facing_changed(facing: StringName)
signal movement_changed(is_moving: bool)
signal interacted(npc_id: StringName)

const PLACEHOLDER_SKIN := Color("e4ad73")
const PLACEHOLDER_OUTLINE := Color("372d37")

@export var data: NPCData
@export var placeholder_clothing_color := Color("76546f")
@export var sprite_frames: SpriteFrames

var facing: StringName = &"down"
var is_moving := false


func _ready() -> void:
	refresh_depth_order()
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite != null and sprite_frames != null:
		sprite.sprite_frames = sprite_frames
		sprite.visible = true
	if data != null:
		facing = data.default_facing
		_update_sprite_facing()
		var dialogue_area := get_node_or_null("InteractionArea") as DialogueInteractable
		if dialogue_area != null:
			dialogue_area.dialogue = data.default_dialogue
			dialogue_area.interacted.connect(_on_interacted)
	queue_redraw()


func get_npc_id() -> StringName:
	return data.npc_id if data != null else &""


func get_display_name() -> String:
	return data.display_name if data != null else ""


func set_facing(value: StringName) -> void:
	if value == facing:
		return
	facing = value
	_update_sprite_facing()
	facing_changed.emit(facing)


func face_toward(world_position: Vector2) -> void:
	var direction := global_position.direction_to(world_position)
	set_facing(_direction_to_cardinal_facing(direction, facing))


func move_with_velocity(desired_velocity: Vector2) -> void:
	velocity = desired_velocity
	var next_is_moving := not velocity.is_zero_approx()
	if next_is_moving:
		face_toward(global_position + velocity)
	_set_is_moving(next_is_moving)
	move_and_slide()
	refresh_depth_order()


func stop_movement() -> void:
	velocity = Vector2.ZERO
	_set_is_moving(false)
	refresh_depth_order()


func refresh_depth_order() -> void:
	z_index = roundi(_get_foot_y())


func _get_foot_y() -> float:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return global_position.y
	return collision.to_global(Vector2(0.0, collision.shape.get_rect().end.y)).y


static func _direction_to_cardinal_facing(direction: Vector2, fallback: StringName = &"down") -> StringName:
	if direction.is_zero_approx():
		return fallback
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	return &"down" if direction.y > 0.0 else &"up"


func _draw() -> void:
	if sprite_frames != null:
		return
	# Production sprite未制作時だけ使用するNPC Placeholder。
	draw_circle(Vector2(0, -14), 7.0, PLACEHOLDER_SKIN)
	draw_circle(Vector2(0, -18), 7.0, Color("74706d"))
	draw_rect(Rect2(-8, -9, 16, 18), placeholder_clothing_color)
	draw_rect(Rect2(-8, -9, 16, 18), PLACEHOLDER_OUTLINE, false, 1.0)
	draw_line(Vector2(-4, 9), Vector2(-4, 13), PLACEHOLDER_OUTLINE, 3.0)
	draw_line(Vector2(4, 9), Vector2(4, 13), PLACEHOLDER_OUTLINE, 3.0)


func _update_sprite_facing() -> void:
	var sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null or sprite_frames == null:
		return
	var movement_name := "walk" if is_moving else "idle"
	var animation_name := StringName("%s_%s" % [movement_name, facing])
	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)


func _set_is_moving(value: bool) -> void:
	if value == is_moving:
		return
	is_moving = value
	_update_sprite_facing()
	movement_changed.emit(is_moving)


func _on_interacted(_actor: Node) -> void:
	interacted.emit(get_npc_id())
