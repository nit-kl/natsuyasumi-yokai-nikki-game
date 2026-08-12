extends Node


func _ready() -> void:
	var monitor := SaveLocationMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class SaveLocationMonitor extends Node:
	const TEST_SAVE_PATH := "user://save_location_restore_test.json"
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const RIVER_SCENE := "res://scenes/maps/river/river.tscn"
	const SAVED_POSITION := Vector2(224, 160)


	func run() -> void:
		if await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom") != OK:
			_fail("Could not enter house before save-location test.")
			return
		await get_tree().process_frame
		GameState.player.global_position = SAVED_POSITION
		GameState.player.set_facing(&"left")
		if not SaveManager.save_game(TEST_SAVE_PATH):
			_fail("Could not create location restore test save.")
			return
		if await SceneTransitionManager.change_scene(RIVER_SCENE, &"home_path") != OK:
			_fail("Could not enter river before restore.")
			return
		await get_tree().process_frame
		if GameState.current_area_id != &"river":
			_fail("River should be active before loading house save.")
			return
		if not await SaveManager.load_game_into_world(TEST_SAVE_PATH):
			_fail("World-aware load failed.")
			return
		await get_tree().process_frame
		if GameState.current_area_id != &"grandma_house":
			_fail("Load should restore the saved house scene.")
			return
		if not is_instance_valid(GameState.player) or GameState.player.global_position != SAVED_POSITION:
			_fail("Load should restore the saved player position after scene change.")
			return
		if GameState.player.facing != &"left":
			_fail("Load should restore facing after scene change.")
			return
		_cleanup()
		get_tree().quit(0)


	func _fail(message: String) -> void:
		_cleanup()
		push_error(message)
		get_tree().quit(1)


	func _cleanup() -> void:
		if FileAccess.file_exists(TEST_SAVE_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
