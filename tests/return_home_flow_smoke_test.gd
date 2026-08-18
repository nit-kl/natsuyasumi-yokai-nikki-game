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
		WorldState.reset_state()
		DiaryManager.reset_state()
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
		if GameState.player.movement_locked or GameClock.is_paused:
			_fail("The next morning should leave the player free to walk and let the clock run.")
			return
		if WorldState.has_flag(&"vertical_slice_complete"):
			_fail("Main progression should not require the vertical slice completion flag.")
			return
		if interaction.dialogue == null or interaction.dialogue.dialogue_id != &"grandma_foundation_greeting":
			_fail("The next morning should restore grandma's daytime greeting.")
			return
		if not dialogue_controller.start_dialogue(interaction.dialogue, GameState.player):
			_fail("Grandma should be talkable again on the next morning.")
			return
		dialogue_controller.finish_dialogue()
		var outdoor_exit := scene.get_node_or_null("Objects/ExitToOutdoor") as MapDoorway
		if outdoor_exit == null or not outdoor_exit.can_interact(GameState.player):
			_fail("The next morning should still allow leaving the house.")
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
		CalendarManager.debug_set_day(30)
		GameClock.debug_set_time(17, 0)
		await get_tree().process_frame
		if interaction.dialogue == null or interaction.dialogue.dialogue_id != &"grandma_evening_dinner":
			_fail("Day 30 evening should still offer dinner before the final review.")
			return
		if not dialogue_controller.start_dialogue(interaction.dialogue, GameState.player):
			_fail("Day 30 dinner dialogue should start.")
			return
		dialogue_controller.finish_dialogue()
		await get_tree().process_frame
		if not diary.is_open():
			_fail("Day 30 dinner should open the final diary review.")
			return
		diary.set_open(false)
		if CalendarManager.day_index != 30 or not WorldState.has_flag(&"vertical_slice_final_day_reviewed"):
			_fail("Day 30 review should not advance into day 31.")
			return
		if interaction.dialogue == null or interaction.dialogue.dialogue_id != &"grandma_foundation_greeting":
			_fail("Day 30 should not repeat the dinner flow after review.")
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
