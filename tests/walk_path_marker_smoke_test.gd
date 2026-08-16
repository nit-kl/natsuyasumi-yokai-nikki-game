extends Node

const LocationCatalogData = preload("res://scripts/maps/location_catalog.gd")


func _ready() -> void:
	var monitor := WalkPathMarkerMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class WalkPathMarkerMonitor extends Node:
	func run() -> void:
		GameState.set_paused(false)
		GameClock.set_clock_paused(false)
		var scene_paths: Array[String] = []
		for area_id: StringName in LocationCatalogData.SCENE_PATHS:
			if area_id == &"foundation_test":
				continue
			scene_paths.append(LocationCatalogData.get_scene_path(area_id))
		scene_paths.sort()
		for scene_path in scene_paths:
			if await SceneTransitionManager.change_scene(scene_path) != OK:
				_fail("Could not open map for walk-marker validation: %s" % scene_path)
				return
			await get_tree().physics_frame
			await get_tree().physics_frame
			var network := get_tree().current_scene.get_node_or_null("WalkPathNetwork")
			if network == null or not network.show_walk_markers or not network.visible:
				_fail("Walk markers should be persistently visible: %s" % scene_path)
				return
			var markers: PackedVector2Array = network.get_walk_marker_positions()
			if markers.size() < 3:
				_fail("A map should expose enough markers to read its walkable route: %s" % scene_path)
				return
			for marker in markers:
				if marker.distance_to(network.get_closest_point(marker)) > 0.1:
					_fail("A marker must remain on its authored stroll path: %s at %s" % [scene_path, marker])
					return
				if _overlaps_world_collision(marker, 2.0):
					_fail("A walk marker contradicts the background collision footprint: %s at %s" % [scene_path, marker])
					return
				if _overlaps_world_collision(marker, 7.0):
					_fail("The Player footprint should fit around every walk marker: %s at %s" % [scene_path, marker])
					return
		_quit_cleanly(0)


	func _overlaps_world_collision(position: Vector2, radius: float) -> bool:
		var shape := CircleShape2D.new()
		shape.radius = radius
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0.0, position)
		query.collision_mask = 2
		query.collide_with_bodies = true
		query.collide_with_areas = false
		return not get_tree().current_scene.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


	func _fail(message: String) -> void:
		push_error(message)
		_quit_cleanly(1)


	func _quit_cleanly(exit_code: int) -> void:
		var scene := get_tree().current_scene
		var audio := scene.get_node_or_null("LocationRuntime/EnvironmentAudio") as EnvironmentAudioController if scene != null else null
		if audio != null:
			audio.shutdown()
			audio.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
