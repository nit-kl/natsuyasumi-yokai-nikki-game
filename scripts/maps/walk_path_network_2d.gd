class_name WalkPathNetwork2D
extends Node2D

## A positive definition of where characters may walk. Each Line2D child is an
## authored path; lines connect when they share an endpoint.

const MERGE_DISTANCE_SQUARED := 0.25
const INPUT_ALIGNMENT_MIN := 0.15
const MARKER_COLOR := Color(1.0, 0.86, 0.38, 0.9)
const MARKER_SHADOW := Color(0.14, 0.1, 0.04, 0.78)

@export_range(20.0, 64.0, 1.0) var marker_spacing := 30.0
@export var show_walk_markers := true

var _points: Array[Vector2] = []
var _edges: Array[Vector2i] = []
var _marker_positions := PackedVector2Array()


func _ready() -> void:
	add_to_group(&"walk_path_network")
	z_index = 5
	_rebuild_graph()
	queue_redraw()


func has_paths() -> bool:
	return not _edges.is_empty()


func get_walk_marker_positions() -> PackedVector2Array:
	return _marker_positions.duplicate()


func get_closest_point(world_position: Vector2) -> Vector2:
	var projection := _get_projection(world_position)
	var closest: Vector2 = projection.get("point", world_position)
	return closest


func find_route(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	if _edges.is_empty():
		return PackedVector2Array()
	var start := _get_projection(from_world)
	var finish := _get_projection(to_world)
	if start.is_empty() or finish.is_empty():
		return PackedVector2Array()

	var graph_points: Array[Vector2] = _points.duplicate()
	var graph_edges: Array[Vector2i] = _edges.duplicate()
	var start_index := graph_points.size()
	graph_points.append(start["point"])
	_connect_projection(graph_edges, start_index, start)
	var finish_index := graph_points.size()
	graph_points.append(finish["point"])
	_connect_projection(graph_edges, finish_index, finish)
	if int(start["edge_index"]) == int(finish["edge_index"]):
		graph_edges.append(Vector2i(start_index, finish_index))

	var previous := _shortest_path_previous(graph_points, graph_edges, start_index)
	if finish_index >= previous.size() or previous[finish_index] == -1:
		return PackedVector2Array()
	var indices: Array[int] = []
	var cursor := finish_index
	while cursor != -1:
		indices.push_front(cursor)
		if cursor == start_index:
			break
		cursor = previous[cursor]
	if indices.is_empty() or indices[0] != start_index:
		return PackedVector2Array()
	var result := PackedVector2Array()
	for index in indices:
		var point := graph_points[index]
		if result.is_empty() or result[-1].distance_squared_to(point) > MERGE_DISTANCE_SQUARED:
			result.append(point)
	return result


func constrain_step(world_position: Vector2, input_direction: Vector2, distance: float) -> Vector2:
	if input_direction.is_zero_approx() or distance <= 0.0 or _edges.is_empty():
		return get_closest_point(world_position)
	var projection := _get_projection(world_position)
	if projection.is_empty():
		return world_position
	var input := input_direction.normalized()
	var current: Vector2 = projection["point"]
	var edge := _edges[int(projection["edge_index"])]
	var next_node := _choose_endpoint(current, edge, input)
	if next_node < 0:
		return current
	var remaining := distance
	var target := _points[next_node]
	if current.distance_to(target) <= remaining:
		# Stop exactly on a junction for one frame. The next input sample chooses
		# the outgoing branch, avoiding overshoot into a neighboring route.
		return target
	return current.move_toward(target, remaining)


func _choose_endpoint(position: Vector2, edge: Vector2i, input: Vector2) -> int:
	var best_node := -1
	var best_alignment := INPUT_ALIGNMENT_MIN
	for node_index in [edge.x, edge.y]:
		var node_position := _points[node_index]
		if position.distance_squared_to(node_position) <= MERGE_DISTANCE_SQUARED:
			var connected := _choose_connected_node(node_index, -1, input)
			if connected >= 0:
				return connected
			continue
		var direction := position.direction_to(node_position)
		var alignment := input.dot(direction)
		if alignment > best_alignment:
			best_alignment = alignment
			best_node = node_index
	return best_node


func _choose_connected_node(node_index: int, previous_node: int, input: Vector2) -> int:
	var best_node := -1
	var best_alignment := INPUT_ALIGNMENT_MIN
	for edge in _edges:
		var candidate := -1
		if edge.x == node_index:
			candidate = edge.y
		elif edge.y == node_index:
			candidate = edge.x
		if candidate < 0 or candidate == previous_node:
			continue
		var alignment := input.dot(_points[node_index].direction_to(_points[candidate]))
		if alignment > best_alignment:
			best_alignment = alignment
			best_node = candidate
	return best_node


func _rebuild_graph() -> void:
	_points.clear()
	_edges.clear()
	for child in get_children():
		if not child is Line2D:
			continue
		var line := child as Line2D
		var previous_index := -1
		for local_point in line.points:
			var point_index := _find_or_add_point(line.to_global(local_point))
			if previous_index >= 0 and previous_index != point_index:
				_edges.append(Vector2i(previous_index, point_index))
			previous_index = point_index
	_rebuild_marker_positions()
	queue_redraw()


func _rebuild_marker_positions() -> void:
	_marker_positions.clear()
	for edge in _edges:
		var from_point := _points[edge.x]
		var to_point := _points[edge.y]
		var length := from_point.distance_to(to_point)
		if length <= 0.001:
			continue
		var sample_distance := minf(marker_spacing * 0.5, length * 0.5)
		while sample_distance < length:
			_marker_positions.append(from_point.lerp(to_point, sample_distance / length))
			sample_distance += marker_spacing


func _draw() -> void:
	if not show_walk_markers:
		return
	for world_position in _marker_positions:
		var point := to_local(world_position).round()
		var shadow := PackedVector2Array([
			point + Vector2(0, -2), point + Vector2(3, 1),
			point + Vector2(0, 4), point + Vector2(-3, 1),
		])
		draw_colored_polygon(shadow, MARKER_SHADOW)
		var marker := PackedVector2Array([
			point + Vector2(0, -2), point + Vector2(2, 0),
			point + Vector2(0, 2), point + Vector2(-2, 0),
		])
		draw_colored_polygon(marker, MARKER_COLOR)


func _find_or_add_point(point: Vector2) -> int:
	for index in _points.size():
		if _points[index].distance_squared_to(point) <= MERGE_DISTANCE_SQUARED:
			return index
	_points.append(point)
	return _points.size() - 1


func _get_projection(world_position: Vector2) -> Dictionary:
	var best_distance := INF
	var best: Dictionary = {}
	for edge_index in _edges.size():
		var edge := _edges[edge_index]
		var from_point := _points[edge.x]
		var to_point := _points[edge.y]
		var projected := Geometry2D.get_closest_point_to_segment(world_position, from_point, to_point)
		var distance := world_position.distance_squared_to(projected)
		if distance < best_distance:
			best_distance = distance
			best = {"point": projected, "edge_index": edge_index, "from": edge.x, "to": edge.y}
	return best


func _connect_projection(edges: Array[Vector2i], projection_index: int, projection: Dictionary) -> void:
	edges.append(Vector2i(projection_index, int(projection["from"])))
	edges.append(Vector2i(projection_index, int(projection["to"])))


func _shortest_path_previous(points: Array[Vector2], edges: Array[Vector2i], start_index: int) -> Array[int]:
	var distances: Array[float] = []
	var previous: Array[int] = []
	var visited: Array[bool] = []
	for _index in points.size():
		distances.append(INF)
		previous.append(-1)
		visited.append(false)
	distances[start_index] = 0.0
	for _iteration in points.size():
		var current := -1
		var current_distance := INF
		for index in points.size():
			if not visited[index] and distances[index] < current_distance:
				current = index
				current_distance = distances[index]
		if current < 0:
			break
		visited[current] = true
		for edge in edges:
			var neighbor := -1
			if edge.x == current:
				neighbor = edge.y
			elif edge.y == current:
				neighbor = edge.x
			if neighbor < 0 or visited[neighbor]:
				continue
			var candidate := distances[current] + points[current].distance_to(points[neighbor])
			if candidate < distances[neighbor]:
				distances[neighbor] = candidate
				previous[neighbor] = current
	return previous
