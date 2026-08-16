extends Node


func _ready() -> void:
	var monitor := AreaSubdivisionMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class AreaSubdivisionMonitor extends Node:
	const BEDROOM_DESTINATION_AREA := &"grandma_house"
	const MAX_TRANSITION_FRAMES := 480
	const CASES := [
		{"path": "res://scenes/maps/bedroom/bedroom.tscn", "area": &"bedroom", "spawn": &"wake_up", "position": Vector2(360, 252)},
		{"path": "res://scenes/maps/village/engawa_yard.tscn", "area": &"engawa_yard", "spawn": &"house_exit", "position": Vector2(320, 184)},
		{"path": "res://scenes/maps/village/paddy_road.tscn", "area": &"paddy_road", "spawn": &"from_home", "position": Vector2(160, 202)},
		{"path": "res://scenes/maps/village/irrigation_shade.tscn", "area": &"irrigation_shade", "spawn": &"from_paddy", "position": Vector2(180, 204)},
		{"path": "res://scenes/maps/river/river_entrance.tscn", "area": &"river_entrance", "spawn": &"from_shade", "position": Vector2(180, 220)},
	]


	func run() -> void:
		CalendarManager.debug_set_day(1)
		GameClock.debug_set_time(7, 0)
		DiaryManager.reset_state()
		for area_case in CASES:
			var error := await SceneTransitionManager.change_scene(area_case.path, area_case.spawn)
			if error != OK:
				_fail("Could not open subdivided area %s." % area_case.area)
				return
			await get_tree().process_frame
			await get_tree().process_frame
			var scene := get_tree().current_scene as LocationScene
			if scene == null or scene.area_id != area_case.area:
				_fail("Subdivided area should preserve its catalog ID: %s." % area_case.area)
				return
			var background := scene.get_node_or_null("ProductionBackground") as Sprite2D
			if background == null or background.texture == null or background.texture.get_size() != Vector2(640, 360):
				_fail("Subdivided area should use a 640x360 Production background: %s." % area_case.area)
				return
			if background.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
				_fail("Subdivided area should keep Nearest filtering: %s." % area_case.area)
				return
			var navigation := scene.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
			if navigation == null or navigation.navigation_polygon == null or navigation.navigation_polygon.get_polygon_count() == 0:
				_fail("Subdivided area should provide click navigation: %s." % area_case.area)
				return
			if GameState.player.global_position != area_case.position:
				_fail("Subdivided area should place the player at its requested entry: %s." % area_case.area)
				return
			for child in scene.get_node("Objects").get_children():
				var doorway := child as MapDoorway
				if doorway != null and not ResourceLoader.exists(doorway.destination_scene, "PackedScene"):
					_fail("Doorway destination should exist in %s." % area_case.area)
					return
			if area_case.area == &"bedroom":
				if not await _verify_bedroom_exit():
					return
		_quit_cleanly(0)


	func _verify_bedroom_exit() -> bool:
		var scene := get_tree().current_scene
		var doorway := scene.get_node("Objects/ToLivingRoom") as MapDoorway
		var click_action := GameState.player.get_node("ClickActionController") as ClickActionController
		if not click_action.queue_action_at(doorway.global_position):
			_fail("The bedroom exit should accept a click action from the wake-up spawn.")
			return false
		for _frame in range(MAX_TRANSITION_FRAMES):
			var current_scene := get_tree().current_scene as LocationScene
			if not SceneTransitionManager.is_transitioning \
				and current_scene != null \
				and current_scene.area_id == BEDROOM_DESTINATION_AREA:
				return true
			await get_tree().physics_frame
		_fail("The bedroom fan must not block movement to the living-room exit.")
		return false


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
