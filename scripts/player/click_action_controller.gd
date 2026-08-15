class_name ClickActionController
extends Node

signal action_queued(target: Node)
signal action_cancelled()
signal action_completed(target: Node)

enum ActionType {
	NONE,
	INTERACT,
	CATCH_INSECT,
}

const INTERACTION_COLLISION_MASK := 4 | 8
const INSECT_COLLISION_MASK := 32

@export_range(1.0, 24.0, 1.0) var click_pick_radius := 8.0
@export_range(8.0, 48.0, 1.0) var interaction_distance := 28.0
@export_range(8.0, 48.0, 1.0) var insect_catch_distance := 30.0
@export_range(1.0, 24.0, 1.0) var moving_target_repath_distance := 8.0

var target: Node2D
var action_type := ActionType.NONE
var is_active := false

var _actor: CharacterBody2D
var _click_move: ClickMoveController
var _interaction_detector: InteractionDetector
var _bug_catcher: BugCatcher


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	_click_move = get_node_or_null("../ClickMoveController") as ClickMoveController
	_interaction_detector = get_node_or_null("../InteractionDetector") as InteractionDetector
	_bug_catcher = get_node_or_null("../BugCatcher") as BugCatcher


func _physics_process(_delta: float) -> void:
	if not is_active:
		return
	if not _can_queue_action() or not is_instance_valid(target):
		cancel_action(true)
		return
	var target_position := target.global_position
	var required_distance := insect_catch_distance if action_type == ActionType.CATCH_INSECT else interaction_distance
	if _actor.global_position.distance_to(target_position) > required_distance:
		if not _click_move.is_active or _click_move.destination.distance_to(target_position) > moving_target_repath_distance:
			_click_move.set_destination(target_position)
		return
	_click_move.cancel_movement()
	_face_target(target_position)
	match action_type:
		ActionType.INTERACT:
			if _interaction_detector != null and _interaction_detector.try_interact_target(target, interaction_distance):
				if is_active:
					_complete_action()
		ActionType.CATCH_INSECT:
			if _bug_catcher != null and _bug_catcher.attempt_catch_target(target as Insect):
				if is_active:
					_complete_action()


func queue_action_at(global_position: Vector2) -> bool:
	return queue_action(pick_target_at(global_position))


func queue_action(clicked_target: Node) -> bool:
	if not _can_queue_action():
		return false
	var next_type := _get_action_type(clicked_target)
	if next_type == ActionType.NONE or not clicked_target is Node2D:
		return false
	target = clicked_target as Node2D
	action_type = next_type
	is_active = true
	if not _click_move.set_destination(target.global_position):
		_clear_action()
		return false
	action_queued.emit(target)
	return true


func pick_target_at(global_position: Vector2) -> Node:
	if not is_instance_valid(_actor) or not _actor.is_inside_tree():
		return null
	var circle := CircleShape2D.new()
	circle.radius = click_pick_radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = INTERACTION_COLLISION_MASK | INSECT_COLLISION_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [_actor.get_rid()]
	var results := _actor.get_world_2d().direct_space_state.intersect_shape(query, 16)
	var best_target: Node2D
	var best_distance := INF
	var best_priority := -2147483648
	for result in results:
		var candidate := _resolve_click_target(result.get("collider") as Node)
		if not candidate is Node2D or _get_action_type(candidate) == ActionType.NONE:
			continue
		var candidate_2d := candidate as Node2D
		var distance := global_position.distance_squared_to(candidate_2d.global_position)
		var priority_value: Variant = candidate.get("interaction_priority")
		var priority := int(priority_value) if priority_value != null else 0
		if distance < best_distance or (is_equal_approx(distance, best_distance) and priority > best_priority):
			best_target = candidate_2d
			best_distance = distance
			best_priority = priority
	return best_target


func cancel_action(cancel_movement: bool = false) -> void:
	if not is_active:
		return
	if cancel_movement and _click_move != null:
		_click_move.cancel_movement()
	_clear_action()
	action_cancelled.emit()


func _complete_action() -> void:
	var completed_target := target
	_clear_action()
	action_completed.emit(completed_target)


func _clear_action() -> void:
	target = null
	action_type = ActionType.NONE
	is_active = false


func _get_action_type(candidate: Node) -> ActionType:
	if candidate is Insect:
		return ActionType.CATCH_INSECT if candidate.state != Insect.State.CAUGHT else ActionType.NONE
	if _interaction_detector != null and InteractionDetector.is_valid_interactable(candidate, _actor):
		return ActionType.INTERACT
	return ActionType.NONE


func _resolve_click_target(collider: Node) -> Node:
	if collider is Insect or collider is Interactable:
		return collider
	if collider != null:
		var interaction_area := collider.get_node_or_null("InteractionArea")
		if interaction_area is Interactable:
			return interaction_area
	return null


func _face_target(target_position: Vector2) -> void:
	var direction := _actor.global_position.direction_to(target_position)
	if direction.is_zero_approx():
		return
	_actor.set_facing(_actor.direction_to_facing(direction, _actor.facing))


func _can_queue_action() -> bool:
	return is_instance_valid(_actor) \
		and _click_move != null \
		and not bool(_actor.get("movement_locked")) \
		and not GameState.is_paused
