class_name GrandmaIndoorRoutine
extends Node

signal destination_changed(waypoint_name: StringName)
signal destination_reached(waypoint_name: StringName)

@export var npc_path: NodePath
@export var waypoint_root_path: NodePath
@export_range(1.0, 100.0, 1.0) var walk_speed := 28.0
@export_range(0.0, 30.0, 0.1) var dwell_seconds := 4.0
@export_range(16.0, 80.0, 1.0) var player_personal_space := 36.0

var _npc: NPC
var _navigation_agent: NavigationAgent2D
var _waypoints: Array[Marker2D] = []
var _target_index := -1
var _last_reached_index := 0
var _dwell_remaining := 0.0
var _returning_home := false
var _settled_for_evening := false
var _ready_to_move := false
var _walk_path: Node
var _path_points := PackedVector2Array()
var _path_index := 0


func _ready() -> void:
	_npc = get_node_or_null(npc_path) as NPC
	_navigation_agent = _npc.get_node_or_null("NavigationAgent") as NavigationAgent2D if _npc != null else null
	var waypoint_root := get_node_or_null(waypoint_root_path)
	if waypoint_root != null:
		for child in waypoint_root.get_children():
			if child is Marker2D:
				_waypoints.append(child as Marker2D)
	GameClock.period_changed.connect(_on_period_changed)
	call_deferred("_begin_routine")


func _physics_process(delta: float) -> void:
	if not _ready_to_move or _npc == null or _navigation_agent == null or _waypoints.is_empty():
		_stop_npc()
		return
	if _settled_for_evening:
		_stop_npc()
		return
	if _should_pause_for_player_or_ui():
		_stop_npc()
		return
	if _dwell_remaining > 0.0:
		_dwell_remaining = maxf(_dwell_remaining - delta, 0.0)
		_stop_npc()
		return
	if _target_index < 0:
		_select_next_destination()
		return
	if _walk_path != null and not _path_points.is_empty():
		while _path_index < _path_points.size() and _npc.global_position.distance_to(_path_points[_path_index]) <= 1.0:
			_path_index += 1
		if _path_index >= _path_points.size():
			_arrive_at_destination()
			return
		_npc.move_toward_path_point(_path_points[_path_index], walk_speed, delta)
		return
	if _navigation_agent.is_navigation_finished():
		_arrive_at_destination()
		return
	var next_path_position := _navigation_agent.get_next_path_position()
	var direction := _npc.global_position.direction_to(next_path_position)
	_npc.move_with_velocity(direction * walk_speed)


func go_to_waypoint(index: int) -> bool:
	if _npc == null or _navigation_agent == null or index < 0 or index >= _waypoints.size():
		return false
	_target_index = index
	_settled_for_evening = false
	_dwell_remaining = 0.0
	_navigation_agent.target_position = _waypoints[index].global_position
	_walk_path = get_tree().get_first_node_in_group(&"walk_path_network")
	_path_points.clear()
	_path_index = 0
	if _walk_path != null and _walk_path.has_paths():
		_path_points = _walk_path.find_route(_npc.global_position, _waypoints[index].global_position)
		_path_index = 1 if _path_points.size() > 1 else 0
	destination_changed.emit(StringName(_waypoints[index].name))
	return true


func get_current_waypoint_name() -> StringName:
	if _target_index < 0 or _target_index >= _waypoints.size():
		return &""
	return StringName(_waypoints[_target_index].name)


func is_returning_home() -> bool:
	return _returning_home


func _begin_routine() -> void:
	_ready_to_move = _npc != null and _navigation_agent != null and not _waypoints.is_empty()
	if not _ready_to_move:
		return
	_on_period_changed(GameClock.get_period())


func _select_next_destination() -> void:
	if _returning_home:
		go_to_waypoint(0)
		return
	var next_index := (_last_reached_index + 1) % _waypoints.size()
	go_to_waypoint(next_index)


func _arrive_at_destination() -> void:
	var reached_name := get_current_waypoint_name()
	_last_reached_index = _target_index
	_stop_npc()
	destination_reached.emit(reached_name)
	if _returning_home and _target_index == 0:
		_target_index = -1
		_settled_for_evening = true
		return
	_dwell_remaining = dwell_seconds
	_target_index = -1


func _should_pause_for_player_or_ui() -> bool:
	if GameState.is_paused or GameClock.is_paused:
		return true
	var player := GameState.player as Node2D
	if not is_instance_valid(player):
		return false
	if player.global_position.distance_to(_npc.global_position) <= player_personal_space:
		return true
	var click_action := player.get_node_or_null("ClickActionController") as ClickActionController
	return click_action != null and click_action.is_active \
		and is_instance_valid(click_action.target) and _npc.is_ancestor_of(click_action.target)


func _stop_npc() -> void:
	if _npc != null:
		_npc.stop_movement()


func _on_period_changed(period: StringName) -> void:
	if not _ready_to_move:
		return
	_returning_home = ReturnHomeFlow.is_return_period(period)
	if _returning_home:
		go_to_waypoint(0)
	else:
		_settled_for_evening = false
	if not _returning_home and _target_index < 0:
		_dwell_remaining = dwell_seconds
