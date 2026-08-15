extends Node


func _ready() -> void:
	var monitor := ClickTargetHoverMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class ClickTargetHoverMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const OUTDOOR_SCENE := "res://scenes/maps/village/home_outdoor.tscn"


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom")
		if error != OK:
			_fail("Could not open the house for target hover testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var house := get_tree().current_scene
		var player := GameState.player
		var hover := player.get_node("ClickTargetHover") as ClickTargetHoverController
		var grandma := house.get_node("NPCs/Grandma") as NPC
		var grandma_interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		if hover.update_hover_at(grandma.global_position) != grandma_interaction:
			_fail("Hover picking should resolve grandma to her interaction area.")
			return
		if not hover.visible or not hover._cursor_claimed or hover.global_position != grandma.global_position:
			_fail("Hovering grandma should show the subtle target frame and claim the pointer cursor.")
			return
		var exit := house.get_node("Objects/ExitToOutdoor") as MapDoorway
		if hover.update_hover_at(exit.global_position) != exit or hover._visual_half_size != Vector2(18.0, 7.0):
			_fail("Hovering a doorway should use its wider ground-level frame.")
			return
		player.set_movement_locked(true)
		if hover.update_hover_at(exit.global_position) != null or hover.visible or hover._cursor_claimed:
			_fail("Movement lock should hide hover feedback and restore the default cursor.")
			return
		player.set_movement_locked(false)
		if hover.update_hover_at(Vector2(16.0, 16.0)) != null or hover.visible:
			_fail("Hover feedback should disappear over non-interactable ground.")
			return
		error = await SceneTransitionManager.change_scene(OUTDOOR_SCENE, &"house_exit")
		if error != OK:
			_fail("Could not open home outdoor for insect hover testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var outdoor := get_tree().current_scene
		player = GameState.player
		hover = player.get_node("ClickTargetHover") as ClickTargetHoverController
		var insect := outdoor.get_node("Objects/Aburazemi") as Insect
		if hover.update_hover_at(insect.global_position) != insect or hover._visual_half_size != Vector2(7.0, 7.0):
			_fail("Hovering the aburazemi should show the compact insect frame.")
			return
		insect.confirm_caught()
		if hover.update_hover_at(insect.global_position) != null or hover.visible:
			_fail("Caught insects should no longer expose hover feedback.")
			return
		hover.clear_hover()
		_quit_cleanly(0)


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
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		var scene := get_tree().current_scene
		var audio := scene.get_node_or_null("LocationRuntime/EnvironmentAudio") as EnvironmentAudioController if scene != null else null
		if audio != null:
			audio.shutdown()
			audio.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
