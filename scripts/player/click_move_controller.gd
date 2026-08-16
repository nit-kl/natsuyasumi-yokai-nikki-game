class_name ClickMoveController
extends Node

signal destination_changed(destination: Vector2)
signal movement_cancelled()

@export_range(1.0, 24.0, 1.0) var arrival_distance := 6.0

@onready var navigation_agent: NavigationAgent2D = %NavigationAgent
@onready var destination_marker: ClickDestinationMarker = %ClickDestinationMarker
@onready var click_action_controller := get_node_or_null("../ClickActionController") as ClickActionController

var destination := Vector2.ZERO
var is_active := false
var _actor: CharacterBody2D
var _path_points := PackedVector2Array()
var _path_index := 0


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	navigation_agent.path_desired_distance = 8.0
	navigation_agent.target_desired_distance = arrival_distance
	navigation_agent.avoidance_enabled = false


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		var had_queued_action := click_action_controller != null and click_action_controller.is_active
		if had_queued_action:
			click_action_controller.cancel_action()
		var had_movement := is_active
		if had_movement:
			cancel_movement()
		if had_movement or had_queued_action:
			get_viewport().set_input_as_handled()
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not _can_accept_destination():
		return
	var click_position := _actor.get_global_mouse_position()
	if click_action_controller != null and click_action_controller.queue_action_at(click_position):
		get_viewport().set_input_as_handled()
		return
	if click_action_controller != null:
		click_action_controller.cancel_action()
	set_destination(click_position)
	get_viewport().set_input_as_handled()


func set_destination(requested_destination: Vector2) -> bool:
	if not _can_accept_destination():
		return false
	var walk_path := _get_walk_path_network()
	if walk_path != null and walk_path.has_paths():
		_path_points = walk_path.find_route(_actor.global_position, requested_destination)
		if _path_points.is_empty():
			return false
		_path_index = 1 if _path_points.size() > 1 else 0
		destination = _path_points[-1].round()
		is_active = true
		destination_marker.show_destination(destination)
		destination_changed.emit(destination)
		return true
	var resolved_destination := requested_destination
	var navigation_map := navigation_agent.get_navigation_map()
	if navigation_map.is_valid() and NavigationServer2D.map_get_iteration_id(navigation_map) > 0:
		resolved_destination = NavigationServer2D.map_get_closest_point(navigation_map, requested_destination)
	destination = resolved_destination.round()
	navigation_agent.target_position = destination
	is_active = true
	destination_marker.show_destination(destination)
	destination_changed.emit(destination)
	return true


func get_movement_direction() -> Vector2:
	if not is_active or not is_instance_valid(_actor):
		return Vector2.ZERO
	if _actor.global_position.distance_to(destination) <= arrival_distance:
		cancel_movement()
		return Vector2.ZERO
	if not _path_points.is_empty():
		while _path_index < _path_points.size() - 1 \
			and _actor.global_position.distance_to(_path_points[_path_index]) <= 0.5:
			_path_index += 1
		if _path_index >= _path_points.size():
			cancel_movement()
			return Vector2.ZERO
		return _actor.global_position.direction_to(_path_points[_path_index])
	var navigation_map := navigation_agent.get_navigation_map()
	if not navigation_map.is_valid() or NavigationServer2D.map_get_iteration_id(navigation_map) == 0:
		return Vector2.ZERO
	var next_position := navigation_agent.get_next_path_position()
	if navigation_agent.is_navigation_finished():
		cancel_movement()
		return Vector2.ZERO
	return _actor.global_position.direction_to(next_position)


func cancel_movement() -> void:
	if not is_active:
		return
	is_active = false
	_path_points.clear()
	_path_index = 0
	navigation_agent.target_position = _actor.global_position if is_instance_valid(_actor) else destination
	destination_marker.hide_destination()
	movement_cancelled.emit()


func _can_accept_destination() -> bool:
	return is_instance_valid(_actor) \
		and not bool(_actor.get("movement_locked")) \
		and not GameState.is_paused


func _get_walk_path_network() -> Node:
	return get_tree().get_first_node_in_group(&"walk_path_network")
