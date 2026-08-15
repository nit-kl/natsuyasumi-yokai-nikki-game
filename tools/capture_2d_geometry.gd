extends SceneTree

const VIEWPORT_SIZE := Vector2i(640, 360)


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() not in [2, 4, 5, 6] or arguments.size() >= 5 and arguments[4] != "clean":
		push_error("Usage: --script res://tools/capture_2d_geometry.gd -- <scene> <output.png> [player_x player_y [clean [wait_seconds]]]")
		quit(1)
		return
	if DisplayServer.get_name() == "headless":
		push_error("Geometry capture requires a rendering display driver; do not pass --headless.")
		quit(1)
		return
	var packed_scene := load(arguments[0]) as PackedScene
	if packed_scene == null:
		push_error("Could not load geometry capture scene: %s" % arguments[0])
		quit(1)
		return
	root.size = VIEWPORT_SIZE
	var scene := packed_scene.instantiate() as Node2D
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	if arguments.size() >= 4:
		var game_state := root.get_node_or_null("GameState")
		var player := game_state.get("player") as Node2D if game_state != null else null
		if is_instance_valid(player):
			player.global_position = Vector2(arguments[2].to_float(), arguments[3].to_float())
			await process_frame
	if arguments.size() == 6:
		await create_timer(maxf(arguments[5].to_float(), 0.0)).timeout
	if arguments.size() < 5:
		var overlay := GeometryOverlay.new()
		scene.add_child(overlay)
	await process_frame
	await process_frame
	var output_path := ProjectSettings.globalize_path(arguments[1])
	var error := root.get_texture().get_image().save_png(output_path)
	if error != OK:
		push_error("Could not save geometry capture: %s" % output_path)
		scene.free()
		quit(error)
		return
	scene.free()
	quit()


class GeometryOverlay extends Node2D:
	const COLLISION_FILL := Color(1.0, 0.15, 0.1, 0.28)
	const COLLISION_LINE := Color(1.0, 0.25, 0.15, 0.95)
	const NAVIGATION_LINE := Color(0.2, 1.0, 0.35, 0.95)
	const SPAWN_COLOR := Color(0.1, 0.65, 1.0, 1.0)
	const DOOR_COLOR := Color(1.0, 0.75, 0.1, 1.0)
	const EVENT_COLOR := Color(0.8, 0.3, 1.0, 1.0)


	func _ready() -> void:
		z_index = 100
		queue_redraw()


	func _draw() -> void:
		var scene := get_parent()
		_draw_collisions(scene.get_node_or_null("WorldCollision"))
		_draw_navigation(scene.get_node_or_null("NavigationRegion2D"))
		_draw_markers(scene.get_node_or_null("SpawnPoints"), SPAWN_COLOR)
		_draw_markers(scene.get_node_or_null("Objects"), DOOR_COLOR)
		_draw_markers(scene.get_node_or_null("EventTriggers"), EVENT_COLOR)


	func _draw_collisions(collision_root: Node) -> void:
		if collision_root == null:
			return
		for child in collision_root.get_children():
			var polygon := child as CollisionPolygon2D
			if polygon != null:
				var points := PackedVector2Array()
				for point in polygon.polygon:
					points.append(polygon.transform * point)
				if points.size() >= 3:
					draw_colored_polygon(points, COLLISION_FILL)
					_draw_closed_line(points, COLLISION_LINE, 2.0)
				continue
			var shape_node := child as CollisionShape2D
			if shape_node == null or not shape_node.shape is RectangleShape2D:
				continue
			var rectangle := shape_node.shape as RectangleShape2D
			var rect := Rect2(shape_node.position - rectangle.size * 0.5, rectangle.size)
			draw_rect(rect, COLLISION_FILL, true)
			draw_rect(rect, COLLISION_LINE, false, 2.0)


	func _draw_navigation(region: NavigationRegion2D) -> void:
		if region == null or region.navigation_polygon == null:
			return
		var navigation := region.navigation_polygon
		var vertices := navigation.vertices
		for polygon_index in range(navigation.get_polygon_count()):
			var indices := navigation.get_polygon(polygon_index)
			var points := PackedVector2Array()
			for vertex_index in indices:
				points.append(region.transform * vertices[vertex_index])
			if points.size() >= 3:
				_draw_closed_line(points, NAVIGATION_LINE, 1.0)


	func _draw_markers(container: Node, color: Color) -> void:
		if container == null:
			return
		for child in container.get_children():
			if child is Node2D:
				draw_circle((child as Node2D).position, 5.0, color, false, 2.0)


	func _draw_closed_line(points: PackedVector2Array, color: Color, width: float) -> void:
		var closed_points := points.duplicate()
		closed_points.append(points[0])
		draw_polyline(closed_points, color, width, true)
