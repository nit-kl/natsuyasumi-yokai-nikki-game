extends Node


func _ready() -> void:
	var monitor := VerticalSliceDayMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class VerticalSliceDayMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const OUTDOOR_SCENE := "res://scenes/maps/village/home_outdoor.tscn"
	const RIVER_SCENE := "res://scenes/maps/river/river.tscn"


	func run() -> void:
		_reset_slice_state()
		if not await _open_scene(HOUSE_SCENE, &"bedroom"):
			return
		var house := get_tree().current_scene
		var grandma := house.get_node("NPCs/Grandma") as NPC
		var house_dialogue := house.get_node("LocationRuntime/DialogueController") as DialogueController
		var grandma_interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		await get_tree().process_frame
		var recorder_connection_count := grandma.interacted.get_connections().size()
		var grandma_signal_received := [false]
		grandma.interacted.connect(func(_npc_id: StringName) -> void: grandma_signal_received[0] = true)
		grandma_interaction.interact(GameState.player)
		if not grandma_signal_received[0]:
			_fail("Grandma interaction should emit the NPC interaction signal.")
			return
		if recorder_connection_count == 0:
			_fail("Day record recorder should connect to grandma before interaction.")
			return
		if not house_dialogue.is_active():
			_fail("Morning grandma dialogue should start.")
			return
		house_dialogue.finish_dialogue()

		if not await _open_scene(OUTDOOR_SCENE, &"house_exit"):
			return
		var outdoor := get_tree().current_scene
		var insect := outdoor.get_node("Objects/Aburazemi") as Insect
		var catcher := GameState.player.get_node("BugCatcher") as BugCatcher
		catcher._nearby_insects = [insect]
		catcher.use_cooldown_seconds = 0.0
		if not catcher.attempt_catch():
			_fail("The outdoor aburazemi should be catchable in the day flow.")
			return

		if not await _open_scene(RIVER_SCENE, &"home_path"):
			return
		var river := get_tree().current_scene
		var trace_trigger: Node = river.get_node("EventTriggers/KappaTrace")
		var sighting_trigger: Node = river.get_node("EventTriggers/KappaSighting")
		if not trace_trigger.try_trigger(GameState.player):
			_fail("Walking along the river should reveal the kappa trace.")
			return
		if not sighting_trigger.try_trigger(GameState.player):
			_fail("Walking farther along the river should reveal the kappa glimpse.")
			return
		if GameClock.get_period() != &"evening":
			_fail("The kappa glimpse should turn the slice toward evening.")
			return

		if not await _open_scene(OUTDOOR_SCENE, &"river_path"):
			return
		if not await _open_scene(HOUSE_SCENE, &"entrance"):
			return
		house = get_tree().current_scene
		var flow := house.get_node("ReturnHomeFlow") as ReturnHomeFlow
		flow.autosave_enabled = false
		grandma = house.get_node("NPCs/Grandma") as NPC
		house_dialogue = house.get_node("LocationRuntime/DialogueController") as DialogueController
		var diary := house.get_node("LocationRuntime/DiaryUI") as DiaryUI
		grandma_interaction = grandma.get_node("InteractionArea") as NPCInteractionArea
		grandma_interaction.interact(GameState.player)
		if house_dialogue.current_dialogue == null or house_dialogue.current_dialogue.dialogue_id != &"grandma_evening_dinner":
			_fail("Returning in the evening should start grandma's dinner dialogue.")
			return
		house_dialogue.finish_dialogue()
		await get_tree().process_frame
		if not diary.is_open():
			_fail("Dinner should open the day diary review.")
			return
		diary.set_open(false)
		await get_tree().process_frame
		_validate_completed_slice(house)


	func _reset_slice_state() -> void:
		CalendarManager.debug_set_day(1)
		GameClock.debug_set_time(7, 0)
		GameClock.set_clock_paused(false)
		WorldState.reset_state()
		YokaiManager.reset_state()
		EventManager.reset_runtime()
		DiaryManager.reset_state()


	func _open_scene(path: String, spawn_id: StringName) -> bool:
		var error := await SceneTransitionManager.change_scene(path, spawn_id)
		if error != OK:
			_fail("Could not open %s." % path)
			return false
		await get_tree().process_frame
		return true


	func _validate_completed_slice(house: Node) -> void:
		var record := DiaryManager.get_or_create_record(1)
		var expected_locations: Array[StringName] = [&"grandma_house", &"home_outdoor", &"river"]
		for location_id in expected_locations:
			if not record.visited_locations.has(location_id):
				_fail("Day record is missing location %s." % location_id)
				return
		if not record.met_npcs.has(&"grandma") or not record.caught_insects.has(&"aburazemi"):
			_fail("Day record should include grandma and the caught insect (npcs=%s insects=%s)." % [record.met_npcs, record.caught_insects])
			return
		if not record.met_yokai.has(&"kappa") or not record.events_seen.has(&"kappa_first_trace") or not record.events_seen.has(&"kappa_first_sighting"):
			_fail("Day record should include the complete kappa encounter.")
			return
		if CalendarManager.day_index != 1 or not WorldState.has_flag(&"vertical_slice_complete"):
			_fail("Closing the diary should end the slice without advancing to day 2.")
			return
		if YokaiManager.get_stage(&"kappa") != &"SEEN" or not GameClock.is_paused:
			_fail("Completed slice should preserve the sighting and pause time.")
			return
		var completion_panel := house.get_node("VerticalSliceCompletion/Panel") as Control
		if not completion_panel.visible or not GameState.player.movement_locked:
			_fail("Completed slice should show its ending and stop player input.")
			return
		get_tree().quit(0)


	func _fail(message: String) -> void:
		push_error(message)
		get_tree().quit(1)
