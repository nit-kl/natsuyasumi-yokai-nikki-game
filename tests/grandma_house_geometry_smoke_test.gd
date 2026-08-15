extends Node


func _ready() -> void:
	var monitor := GrandmaHouseGeometryMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class GrandmaHouseGeometryMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const LIVING_BACKGROUND := "res://assets/maps/grandma_house_living/map_grandma_house_living.png"
	const BEDROOM_SPAWN := Vector2(142.0, 174.0)
	const GRANDMA_POSITION := Vector2(208.0, 164.0)
	const ENTRANCE_TARGET := Vector2(320.0, 290.0)
	const KITCHEN_ENTRANCE := Vector2(458.0, 212.0)
	const LEFT_DRESSER := Vector2(35.0, 110.0)
	const REMOVED_BED_FOOTPRINT := Vector2(75.0, 168.0)
	const TABLE_CENTER := Vector2(288.0, 173.0)
	const DINING_CHAIR := Vector2(533.0, 246.0)
	const MAX_MOVE_FRAMES := 480


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom")
		if error != OK:
			_fail("Could not open grandma house for geometry testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var house := get_tree().current_scene
		var player := GameState.player
		var collision_root := house.get_node_or_null("WorldCollision") as StaticBody2D
		var old_collision := house.get_node_or_null("GreyboxWalls")
		var region := house.get_node("NavigationRegion2D") as NavigationRegion2D
		var background := house.get_node("ProductionBackground") as Sprite2D
		if collision_root == null or old_collision != null:
			_fail("Grandma house should use Production WorldCollision instead of GreyboxWalls.")
			return
		if background.texture == null or background.texture.resource_path != LIVING_BACKGROUND:
			_fail("Grandma house should use the bedroom-free living-room Production background.")
			return
		if region.navigation_polygon == null or region.navigation_polygon.get_polygon_count() <= 4:
			_fail("Grandma house navigation should be baked around Production furniture obstacles.")
			return
		if player.global_position != BEDROOM_SPAWN or _point_hits_world(player.global_position):
			_fail("Bedroom spawn should be on the tatami beside the bed.")
			return
		var grandma := house.get_node("NPCs/Grandma") as NPC
		if grandma.global_position != GRANDMA_POSITION or _point_hits_world(grandma.global_position):
			_fail("Grandma should stand in the clear aisle left of the center table.")
			return
		if not _point_hits_world(LEFT_DRESSER) or not _point_hits_world(TABLE_CENTER) \
			or not _point_hits_world(DINING_CHAIR):
			_fail("Visible furniture footprints should have Production collision.")
			return
		if _point_hits_world(REMOVED_BED_FOOTPRINT):
			_fail("The former bedroom footprint should be walkable in the living-room layout.")
			return
		var navigation_map := player.get_world_2d().navigation_map
		var table_nearest := NavigationServer2D.map_get_closest_point(navigation_map, TABLE_CENTER)
		if table_nearest.distance_to(TABLE_CENTER) < 20.0:
			_fail("Baked navigation should keep the Player center away from furniture.")
			return
		var path := NavigationServer2D.map_get_path(navigation_map, BEDROOM_SPAWN, ENTRANCE_TARGET, true)
		if path.size() < 3:
			_fail("Bedroom should remain connected to the entrance around the furniture.")
			return
		var kitchen_path := NavigationServer2D.map_get_path(navigation_map, GRANDMA_POSITION, KITCHEN_ENTRANCE, true)
		if kitchen_path.size() < 2 or kitchen_path[kitchen_path.size() - 1].distance_to(KITCHEN_ENTRANCE) > 3.0:
			_fail("The living room should connect to the visible kitchen entrance below the plant (path=%s nearest=%s)." % [kitchen_path, NavigationServer2D.map_get_closest_point(navigation_map, KITCHEN_ENTRANCE)])
			return
		if _point_hits_world(Vector2(425.0, 205.0)):
			_fail("The visible passage in front of the center plant should remain walkable.")
			return
		var click_move := player.get_node("ClickMoveController") as ClickMoveController
		if not click_move.set_destination(ENTRANCE_TARGET):
			_fail("Entrance aisle should accept a click destination.")
			return
		for _frame in range(MAX_MOVE_FRAMES):
			if not click_move.is_active:
				break
			await get_tree().physics_frame
		if click_move.is_active or player.global_position.distance_to(ENTRANCE_TARGET) > 10.0:
			_fail("Player should reach the entrance aisle without sticking on furniture collision.")
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
