extends Node


func _ready() -> void:
	var monitor := ForegroundOcclusionMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class ForegroundOcclusionMonitor extends Node:
	const MAP_CASES := [
		{
			"scene": "res://scenes/maps/grandma_house/grandma_house.tscn",
			"spawn": &"bedroom",
			"occluders": [&"CenterTable", &"CenterPlant", &"DiningSet", &"LeftShoji", &"RightShoji"],
		},
		{
			"scene": "res://scenes/maps/village/home_outdoor.tscn",
			"spawn": &"house_exit",
			"occluders": [&"PaddyEdge", &"GardenVegetation", &"CornEdge"],
		},
		{
			"scene": "res://scenes/maps/river/river.tscn",
			"spawn": &"home_path",
			"occluders": [&"LeftShrub", &"LeftHydrangea", &"BottomFence"],
		},
	]


	func run() -> void:
		_reset_state()
		for map_case in MAP_CASES:
			if not await _verify_map(map_case):
				return
		await get_tree().create_timer(0.2).timeout
		_quit_cleanly(0)


	func _verify_map(map_case: Dictionary) -> bool:
		var error := await SceneTransitionManager.change_scene(map_case.scene, map_case.spawn)
		if error != OK:
			_fail("Could not open map for foreground occlusion testing: %s" % map_case.scene)
			return false
		await get_tree().physics_frame
		await get_tree().physics_frame
		var scene := get_tree().current_scene
		var background := scene.get_node("ProductionBackground") as Sprite2D
		var container := scene.get_node_or_null("ForegroundOccluders")
		if container == null:
			_fail("Production map should provide a ForegroundOccluders container: %s" % map_case.scene)
			return false
		var player := GameState.player
		for occluder_name in map_case.occluders:
			var occluder := container.get_node_or_null(NodePath(occluder_name)) as ForegroundOccluder2D
			if occluder == null or occluder.texture != background.texture:
				_fail("Foreground occluder should reuse the map Production texture: %s" % occluder_name)
				return false
			if occluder.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
				_fail("Foreground occluder should preserve Nearest texture filtering: %s" % occluder_name)
				return false
			if occluder.polygon.size() < 3 or occluder.uv != occluder.polygon:
				_fail("Foreground occluder should map its polygon to identical source pixels: %s" % occluder_name)
				return false
			player.global_position = Vector2(occluder.global_position.x, occluder.global_position.y + occluder.occlusion_y - 16.0)
			player.refresh_depth_order()
			occluder.refresh()
			if player.z_index >= occluder.depth_z_index or occluder.z_index != occluder.depth_z_index:
				_fail("Occluder should draw above a Player standing behind it: %s" % occluder_name)
				return false
			player.global_position.y = occluder.global_position.y + occluder.occlusion_y - 8.0
			player.refresh_depth_order()
			occluder.refresh()
			if player.z_index <= occluder.depth_z_index:
				_fail("Occluder should use the Player's feet and return behind it at the boundary: %s" % occluder_name)
				return false
		if map_case.scene == "res://scenes/maps/grandma_house/grandma_house.tscn":
			var table := container.get_node("CenterTable") as ForegroundOccluder2D
			var grandma := scene.get_node("NPCs/Grandma") as NPC
			player.global_position = Vector2(320.0, 190.0)
			grandma.global_position = Vector2(320.0, 217.0)
			player.refresh_depth_order()
			grandma.refresh_depth_order()
			if player.z_index >= table.z_index or grandma.z_index <= table.z_index:
				_fail("The table should sort independently between the Player behind it and Grandma in front of it.")
				return false
		return true


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
			await get_tree().create_timer(0.2).timeout
		if scene != null:
			scene.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
