extends Node


func _ready() -> void:
	var monitor := ClickActionMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class ClickActionMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const MAX_ACTION_FRAMES := 480


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom")
		if error != OK:
			_fail("Could not open the house for click action testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var house := get_tree().current_scene
		var player := GameState.player
		var click_action := player.get_node("ClickActionController") as ClickActionController
		var grandma := house.get_node("NPCs/Grandma") as NPC
		var grandma_interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		var dialogue := house.get_node("LocationRuntime/DialogueController") as DialogueController
		if click_action.pick_target_at(grandma.global_position) != grandma_interaction:
			_fail("Click picking should resolve grandma to her interaction area.")
			return
		if not click_action.queue_action_at(grandma.global_position):
			_fail("Clicking grandma should queue an approach interaction.")
			return
		var right_click := InputEventMouseButton.new()
		right_click.button_index = MOUSE_BUTTON_RIGHT
		right_click.pressed = true
		var click_move := player.get_node("ClickMoveController") as ClickMoveController
		click_move._unhandled_input(right_click)
		if click_action.is_active or click_move.is_active:
			_fail("Right click should cancel both the queued action and its approach movement.")
			return
		if not click_action.queue_action_at(grandma.global_position):
			_fail("Grandma interaction should be queueable again after cancellation.")
			return
		if not await _wait_until(func() -> bool: return dialogue.is_active()):
			_fail("Clicking grandma should approach her and start dialogue once in range.")
			return
		dialogue.finish_dialogue()
		await get_tree().physics_frame
		var exit := house.get_node("Objects/ExitToOutdoor") as MapDoorway
		if click_action.pick_target_at(exit.global_position) != exit:
			_fail("Click picking should resolve the house exit.")
			return
		if not click_action.queue_action_at(exit.global_position):
			_fail("Clicking the exit should queue an approach interaction.")
			return
		if not await _wait_until(func() -> bool: return GameState.current_area_id == &"engawa_yard"):
			_fail("Clicking the exit should approach it and change to the outdoor map (player=%s destination=%s moving=%s action=%s)." % [player.global_position, click_move.destination, click_move.is_active, click_action.is_active])
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var outdoor := get_tree().current_scene
		player = GameState.player
		click_action = player.get_node("ClickActionController") as ClickActionController
		var insect := outdoor.get_node("Objects/Aburazemi") as Insect
		if click_action.pick_target_at(insect.global_position) != insect:
			_fail("Click picking should resolve the aburazemi.")
			return
		if not click_action.queue_action_at(insect.global_position):
			_fail("Clicking the aburazemi should queue a catch action.")
			return
		if not await _wait_until(func() -> bool: return insect.state == Insect.State.CAUGHT):
			_fail("Clicking the aburazemi should approach it and use the existing bug catcher.")
			return
		var record := DiaryManager.get_or_create_record(1)
		if not record.caught_insects.has(&"aburazemi"):
			_fail("Mouse-driven insect catching should keep the existing diary recording contract.")
			return
		await get_tree().create_timer(0.7).timeout
		_quit_cleanly(0)


	func _wait_until(predicate: Callable) -> bool:
		for _frame in range(MAX_ACTION_FRAMES):
			if predicate.call():
				return true
			await get_tree().physics_frame
		return false


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
