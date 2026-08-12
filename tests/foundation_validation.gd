extends Node

const PlayerController = preload("res://scripts/player/player.gd")
const PlayerAnimationControllerComponent = preload("res://scripts/player/player_animation.gd")
const InteractionDetectorComponent = preload("res://scripts/interaction/interaction_detector.gd")
const InteractableComponent = preload("res://scripts/interaction/interactable.gd")
const DialogueChoiceData = preload("res://scripts/dialogue/dialogue_choice.gd")
const DialogueLineData = preload("res://scripts/dialogue/dialogue_line.gd")
const DialogueResourceData = preload("res://scripts/dialogue/dialogue_resource.gd")
const DialogueControllerComponent = preload("res://scripts/dialogue/dialogue_controller.gd")
const NPCDataResource = preload("res://scripts/npc/npc_data.gd")
const NPCController = preload("res://scripts/npc/npc.gd")
const DayPeriodPaletteResource = preload("res://scripts/core/day_period_palette.gd")
const DayPeriodVisualControllerComponent = preload("res://scripts/core/day_period_visual_controller.gd")
const InsectDataResource = preload("res://scripts/insects/insect_data.gd")
const InsectController = preload("res://scripts/insects/insect.gd")
const BugCatcherComponent = preload("res://scripts/player/bug_catcher.gd")
const EventConditionResource = preload("res://scripts/events/event_condition.gd")
const EventActionResource = preload("res://scripts/events/event_action.gd")
const EventDefinitionResource = preload("res://scripts/events/event_definition.gd")
const YokaiDataResource = preload("res://scripts/yokai/yokai_data.gd")
const DayRecordResource = preload("res://scripts/diary/day_record.gd")
const DiaryUIComponent = preload("res://scripts/ui/diary_ui.gd")
const PlaytestPresetResource = preload("res://scripts/debug/playtest_preset.gd")
const PlaytestDebugControllerComponent = preload("res://scripts/debug/playtest_debug_controller.gd")
const EnvironmentAudioProfileResource = preload("res://scripts/audio/environment_audio_profile.gd")
const TEST_SAVE_PATH := "user://foundation_validation_save.json"
const CORRUPT_SAVE_PATH := "user://foundation_validation_corrupt.json"

var _failures: Array[String] = []


func _ready() -> void:
	_run()


func _run() -> void:
	_test_clock_periods()
	_test_clock_controls()
	_test_calendar()
	_test_input_map()
	_test_player_directions()
	_test_player_movement_state()
	_test_player_animation_state()
	_test_interaction_contract()
	_test_interaction_selection()
	_test_dialogue_resources()
	_test_dialogue_flow()
	_test_npc_data()
	_test_grandma_scene()
	_test_day_period_palette()
	_test_day_period_visual_controller()
	_test_environment_audio()
	_test_insect_entity()
	_test_bug_catching()
	_test_world_and_yokai_state()
	_test_event_manager()
	_test_kappa_events()
	_test_day_record_and_diary()
	_test_playtest_tools()
	_test_save_validation()
	_test_save_round_trip()
	_test_corrupted_json()
	if _failures.is_empty():
		print("Foundation validation passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)


func _test_clock_periods() -> void:
	_expect(GameClock.get_period_for_minutes(300) == &"morning", "05:00 should be morning")
	_expect(GameClock.get_period_for_minutes(599) == &"morning", "09:59 should be morning")
	_expect(GameClock.get_period_for_minutes(600) == &"daytime", "10:00 should be daytime")
	_expect(GameClock.get_period_for_minutes(989) == &"daytime", "16:29 should be daytime")
	_expect(GameClock.get_period_for_minutes(990) == &"evening", "16:30 should be evening")
	_expect(GameClock.get_period_for_minutes(1139) == &"evening", "18:59 should be evening")
	_expect(GameClock.get_period_for_minutes(1140) == &"night", "19:00 should be night")
	_expect(GameClock.get_period_for_minutes(299) == &"night", "04:59 should be night")


func _test_clock_controls() -> void:
	GameClock.debug_set_time(16, 30)
	_expect(GameClock.time_minutes == 990, "Debug time API should set minute-of-day")
	GameClock.set_clock_paused(true)
	_expect(GameClock.is_paused, "Clock pause should be enabled")
	GameClock.set_time_scale(2.0)
	_expect(is_equal_approx(GameClock.time_scale, 2.0), "Clock time scale should be settable")
	GameClock.set_clock_paused(false)
	GameClock.set_time_scale(1.0)


func _test_calendar() -> void:
	CalendarManager.debug_set_day(30)
	_expect(CalendarManager.day_index == 30, "Debug day API should reach day 30")
	_expect(not CalendarManager.next_day(), "Calendar should not advance beyond day 30")
	CalendarManager.debug_set_day(0)
	_expect(CalendarManager.day_index == 1, "Calendar should clamp to day 1")


func _test_input_map() -> void:
	var required_actions := [
		&"move_up", &"move_down", &"move_left", &"move_right", &"interact",
		&"run", &"use_tool", &"open_diary", &"pause", &"debug_menu",
	]
	for action in required_actions:
		_expect(InputMap.has_action(action), "InputMap should contain %s" % action)
	var debug_event := InputEventKey.new()
	debug_event.physical_keycode = KEY_F3
	_expect(InputMap.event_is_action(debug_event, &"debug_menu"), "F3 should open the debug menu")


func _test_player_directions() -> void:
	var direction_cases := {
		Vector2.DOWN: &"down",
		Vector2(-1, 1): &"down_left",
		Vector2.LEFT: &"left",
		Vector2(-1, -1): &"up_left",
		Vector2.UP: &"up",
		Vector2(1, -1): &"up_right",
		Vector2.RIGHT: &"right",
		Vector2(1, 1): &"down_right",
	}
	for direction: Vector2 in direction_cases:
		_expect(
			PlayerController.direction_to_facing(direction) == direction_cases[direction],
			"Player direction %s should map to %s" % [direction, direction_cases[direction]],
		)
	_expect(
		PlayerController.direction_to_facing(Vector2.ZERO, &"left") == &"left",
		"A stopped player should preserve the previous facing",
	)


func _test_player_movement_state() -> void:
	var player := PlayerController.new()
	add_child(player)
	player._apply_movement(Vector2(1, 1), false)
	_expect(is_equal_approx(player.velocity.length(), player.walk_speed), "Diagonal walk speed should be normalized")
	_expect(player.facing == &"down_right", "Movement should update player facing")
	player._apply_movement(Vector2.RIGHT, true)
	_expect(is_equal_approx(player.velocity.length(), player.run_speed), "Run input should use run speed")
	_expect(player.is_running, "Player should report the running state")
	player.set_movement_locked(true)
	_expect(player.velocity.is_zero_approx(), "Movement lock should stop the player")
	_expect(not player.is_moving, "Movement lock should clear movement state")
	player.queue_free()


func _test_player_animation_state() -> void:
	_expect(
		PlayerAnimationControllerComponent.make_animation_name(&"down", false, false) == &"idle_down",
		"Stopped player should select the directional idle animation",
	)
	_expect(
		PlayerAnimationControllerComponent.make_animation_name(&"up_left", true, false) == &"walk_up_left",
		"Moving player should select the directional walk animation",
	)
	_expect(
		PlayerAnimationControllerComponent.make_animation_name(&"right", true, true) == &"run_right",
		"Running player should select the directional run animation",
	)
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	var player := player_scene.instantiate()
	add_child(player)
	var animation_controller := player.get_node("AnimatedSprite2D") as PlayerAnimationController
	_expect(animation_controller != null, "Player scene should include the animation controller")
	if animation_controller != null:
		animation_controller.set_visual_state(&"down_right", true, false)
		_expect(animation_controller.desired_animation == &"walk_down_right", "Controller should track 8-direction walk state")
		_expect(not animation_controller.is_using_production_frames(), "Missing production frames should keep the explicit placeholder")
	player.queue_free()


func _test_interaction_contract() -> void:
	var actor := Node.new()
	var target := InteractableComponent.new()
	target.interaction_text = "Test action"
	_expect(target.can_interact(actor), "Enabled interactable should accept an actor")
	_expect(target.get_interaction_text(actor) == "Test action", "Interactable should expose prompt text")
	var interaction_count := [0]
	target.interacted.connect(func(_unused: Node) -> void: interaction_count[0] += 1)
	target.interact(actor)
	_expect(interaction_count[0] == 1, "Interactable should emit one interaction")
	target.interaction_enabled = false
	_expect(not target.can_interact(actor), "Disabled interactable should reject an actor")
	target.interact(actor)
	_expect(interaction_count[0] == 1, "Disabled interactable should not interact")
	actor.free()
	target.free()


func _test_interaction_selection() -> void:
	var actor := Node2D.new()
	var near_target := InteractableComponent.new()
	var far_target := InteractableComponent.new()
	var unavailable_target := InteractableComponent.new()
	add_child(actor)
	add_child(near_target)
	add_child(far_target)
	add_child(unavailable_target)
	near_target.global_position = Vector2(8, 0)
	far_target.global_position = Vector2(20, 0)
	unavailable_target.global_position = Vector2(1, 0)
	unavailable_target.interaction_enabled = false
	var candidates: Array[Node] = [far_target, unavailable_target, near_target]
	_expect(
		InteractionDetectorComponent.select_candidate(candidates, actor, Vector2.ZERO) == near_target,
		"Interaction detector should select the nearest available target",
	)
	far_target.global_position = near_target.global_position
	far_target.interaction_priority = 10
	_expect(
		InteractionDetectorComponent.select_candidate(candidates, actor, Vector2.ZERO) == far_target,
		"Interaction priority should break equal-distance ties",
	)
	actor.queue_free()
	near_target.queue_free()
	far_target.queue_free()
	unavailable_target.queue_free()


func _test_dialogue_resources() -> void:
	var invalid_dialogue := DialogueResourceData.new()
	_expect(not invalid_dialogue.is_valid_dialogue(), "Dialogue requires a stable id and at least one line")
	var line := DialogueLineData.new()
	line.speaker = "Tester"
	line.text = "Hello"
	var choice := DialogueChoiceData.new()
	choice.text = "Continue"
	choice.next_line_index = 1
	line.choices = [choice]
	var dialogue := DialogueResourceData.new()
	dialogue.dialogue_id = &"validation_dialogue"
	dialogue.lines = [line]
	_expect(dialogue.is_valid_dialogue(), "Valid dialogue resource should pass validation")
	_expect(line.has_choices(), "Dialogue line should expose its choices")
	_expect(choice.is_valid(), "Non-empty dialogue choice should be valid")


func _test_dialogue_flow() -> void:
	var controller: DialogueController = load("res://scenes/ui/dialogue_ui.tscn").instantiate()
	add_child(controller)
	var actor := PlayerController.new()
	add_child(actor)
	var line_a := DialogueLineData.new()
	line_a.text = "First"
	var line_b := DialogueLineData.new()
	line_b.text = "Choose"
	var branch_choice := DialogueChoiceData.new()
	branch_choice.text = "Branch"
	branch_choice.next_line_index = 2
	line_b.choices = [branch_choice]
	var line_c := DialogueLineData.new()
	line_c.text = "Last"
	var dialogue := DialogueResourceData.new()
	dialogue.dialogue_id = &"flow_test"
	dialogue.lines = [line_a, line_b, line_c]
	GameClock.set_clock_paused(false)
	_expect(controller.start_dialogue(dialogue, actor), "Dialogue controller should start valid dialogue")
	_expect(actor.movement_locked, "Dialogue should lock actor movement")
	_expect(GameClock.is_paused, "Dialogue should pause the game clock")
	_expect(controller.current_line_index == 0, "Dialogue should start from the first line")
	controller.advance()
	_expect(controller.current_line_index == 1, "Advance should show the next line")
	controller.advance()
	_expect(controller.current_line_index == 1, "Choice line should not advance without a choice")
	_expect(controller.choose(0), "Valid choice should be accepted")
	_expect(controller.current_line_index == 2, "Choice should branch to configured line")
	controller.advance()
	_expect(not controller.is_active(), "Dialogue should finish after the last line")
	_expect(not actor.movement_locked, "Dialogue finish should unlock actor movement")
	_expect(not GameClock.is_paused, "Dialogue finish should restore the previous clock pause state")
	controller.queue_free()
	actor.queue_free()


func _test_npc_data() -> void:
	var invalid_data := NPCDataResource.new()
	_expect(not invalid_data.is_valid_npc(), "NPC data requires a stable id and display name")
	invalid_data.npc_id = &"test_npc"
	invalid_data.display_name = "Test NPC"
	_expect(invalid_data.is_valid_npc(), "Complete NPC data should be valid")
	_expect(
		NPCController._direction_to_cardinal_facing(Vector2.RIGHT) == &"right",
		"NPC should face an actor on its right",
	)
	_expect(
		NPCController._direction_to_cardinal_facing(Vector2.UP) == &"up",
		"NPC should face an actor above it",
	)


func _test_grandma_scene() -> void:
	var grandma: NPC = load("res://scenes/npc/grandma.tscn").instantiate()
	add_child(grandma)
	_expect(grandma.get_npc_id() == &"grandma", "Grandma should expose her stable NPC id")
	_expect(grandma.get_display_name() == "おばあちゃん", "Grandma should expose her display name")
	var interaction_area := grandma.get_node("InteractionArea") as NPCInteractionArea
	_expect(interaction_area.dialogue != null, "Grandma should receive dialogue from NPC data")
	_expect(
		interaction_area.get_interaction_text(null) == "おばあちゃんと話す",
		"Grandma interaction should use her display name",
	)
	grandma.queue_free()


func _test_day_period_palette() -> void:
	var palette := DayPeriodPaletteResource.new()
	_expect(palette.get_color(&"morning") == palette.morning, "Morning should use morning palette color")
	_expect(palette.get_color(&"daytime") == palette.daytime, "Daytime should use daytime palette color")
	_expect(palette.get_color(&"evening") == palette.evening, "Evening should use evening palette color")
	_expect(palette.get_color(&"night") == palette.night, "Night should use night palette color")


func _test_day_period_visual_controller() -> void:
	var controller := DayPeriodVisualControllerComponent.new()
	controller.palette = DayPeriodPaletteResource.new()
	controller.transition_seconds = 0.0
	add_child(controller)
	controller.apply_period(&"evening", true)
	_expect(controller.color == controller.palette.evening, "Visual controller should apply period color")
	controller.queue_free()


func _test_environment_audio() -> void:
	var morning_stream := AudioStreamGenerator.new()
	var evening_stream := AudioStreamGenerator.new()
	var profile := EnvironmentAudioProfileResource.new()
	profile.area_id = &"audio_validation"
	profile.morning_stream = morning_stream
	profile.evening_stream = evening_stream
	_expect(profile.get_stream(&"morning") == morning_stream, "Audio profile should select the morning stream")
	_expect(profile.get_stream(&"evening") == evening_stream, "Audio profile should select the evening stream")
	_expect(profile.get_stream(&"night") == null, "Missing ambience assets should remain silent")
	var audio_scene: PackedScene = load("res://scenes/audio/environment_audio.tscn")
	var controller := audio_scene.instantiate() as EnvironmentAudioController
	controller.profiles = [profile]
	controller.crossfade_seconds = 0.0
	GameState.set_area(&"audio_validation")
	GameClock.debug_set_time(7, 0)
	add_child(controller)
	_expect(controller.get_profile(&"audio_validation") == profile, "Audio controller should resolve its location profile")
	_expect(controller.player_a.stream == morning_stream, "Initial area and period should select ambience")
	GameClock.debug_set_time(17, 0)
	_expect(controller.player_b.stream == evening_stream, "Period change should switch ambience streams")
	controller.player_a.stop()
	controller.player_b.stop()
	controller.free()


func _test_insect_entity() -> void:
	var invalid_data := InsectDataResource.new()
	_expect(not invalid_data.is_valid_insect(), "Insect data requires a stable id and display name")
	var insect: Insect = load("res://scenes/minigames/insect.tscn").instantiate()
	insect.data = load("res://resources/insects/aburazemi.tres")
	add_child(insect)
	_expect(insect.get_insect_id() == &"aburazemi", "Insect should expose its stable id")
	insect.choose_next_direction(0.0)
	_expect(insect.movement_direction.is_equal_approx(Vector2.RIGHT), "Insect direction should be normalized")
	var catch_request_count := [0]
	insect.catch_requested.connect(func(_insect: Insect, _actor: Node) -> void: catch_request_count[0] += 1)
	_expect(insect.request_catch(self), "Available insect should accept catch request")
	_expect(catch_request_count[0] == 1, "Catch request should emit once")
	insect.confirm_caught()
	_expect(insect.state == Insect.State.CAUGHT, "Confirmed insect should enter caught state")
	_expect(not insect.visible, "Caught insect should be hidden")
	_expect(not insect.request_catch(self), "Caught insect should reject another catch request")
	insect.queue_free()


func _test_bug_catching() -> void:
	var actor := PlayerController.new()
	var catcher := BugCatcherComponent.new()
	actor.add_child(catcher)
	add_child(actor)
	var near_insect: Insect = load("res://scenes/minigames/insect.tscn").instantiate()
	var far_insect: Insect = load("res://scenes/minigames/insect.tscn").instantiate()
	near_insect.data = load("res://resources/insects/aburazemi.tres")
	far_insect.data = near_insect.data
	add_child(near_insect)
	add_child(far_insect)
	near_insect.global_position = Vector2(4, 0)
	far_insect.global_position = Vector2(12, 0)
	var candidates: Array[Node] = [far_insect, near_insect]
	_expect(
		BugCatcherComponent.select_nearest_insect(candidates, Vector2.ZERO) == near_insect,
		"Bug catcher should select the nearest available insect",
	)
	catcher._nearby_insects = candidates
	catcher.use_cooldown_seconds = 0.0
	_expect(catcher.attempt_catch(), "Bug catcher should catch an insect in range")
	_expect(near_insect.state == Insect.State.CAUGHT, "Nearest insect should be caught")
	actor.set_movement_locked(true)
	_expect(not catcher.can_use_tool(), "Bug net should be disabled while actor movement is locked")
	actor.queue_free()
	near_insect.queue_free()
	far_insect.queue_free()


func _test_world_and_yokai_state() -> void:
	WorldState.reset_state()
	YokaiManager.reset_state()
	WorldState.set_flag(&"validation_flag")
	_expect(WorldState.has_flag(&"validation_flag"), "WorldState should store a named flag")
	WorldState.clear_flag(&"validation_flag")
	_expect(not WorldState.has_flag(&"validation_flag"), "WorldState should clear a named flag")
	_expect(YokaiManager.set_stage(&"kappa", &"TRACE"), "Yokai should advance to a valid stage")
	_expect(YokaiManager.get_stage(&"kappa") == &"TRACE", "Yokai stage should be readable")
	_expect(not YokaiManager.set_stage(&"kappa", &"UNKNOWN"), "Yokai stage should not regress by default")
	var kappa_data: YokaiData = load("res://resources/yokai/kappa.tres")
	_expect(kappa_data.is_valid_yokai(), "Kappa data should have stable id and display name")


func _test_event_manager() -> void:
	EventManager.reset_runtime()
	WorldState.reset_state()
	YokaiManager.reset_state()
	CalendarManager.debug_set_day(2)
	GameClock.debug_set_time(12, 0)
	GameState.set_area(&"river")
	var condition := EventConditionResource.new()
	condition.min_day = 2
	condition.locations = [&"river"]
	condition.time_periods = [&"daytime"]
	var action := EventActionResource.new()
	action.type = EventAction.Type.SET_FLAG
	action.target_id = &"event_validation_complete"
	var low_event := EventDefinitionResource.new()
	low_event.event_id = &"low_event"
	low_event.priority = 10
	low_event.condition = condition
	low_event.actions = [action]
	low_event.exclusive_group = &"validation_group"
	var high_event := EventDefinitionResource.new()
	high_event.event_id = &"high_event"
	high_event.priority = 100
	high_event.condition = condition
	high_event.exclusive_group = &"validation_group"
	EventManager.register_events([low_event, high_event])
	var candidates := EventManager.get_candidates()
	_expect(candidates.size() == 1 and candidates[0].event_id == &"high_event", "Priority should win within an exclusive group")
	_expect(EventManager.trigger_event(&"low_event"), "Matching event should trigger")
	_expect(WorldState.has_flag(&"event_validation_complete"), "Event action should set world flag")
	_expect(EventManager.has_seen(&"low_event"), "Triggered event should enter event history")
	_expect(not EventManager.trigger_event(&"low_event"), "Completed one-shot event should not trigger again")


func _test_kappa_events() -> void:
	EventManager.reset_runtime()
	WorldState.reset_state()
	YokaiManager.reset_state()
	var trace_event: EventDefinition = load("res://resources/events/kappa_first_trace.tres")
	var sighting_event: EventDefinition = load("res://resources/events/kappa_first_sighting.tres")
	EventManager.register_events([trace_event, sighting_event])
	CalendarManager.debug_set_day(2)
	GameClock.debug_set_time(12, 0)
	GameState.set_area(&"river")
	_expect(EventManager.trigger_event(&"kappa_first_trace"), "Kappa trace should trigger under documented conditions")
	_expect(YokaiManager.get_stage(&"kappa") == &"TRACE", "Kappa trace should advance stage to TRACE")
	_expect(WorldState.has_flag(&"kappa_first_trace_complete"), "Kappa trace should set completion flag")
	CalendarManager.debug_set_day(3)
	_expect(EventManager.trigger_event(&"kappa_first_sighting"), "Kappa sighting should follow trace on day 3")
	_expect(YokaiManager.get_stage(&"kappa") == &"SEEN", "Kappa sighting should advance stage to SEEN")
	_expect(WorldState.has_flag(&"kappa_first_sighting_complete"), "Kappa sighting should set completion flag")


func _test_day_record_and_diary() -> void:
	DiaryManager.reset_state()
	CalendarManager.debug_set_day(3)
	DiaryManager.record_location(&"river")
	DiaryManager.record_location(&"river")
	DiaryManager.record_npc(&"grandma")
	DiaryManager.record_yokai(&"kappa")
	DiaryManager.record_insect(&"aburazemi")
	DiaryManager.record_event(&"kappa_first_sighting")
	var record := DiaryManager.get_or_create_record(3)
	_expect(record.visited_locations.size() == 1, "DayRecord should de-duplicate locations")
	_expect(record.met_npcs.has(&"grandma"), "DayRecord should store met NPCs")
	_expect(record.met_yokai.has(&"kappa"), "DayRecord should store met yokai")
	_expect(record.caught_insects.has(&"aburazemi"), "DayRecord should store caught insects")
	var restored := DayRecordResource.deserialize(record.serialize())
	_expect(restored.events_seen.has(&"kappa_first_sighting"), "DayRecord round trip should preserve events")
	var formatted := DiaryUIComponent.format_record(restored)
	_expect(formatted.contains("grandma") and formatted.contains("kappa"), "Diary UI should format recorded facts")


func _test_playtest_tools() -> void:
	var player := PlayerController.new()
	add_child(player)
	var controller := PlaytestDebugControllerComponent.new()
	var preset: PlaytestPreset = load("res://resources/debug/kappa_sighting_ready.tres")
	controller.presets = [preset]
	add_child(controller)
	WorldState.set_flag(&"old_flag")
	DiaryManager.record_insect(&"old_insect")
	_expect(controller.apply_preset(&"kappa_sighting_ready"), "Playtest preset should apply")
	_expect(CalendarManager.day_index == 3, "Preset should set day")
	_expect(GameClock.time_minutes == 1020, "Preset should set time")
	_expect(GameState.current_area_id == &"river", "Preset should set area")
	_expect(YokaiManager.get_stage(&"kappa") == &"TRACE", "Preset should set kappa stage")
	_expect(WorldState.has_flag(&"kappa_first_trace_complete"), "Preset should set required flags")
	_expect(not WorldState.has_flag(&"old_flag"), "Preset should clear previous runtime flags")
	_expect(EventManager.has_seen(&"kappa_first_trace"), "Preset should set event history")
	_expect(player.global_position == Vector2(400, 160), "Preset should position player")
	_expect(controller.teleport(&"home"), "Known teleport point should work")
	_expect(player.global_position == Vector2(280, 180), "Teleport should move player")
	var snapshot := controller.get_snapshot()
	_expect(snapshot.kappa_stage == &"TRACE", "Snapshot should expose yokai stage")
	controller.reset_runtime_state()
	_expect(CalendarManager.day_index == 1, "Runtime reset should restore day 1")
	_expect(GameState.current_area_id == &"foundation_test", "Runtime reset should restore foundation area")
	_expect(YokaiManager.get_stage(&"kappa") == &"UNKNOWN", "Runtime reset should clear yokai state")
	controller.queue_free()
	player.queue_free()


func _test_save_validation() -> void:
	var valid_data := SaveManager.serialize()
	valid_data["future_field"] = {"is_tolerated": true}
	_expect(SaveManager.deserialize(valid_data), "Unknown save fields should be tolerated")
	var wrong_version := valid_data.duplicate(true)
	wrong_version["save_version"] = 999
	_expect(not SaveManager.deserialize(wrong_version), "Version mismatch should be rejected")
	var missing_calendar := valid_data.duplicate(true)
	missing_calendar.erase("calendar")
	_expect(not SaveManager.deserialize(missing_calendar), "Missing calendar should be rejected")
	var missing_optional := valid_data.duplicate(true)
	missing_optional.erase("player")
	missing_optional.erase("diary")
	_expect(SaveManager.deserialize(missing_optional), "Missing optional fields should be tolerated")


func _test_save_round_trip() -> void:
	var save_player := PlayerController.new()
	add_child(save_player)
	CalendarManager.debug_set_day(7)
	GameClock.debug_set_time(18, 45)
	WorldState.set_flag(&"save_round_trip_flag")
	YokaiManager.set_stage(&"kappa", &"SEEN", true)
	EventManager.deserialize_history(["save_round_trip_event"])
	DiaryManager.reset_state()
	DiaryManager.record_insect(&"aburazemi")
	save_player.set_facing(&"up_left")
	_expect(SaveManager.save_game(TEST_SAVE_PATH), "Save should write a valid file")
	CalendarManager.debug_set_day(1)
	GameClock.debug_set_time(7, 0)
	WorldState.reset_state()
	YokaiManager.reset_state()
	EventManager.deserialize_history([])
	DiaryManager.reset_state()
	_expect(SaveManager.load_game(TEST_SAVE_PATH), "Load should read a valid file")
	_expect(CalendarManager.day_index == 7, "Save round trip should preserve day")
	_expect(GameClock.time_minutes == 1125, "Save round trip should preserve time")
	_expect(WorldState.has_flag(&"save_round_trip_flag"), "Save round trip should preserve world flags")
	_expect(YokaiManager.get_stage(&"kappa") == &"SEEN", "Save round trip should preserve yokai stage")
	_expect(EventManager.has_seen(&"save_round_trip_event"), "Save round trip should preserve event history")
	_expect(DiaryManager.get_or_create_record(7).caught_insects.has(&"aburazemi"), "Save round trip should preserve DayRecord")
	_expect(save_player.facing == &"up_left", "Save round trip should preserve player facing")
	save_player.queue_free()


func _test_corrupted_json() -> void:
	var file := FileAccess.open(CORRUPT_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_failures.append("Could not create corrupted save fixture")
		return
	file.store_string("{not valid json")
	file.close()
	_expect(not SaveManager.load_game(CORRUPT_SAVE_PATH), "Corrupted JSON should be rejected")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
