extends Node


func _ready() -> void:
	var monitor := ReturnHomeMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class ReturnHomeMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"


	func run() -> void:
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"entrance")
		if error != OK:
			_fail("Could not open grandma house for return-home test.")
			return
		await get_tree().process_frame
		var scene := get_tree().current_scene
		var flow := scene.get_node_or_null("ReturnHomeFlow") as ReturnHomeFlow
		var grandma := scene.get_node_or_null("NPCs/Grandma") as NPC
		var diary := scene.get_node_or_null("LocationRuntime/DiaryUI") as DiaryUI
		var dialogue_controller := scene.get_node_or_null("LocationRuntime/DialogueController") as DialogueController
		if flow == null or grandma == null or diary == null or dialogue_controller == null:
			_fail("Return-home scene dependencies are missing.")
			return
		flow.autosave_enabled = false
		flow.end_vertical_slice_after_review = false
		CalendarManager.debug_set_day(3)
		GameClock.debug_set_time(17, 0)
		var interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		if interaction.dialogue == null or interaction.dialogue.dialogue_id != &"grandma_evening_dinner":
			_fail("Evening should switch grandma to the dinner dialogue.")
			return
		if not dialogue_controller.start_dialogue(interaction.dialogue, GameState.player):
			_fail("Dinner dialogue should start through the dialogue controller.")
			return
		dialogue_controller.finish_dialogue()
		await get_tree().process_frame
		if not diary.is_open():
			_fail("Finishing dinner dialogue should open the diary review.")
			return
		if diary.is_showing_cover():
			_fail("The required evening review should open directly to the daily page.")
			return
		var record := DiaryManager.get_or_create_record(3)
		if record.sleep_time != 1020 or not record.diary_fragments.has(&"evening_diary_written"):
			_fail("Diary review should finalize the current day record.")
			return
		diary.set_open(false)
		if CalendarManager.day_index != 4 or GameClock.time_minutes != 420:
			_fail("Closing the review should advance to the next morning.")
			return
		if not is_instance_valid(GameState.player) or GameState.player.global_position != Vector2(142, 174):
			_fail("Next morning should place the player in the bedroom.")
			return
		# A regular diary open/close is not a day-completion action.
		diary.set_open(true)
		if not diary.is_showing_cover():
			_fail("Regular diary browsing should begin at the cover.")
			return
		diary.set_open(false)
		if CalendarManager.day_index != 4:
			_fail("Regular diary browsing must not advance the day.")
			return
		_quit_cleanly(0)


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
		await get_tree().create_timer(0.1).timeout
		get_tree().quit(exit_code)
