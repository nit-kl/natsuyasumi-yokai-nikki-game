extends Node


func _ready() -> void:
	var monitor := HomeOutdoorGeometryMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class HomeOutdoorGeometryMonitor extends Node:
	const OUTDOOR_SCENE := "res://scenes/maps/village/home_outdoor.tscn"
	const HOUSE_SPAWN := Vector2(328.0, 176.0)
	const UPPER_ROAD := Vector2(180.0, 184.0)
	const BRIDGE := Vector2(248.0, 220.0)
	const LOWER_PATH := Vector2(250.0, 300.0)
	const INSECT_PATHS := [Vector2(402.0, 270.0), Vector2(270.0, 260.0), Vector2(420.0, 184.0)]
	const HOUSE_FOUNDATION := Vector2(240.0, 130.0)
	const CANAL := Vector2(160.0, 220.0)
	const RICE_PADDY := Vector2(100.0, 280.0)
	const CORN_FIELD := Vector2(520.0, 280.0)
	const GARDEN_BED := Vector2(330.0, 300.0)
	const GARDEN_HYDRANGEA := Vector2(300.0, 260.0)


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(OUTDOOR_SCENE, &"house_exit")
		if error != OK:
			_fail("Could not open home outdoor for geometry testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var outdoor := get_tree().current_scene
		var player := GameState.player
		var collision_root := outdoor.get_node_or_null("WorldCollision") as StaticBody2D
		var old_collision := outdoor.get_node_or_null("GreyboxCollision")
		var region := outdoor.get_node("NavigationRegion2D") as NavigationRegion2D
		if collision_root == null or old_collision != null:
			_fail("Home outdoor should use Production WorldCollision instead of GreyboxCollision.")
			return
		if region.navigation_polygon == null or region.navigation_polygon.get_polygon_count() <= 8:
			_fail("Home outdoor navigation should be baked around the Production fields and canal.")
			return
		if player.global_position != HOUSE_SPAWN or _point_hits_world(HOUSE_SPAWN):
			_fail("House exit spawn should stand on the front approach path.")
			return
		for blocked_point in [HOUSE_FOUNDATION, CANAL, RICE_PADDY, CORN_FIELD, GARDEN_BED, GARDEN_HYDRANGEA]:
			if not _point_hits_world(blocked_point):
				_fail("Expected Production collision at %s." % blocked_point)
				return
		for walkable_point in [UPPER_ROAD, BRIDGE, LOWER_PATH] + INSECT_PATHS:
			if _point_hits_world(walkable_point):
				_fail("Expected a clear walking surface at %s." % walkable_point)
				return
		var insect := outdoor.get_node("Objects/Aburazemi") as Insect
		if not INSECT_PATHS.has(insect.global_position):
			_fail("Aburazemi should use one of the area habitat spawn points.")
			return
		var navigation_map := player.get_world_2d().navigation_map
		var canal_nearest := NavigationServer2D.map_get_closest_point(navigation_map, CANAL)
		var paddy_nearest := NavigationServer2D.map_get_closest_point(navigation_map, RICE_PADDY)
		var corn_nearest := NavigationServer2D.map_get_closest_point(navigation_map, CORN_FIELD)
		if canal_nearest.distance_to(CANAL) < 20.0 \
			or paddy_nearest.distance_to(RICE_PADDY) < 40.0 \
			or corn_nearest.distance_to(CORN_FIELD) < 40.0:
			_fail("Baked navigation should exclude the canal and crop fields.")
			return
		var insect_path := NavigationServer2D.map_get_path(navigation_map, UPPER_ROAD, insect.global_position, true)
		if insect_path.size() < 2:
			_fail("Every insect habitat point should remain connected to the outdoor path.")
			return
		var path := NavigationServer2D.map_get_path(navigation_map, UPPER_ROAD, LOWER_PATH, true)
		if path.size() < 3:
			_fail("Upper road should remain connected to the insect path through the bridge.")
			return
		var crosses_bridge := false
		for point in path:
			if point.x >= 240.0 and point.x <= 257.0 and point.y >= 190.0 and point.y <= 254.0:
				crosses_bridge = true
				break
		if not crosses_bridge:
			_fail("The outdoor navigation path should cross the visible center bridge.")
			return
		var river_door := outdoor.get_node("Objects/GoToRiver") as MapDoorway
		var river_nearest := NavigationServer2D.map_get_closest_point(navigation_map, river_door.global_position)
		if river_nearest.distance_to(river_door.global_position) > 8.0:
			_fail("The road to the river should remain reachable at the right edge.")
			return
		_quit_cleanly(0)


	func _point_hits_world(point: Vector2) -> bool:
		var query := PhysicsPointQueryParameters2D.new()
		query.position = point
		query.collision_mask = 2
		query.collide_with_areas = false
		query.collide_with_bodies = true
		return not GameState.player.get_world_2d().direct_space_state.intersect_point(query, 8).is_empty()


	func _reset_state() -> void:
		CalendarManager.debug_set_day(1)
		GameClock.debug_set_time(7, 0)
		GameClock.set_clock_paused(false)
		GameState.set_paused(false)
		WorldState.reset_state()
		YokaiManager.reset_state()
		EventManager.reset_runtime()
		DiaryManager.reset_state()


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
