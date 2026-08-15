extends Node


func _ready() -> void:
	var monitor := RiverGeometryMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class RiverGeometryMonitor extends Node:
	const RIVER_SCENE := "res://scenes/maps/river/river.tscn"
	const HOME_SPAWN := Vector2(96.0, 264.0)
	const TRACE_PATH := Vector2(264.0, 248.0)
	const SIGHTING_PATH := Vector2(424.0, 248.0)
	const DEBUG_BANK := Vector2(400.0, 240.0)
	const WATER_CENTER := Vector2(416.0, 128.0)
	const SHORE_WATER := Vector2(320.0, 220.0)
	const LEFT_SHRUB := Vector2(30.0, 270.0)
	const RIGHT_ROCKS := Vector2(580.0, 280.0)
	const BOTTOM_FENCE := Vector2(320.0, 330.0)
	const FENCE_EDGE := Vector2(320.0, 302.0)
	const MAX_MOVE_FRAMES := 480


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(RIVER_SCENE, &"home_path")
		if error != OK:
			_fail("Could not open river for geometry testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var river := get_tree().current_scene
		var player := GameState.player
		var collision_root := river.get_node_or_null("WorldCollision") as StaticBody2D
		var old_collision := river.get_node_or_null("GreyboxCollision")
		var region := river.get_node("NavigationRegion2D") as NavigationRegion2D
		if collision_root == null or old_collision != null:
			_fail("River should use Production WorldCollision instead of GreyboxCollision.")
			return
		if region.navigation_polygon == null or region.navigation_polygon.get_polygon_count() <= 8:
			_fail("River navigation should be baked around the Production shoreline and vegetation.")
			return
		if player.global_position != HOME_SPAWN or _point_hits_world(HOME_SPAWN):
			_fail("River spawn should stand on the clear left dirt path.")
			return
		for blocked_point in [WATER_CENTER, SHORE_WATER, LEFT_SHRUB, RIGHT_ROCKS, BOTTOM_FENCE, FENCE_EDGE]:
			if not _point_hits_world(blocked_point):
				_fail("Expected Production river collision at %s." % blocked_point)
				return
		for walkable_point in [TRACE_PATH, SIGHTING_PATH, DEBUG_BANK]:
			if _point_hits_world(walkable_point):
				_fail("Expected a clear riverbank path at %s." % walkable_point)
				return
		var navigation_map := player.get_world_2d().navigation_map
		var water_nearest := NavigationServer2D.map_get_closest_point(navigation_map, WATER_CENTER)
		if water_nearest.distance_to(WATER_CENTER) < 80.0:
			_fail("Baked navigation should keep click destinations out of the river water.")
			return
		for event_point in [TRACE_PATH, SIGHTING_PATH, DEBUG_BANK]:
			var nearest := NavigationServer2D.map_get_closest_point(navigation_map, event_point)
			if nearest.distance_to(event_point) > 3.0:
				_fail("Kappa event path should remain navigable at %s." % event_point)
				return
		var path := NavigationServer2D.map_get_path(navigation_map, HOME_SPAWN, SIGHTING_PATH, true)
		if path.size() < 2:
			_fail("The left entrance should remain connected to both kappa discovery areas.")
			return
		var click_move := player.get_node("ClickMoveController") as ClickMoveController
		if not click_move.set_destination(SIGHTING_PATH):
			_fail("Kappa sighting path should accept a click destination.")
			return
		for _frame in range(MAX_MOVE_FRAMES):
			if not click_move.is_active:
				break
			await get_tree().physics_frame
		if click_move.is_active or player.global_position.distance_to(SIGHTING_PATH) > 10.0:
			_fail("Player should follow the dirt bank without entering water or bottom vegetation.")
			return
		var return_door := river.get_node("Objects/ReturnHome") as MapDoorway
		var return_nearest := NavigationServer2D.map_get_closest_point(navigation_map, return_door.global_position)
		if return_nearest.distance_to(return_door.global_position) > 8.0:
			_fail("The return-home doorway should remain reachable on the left path.")
			return
		await get_tree().create_timer(1.8).timeout
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
		GameClock.debug_set_time(12, 0)
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
			await get_tree().create_timer(0.2).timeout
		if scene != null:
			scene.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
