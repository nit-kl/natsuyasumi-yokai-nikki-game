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
const InsectSpawnProfileResource = preload("res://scripts/insects/insect_spawn_profile.gd")
const BugCatcherComponent = preload("res://scripts/player/bug_catcher.gd")
const BugCatchPresenterComponent = preload("res://scripts/player/bug_catch_presenter.gd")
const EventConditionResource = preload("res://scripts/events/event_condition.gd")
const EventActionResource = preload("res://scripts/events/event_action.gd")
const EventDefinitionResource = preload("res://scripts/events/event_definition.gd")
const YokaiDataResource = preload("res://scripts/yokai/yokai_data.gd")
const DayRecordResource = preload("res://scripts/diary/day_record.gd")
const WeatherForecastResource = preload("res://scripts/core/weather_forecast.gd")
const DiaryUIComponent = preload("res://scripts/ui/diary_ui.gd")
const GameplayHUDComponent = preload("res://scripts/ui/foundation_hud.gd")
const PlaytestPresetResource = preload("res://scripts/debug/playtest_preset.gd")
const PlaytestDebugControllerComponent = preload("res://scripts/debug/playtest_debug_controller.gd")
const EnvironmentAudioProfileResource = preload("res://scripts/audio/environment_audio_profile.gd")
const LocationSceneComponent = preload("res://scripts/maps/location_scene.gd")
const MapSpawnPointComponent = preload("res://scripts/maps/map_spawn_point.gd")
const ReturnHomeFlowComponent = preload("res://scripts/events/return_home_flow.gd")
const LocationCatalogData = preload("res://scripts/maps/location_catalog.gd")
const WeatherVisualPaletteResource = preload("res://scripts/core/weather_visual_palette.gd")
const WeatherPresentationData = preload("res://scripts/ui/weather_presentation.gd")
const WeatherRainOverlayComponent = preload("res://scripts/vfx/weather_rain_overlay.gd")
const ItemDataResource = preload("res://scripts/inventory/item_data.gd")
const InventoryUIComponent = preload("res://scripts/ui/inventory_ui.gd")
const TEST_SAVE_PATH := "user://foundation_validation_save.json"
const CORRUPT_SAVE_PATH := "user://foundation_validation_corrupt.json"

var _failures: Array[String] = []


func _ready() -> void:
	_run()


func _run() -> void:
	_test_clock_periods()
	_test_clock_controls()
	_test_calendar()
	_test_weather_manager()
	_test_input_map()
	_test_gameplay_hud()
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
	_test_location_maps()
	_test_return_home_rules()
	_test_location_catalog()
	_test_insect_entity()
	_test_insect_spawn_profiles()
	_test_bug_catching()
	_test_world_and_yokai_state()
	_test_inventory_manager()
	_test_inventory_ui()
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
	_expect(is_equal_approx(GameClock.minutes_per_real_second, 0.375), "Default clock speed should target a 30-45 minute day")
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


func _test_weather_manager() -> void:
	DiaryManager.reset_state()
	WeatherManager.reset_state()
	CalendarManager.debug_set_day(1)
	_expect(WeatherManager.get_weather() == &"sunny", "Day 1 should start sunny")
	_expect(WeatherManager.weather_id_from_enum(WeatherManager.Weather.THUNDERSTORM) == &"thunderstorm", "Weather enum should map to save IDs")
	_expect(not WeatherManager.set_weather(&"snow"), "Unknown weather IDs should be rejected")
	_expect(WeatherManager.get_weather() == &"sunny", "Rejected weather should leave the current value")
	_expect(WeatherManager.debug_set_weather(&"rain"), "Debug weather API should accept rain")
	_expect(WeatherManager.get_weather() == &"rain", "WeatherManager should keep the current day's weather")
	_expect(DiaryManager.get_or_create_record(1).weather == &"rain", "Current DayRecord weather should follow WeatherManager")
	var forecast := WeatherForecastResource.new()
	forecast.first_day_weather = &"sunny"
	forecast.sunny_weight = 0.0
	forecast.cloudy_weight = 0.0
	forecast.rain_weight = 1.0
	forecast.thunderstorm_weight = 0.0
	forecast.override_day_indexes = [5]
	forecast.override_weathers = [&"thunderstorm"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	_expect(forecast.choose(1, &"rain", rng) == &"sunny", "Forecast table should keep day 1 on first_day_weather")
	_expect(forecast.choose(5, &"sunny", rng) == &"thunderstorm", "Forecast table should honor day overrides")
	_expect(forecast.choose(2, &"sunny", rng) == &"rain", "Forecast table should pick from resource weights")
	var previous_forecast := WeatherManager.forecast
	WeatherManager.forecast = forecast
	CalendarManager.debug_set_day(2)
	WeatherManager.debug_set_weather(&"sunny")
	_expect(CalendarManager.next_day(), "Calendar should advance from day 2")
	_expect(CalendarManager.day_index == 3, "next_day should move to day 3")
	_expect(WeatherManager.get_weather() == &"rain", "Advancing the calendar should roll tomorrow's weather from the table")
	_expect(DiaryManager.get_or_create_record(3).weather == &"rain", "Rolled weather should stamp the new DayRecord")
	WeatherManager.debug_set_weather(&"cloudy")
	CalendarManager.debug_set_day(2)
	_expect(WeatherManager.get_weather() == &"sunny", "Debug day changes should restore a previous DayRecord weather")
	WeatherManager.debug_set_weather(&"rain")
	var condition := EventConditionResource.new()
	condition.weathers = [&"rain"]
	_expect(bool(condition.evaluate().matches), "Event conditions should match the current weather")
	WeatherManager.debug_set_weather(&"sunny")
	_expect(not bool(condition.evaluate().matches), "Event conditions should reject a disallowed weather")
	WeatherManager.forecast = previous_forecast
	DiaryManager.reset_state()
	WeatherManager.reset_state()
	CalendarManager.debug_set_day(1)
	_expect(WeatherManager.get_weather() == &"sunny", "Reset should restore the first-day weather")


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


func _test_gameplay_hud() -> void:
	_expect(GameplayHUDComponent.display_name(&"morning", GameplayHUDComponent.PERIOD_NAMES) == "朝", "Gameplay HUD should localize the day period")
	_expect(GameplayHUDComponent.display_name(&"sunny", GameplayHUDComponent.WEATHER_NAMES) == "晴れ", "Gameplay HUD should localize the weather")
	_expect(GameplayHUDComponent.display_name(&"cloudy", GameplayHUDComponent.WEATHER_NAMES) == "曇り", "Gameplay HUD should localize cloudy weather")
	_expect(GameplayHUDComponent.display_name(&"rain", GameplayHUDComponent.WEATHER_NAMES) == "雨", "Gameplay HUD should localize rain")
	_expect(GameplayHUDComponent.display_name(&"thunderstorm", GameplayHUDComponent.WEATHER_NAMES) == "雷雨", "Gameplay HUD should localize thunderstorms")
	_expect(WeatherPresentationData.icon_texture(&"rain") != null, "Rain should have a weather icon")
	_expect(GameplayHUDComponent.display_name(&"unknown", {}) == "unknown", "Gameplay HUD should preserve unknown stable IDs")
	var hud_scene: PackedScene = load("res://scenes/ui/gameplay_hud.tscn")
	var hud := hud_scene.instantiate()
	var status_panel := hud.get_node_or_null("StatusPanel") as TextureRect
	var tool_panel := hud.get_node_or_null("ToolPanel") as TextureRect
	var prompt_panel := hud.get_node_or_null("PromptPanel") as TextureRect
	_expect(status_panel != null and status_panel.texture != null, "Gameplay HUD should use the production status panel")
	_expect(tool_panel != null and tool_panel.texture != null, "Gameplay HUD should use the production tool panel")
	_expect(prompt_panel != null and prompt_panel.texture != null, "Gameplay HUD should use the production interaction panel")
	if status_panel != null and status_panel.texture != null:
		_expect(status_panel.texture.get_size() == Vector2(208, 72), "HUD status panel should match its pixel-art canvas")
	if tool_panel != null and tool_panel.texture != null:
		_expect(tool_panel.texture.get_size() == Vector2(128, 44), "HUD tool panel should match its pixel-art canvas")
	if prompt_panel != null and prompt_panel.texture != null:
		_expect(prompt_panel.texture.get_size() == Vector2(300, 48), "HUD interaction panel should match its pixel-art canvas")
	_expect(hud.get_node_or_null("Notice") == null, "Production HUD should not keep the foundation control legend")
	var inventory_button := hud.get_node_or_null("InventoryButton") as Button
	_expect(inventory_button != null and inventory_button.text == "かばん", "Gameplay HUD should provide a mouse-first inventory button")
	hud.free()


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
	var navigation_agent := player.get_node_or_null("NavigationAgent") as NavigationAgent2D
	var click_move := player.get_node_or_null("ClickMoveController") as ClickMoveController
	var click_action := player.get_node_or_null("ClickActionController") as ClickActionController
	var destination_marker := player.get_node_or_null("ClickDestinationMarker") as ClickDestinationMarker
	var target_hover := player.get_node_or_null("ClickTargetHover") as ClickTargetHoverController
	_expect(navigation_agent != null, "Player scene should include click-navigation pathfinding")
	_expect(click_move != null, "Player scene should include the click movement controller")
	_expect(click_action != null, "Player scene should include click-to-approach actions")
	_expect(destination_marker != null, "Player scene should include the click destination marker")
	_expect(target_hover != null, "Player scene should include target hover feedback")
	_expect(animation_controller != null, "Player scene should include the animation controller")
	if animation_controller != null:
		animation_controller.set_visual_state(&"down_right", true, false)
		_expect(animation_controller.desired_animation == &"walk_down_right", "Controller should track 8-direction walk state")
		_expect(animation_controller.is_using_production_frames(), "Cardinal production frames should serve diagonal movement through fallback")
		_expect(animation_controller.animation == &"walk_right", "Down-right movement should fall back to the right production animation")
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
	var confirm_audio := controller.get_node_or_null("ConfirmAudio") as AudioStreamPlayer
	_expect(confirm_audio != null and confirm_audio.stream != null, "Dialogue confirmation should have a production audio cue")
	if confirm_audio != null and confirm_audio.stream != null:
		_expect(confirm_audio.stream.get_length() < 0.5, "UI confirmation cue should stay short")
		_expect(not (confirm_audio.stream as AudioStreamOggVorbis).loop, "UI confirmation cue should not loop")
	var dialogue_panel := controller.get_node_or_null("Panel") as TextureRect
	_expect(dialogue_panel != null and dialogue_panel.texture != null, "Dialogue UI should use the production paper panel")
	if dialogue_panel != null and dialogue_panel.texture != null:
		_expect(dialogue_panel.texture.get_size() == Vector2(560, 132), "Dialogue production panel should match its pixel-art canvas")
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
	_expect(confirm_audio.playing, "Advancing dialogue should play the confirmation cue")
	_expect(controller.choices_container.get_child_count() == 1, "Choice line should create its production choice button")
	if controller.choices_container.get_child_count() == 1:
		var production_choice := controller.choices_container.get_child(0) as Button
		_expect(production_choice.custom_minimum_size == Vector2(240, 42), "Dialogue choice should match its production frame")
		_expect(production_choice.get_theme_stylebox("normal") is StyleBoxTexture, "Dialogue choice should use the production texture style")
	controller.advance()
	_expect(controller.current_line_index == 1, "Choice line should not advance without a choice")
	var choice_button := controller.choices_container.get_child(0) as Button
	choice_button.pressed.emit()
	_expect(confirm_audio.playing, "Choosing a dialogue option should play the confirmation cue")
	_expect(controller.current_line_index == 2, "Clicking a valid choice should branch to its configured line")
	controller.advance()
	_expect(not controller.is_active(), "Dialogue should finish after the last line")
	_expect(not actor.movement_locked, "Dialogue finish should unlock actor movement")
	_expect(not GameClock.is_paused, "Dialogue finish should restore the previous clock pause state")
	confirm_audio.stop()
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
	var sprite := grandma.get_node("AnimatedSprite2D") as AnimatedSprite2D
	_expect(sprite.visible and sprite.animation == &"idle_left", "Grandma should use her configured production idle facing")
	grandma.set_facing(&"right")
	_expect(sprite.animation == &"idle_right", "Grandma production sprite should follow dialogue-facing changes")
	grandma.queue_free()


func _test_day_period_palette() -> void:
	var palette := DayPeriodPaletteResource.new()
	_expect(palette.get_color(&"morning") == palette.morning, "Morning should use morning palette color")
	_expect(palette.get_color(&"daytime") == palette.daytime, "Daytime should use daytime palette color")
	_expect(palette.get_color(&"evening") == palette.evening, "Evening should use evening palette color")
	_expect(palette.get_color(&"night") == palette.night, "Night should use night palette color")
	_expect(palette.get_color(&"unknown") == palette.daytime, "Unknown periods should fall back to daytime")
	var production: DayPeriodPalette = load("res://resources/locations/default_day_period_palette.tres")
	_expect(production.morning.is_equal_approx(Color("fff0d2")), "Production morning should use the soft golden tint")
	_expect(production.daytime.is_equal_approx(Color("fffaf2")), "Production daytime should retain a slight summer warmth")
	_expect(production.evening.is_equal_approx(Color("f2ae7d")), "Production evening should use the nostalgic orange tint")
	_expect(production.night.is_equal_approx(Color("7888ad")), "Production night should use the readable blue-gray tint")
	_expect(production.night.r >= 0.45 and production.night.g >= 0.5, "Production night should remain bright enough for exploration")
	var weather_palette: WeatherVisualPalette = load("res://resources/weather/default_weather_visual_palette.tres")
	var storm_night := weather_palette.compose(production.night, &"thunderstorm", &"night")
	_expect(storm_night.get_luminance() >= weather_palette.minimum_night_luminance, "Rainy nights should stay bright enough to walk")
	_expect(weather_palette.compose(production.daytime, &"sunny", &"daytime") == production.daytime, "Sunny days should keep the period palette")


func _test_day_period_visual_controller() -> void:
	WeatherManager.reset_state()
	var controller := DayPeriodVisualControllerComponent.new()
	controller.palette = DayPeriodPaletteResource.new()
	controller.transition_seconds = 0.0
	add_child(controller)
	controller.apply_period(&"evening", true)
	_expect(controller.color == controller.palette.evening, "Visual controller should apply period color")
	controller.transition_seconds = 3.0
	controller.apply_period(&"evening")
	_expect(controller._transition_tween == null, "Visual controller should skip no-op period transitions")
	controller.apply_period(&"night")
	_expect(controller._transition_tween != null, "Visual controller should tween between different production periods")
	controller.apply_period(&"morning", true)
	_expect(controller._transition_tween == null and controller.color == controller.palette.morning, "Immediate period changes should cancel an active transition cleanly")
	controller.weather_palette = WeatherVisualPaletteResource.new()
	WeatherManager.debug_set_weather(&"rain")
	controller.apply_period(&"daytime", true)
	_expect(controller.color != controller.palette.daytime, "Rain should tint the period palette")
	WeatherManager.reset_state()
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
	var rain_stream := AudioStreamGenerator.new()
	profile.apply_weather_streams = true
	profile.rain_stream = rain_stream
	_expect(profile.get_stream(&"morning", &"rain") == rain_stream, "Outdoor profiles should switch to rain ambience")
	_expect(profile.get_stream(&"morning", &"sunny") == morning_stream, "Sunny weather should keep the period ambience")
	var house_profile: EnvironmentAudioProfile = load("res://resources/locations/grandma_house_audio_profile.tres")
	var outdoor_profile: EnvironmentAudioProfile = load("res://resources/locations/home_outdoor_audio_profile.tres")
	var river_profile: EnvironmentAudioProfile = load("res://resources/locations/river_audio_profile.tres")
	_expect(house_profile.get_stream(&"morning") != null, "Grandma house should provide its production interior ambience")
	_expect(outdoor_profile.get_stream(&"daytime") != null, "Home outdoor should provide its daytime cicada ambience")
	_expect(outdoor_profile.get_stream(&"evening") != null, "Home outdoor should provide its evening higurashi ambience")
	_expect(outdoor_profile.get_stream(&"morning") == null, "Unproduced outdoor morning ambience should remain silent")
	_expect(outdoor_profile.get_stream(&"daytime", &"rain") != outdoor_profile.get_stream(&"daytime"), "Home outdoor rain should replace cicadas")
	_expect(house_profile.get_stream(&"morning", &"rain") == house_profile.get_stream(&"morning"), "Indoor rain should keep the room tone")
	_expect(river_profile.get_stream(&"daytime") != null, "River should provide its production water ambience")
	EnvironmentAudioController.configure_ambience_stream(river_profile.default_stream, true)
	_expect((river_profile.default_stream as AudioStreamOggVorbis).loop, "Production ambience should be configured to loop")
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


func _test_location_maps() -> void:
	var grandma_house_scene: PackedScene = load("res://scenes/maps/grandma_house/grandma_house.tscn")
	var outdoor_scene: PackedScene = load("res://scenes/maps/village/home_outdoor.tscn")
	var river_scene: PackedScene = load("res://scenes/maps/river/river.tscn")
	_expect(grandma_house_scene != null, "Grandma house map should load")
	_expect(outdoor_scene != null, "Home outdoor map should load")
	_expect(river_scene != null, "River map should load")
	var house := grandma_house_scene.instantiate() as LocationScene
	var outdoor := outdoor_scene.instantiate() as LocationScene
	var river := river_scene.instantiate() as LocationScene
	_expect(house.area_id == &"grandma_house", "Grandma house should use a stable location ID")
	_expect(outdoor.area_id == &"home_outdoor", "Home outdoor should use a stable location ID")
	_expect(river.area_id == &"river", "River should use a stable location ID")
	_expect(house.get_node_or_null("Ground") is TileMapLayer, "House should expose the production Ground layer")
	_expect(house.get_node_or_null("Collision") is TileMapLayer, "House should expose the production Collision layer")
	_expect(house.get_node_or_null("NPCs/Grandma") != null, "Grandma should be placed in the house NPC layer")
	var return_home := house.get_node_or_null("ReturnHomeFlow") as ReturnHomeFlow
	_expect(return_home != null and not return_home.end_vertical_slice_after_review, "Production grandma house should continue to the next morning after diary review")
	var house_background := house.get_node_or_null("ProductionBackground") as Sprite2D
	_expect(house_background != null and house_background.texture != null, "Grandma house should use its production interior background")
	_expect(house_background.texture.get_size() == Vector2(640, 360), "Grandma house production background should match the base viewport")
	_expect(not house.get_node("GreyboxVisual").visible, "Grandma house greybox visual should be disabled after production art integration")
	var grandma := house.get_node_or_null("NPCs/Grandma") as NPC
	_expect(grandma != null and grandma.sprite_frames != null, "Grandma should use her production sprite frames")
	_expect(grandma.sprite_frames.get_frame_count(&"idle_down") == 1, "Grandma should provide a directional idle frame")
	_expect(outdoor.get_node_or_null("Objects/InsectSpawner") is InsectAreaSpawner, "Outdoor map should generate its bug-catching target from an area profile")
	var outdoor_background := outdoor.get_node_or_null("ProductionBackground") as Sprite2D
	_expect(outdoor_background != null and outdoor_background.texture != null, "Outdoor map should use its production background")
	_expect(outdoor_background.texture.get_size() == Vector2(640, 360), "Outdoor production background should match the base viewport")
	_expect(not outdoor.get_node("GreyboxVisual").visible, "Outdoor greybox visual should be disabled after production art integration")
	_expect(outdoor.get_node_or_null("WorldCollision/IrrigationWest") is CollisionPolygon2D, "Outdoor irrigation channel should follow the production rice-field side")
	_expect(outdoor.get_node_or_null("WorldCollision/IrrigationEast") is CollisionPolygon2D, "Outdoor irrigation channel should follow the production garden side")
	var outdoor_navigation := outdoor.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
	_expect(outdoor_navigation != null and outdoor_navigation.navigation_polygon.get_polygon_count() > 8, "Outdoor navigation should be baked around production geometry")
	_expect(river.get_node_or_null("Water") is TileMapLayer, "River should expose a separate production Water layer")
	_expect(river.get_node_or_null("Yokai/KappaGlimpse") != null, "River should contain the subtle kappa presenter")
	_expect(river.get_node_or_null("WorldCollision/RiverWater") is CollisionPolygon2D, "River water boundary should follow the production shoreline")
	var river_navigation := river.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
	_expect(river_navigation != null and river_navigation.navigation_polygon != null, "River navigation should use a production resource")
	var river_background := river.get_node_or_null("ProductionBackground") as Sprite2D
	_expect(river_background != null and river_background.texture != null, "River map should use its production background")
	_expect(river_background.texture.get_size() == Vector2(640, 360), "River production background should match the base viewport")
	_expect(not river.get_node("GreyboxVisual").visible, "River greybox visual should be disabled after production art integration")
	var ripple := river.get_node_or_null("Yokai/KappaGlimpse/Ripple") as AnimatedSprite2D
	_expect(ripple != null and ripple.sprite_frames.get_frame_count(&"ripple") == 4, "Kappa trace should use the four-frame production ripple")
	_expect(ripple != null and not ripple.visible, "River background should stay calm before a kappa event")
	var kappa_surface := river.get_node_or_null("Yokai/KappaGlimpse/KappaSurface") as AnimatedSprite2D
	_expect(kappa_surface != null and kappa_surface.sprite_frames.get_frame_count(&"surface") == 4, "Kappa sighting should use the four-frame production surface animation")
	_expect(kappa_surface != null and not kappa_surface.sprite_frames.get_animation_loop(&"surface"), "Kappa surface animation should play only once per sighting")
	_expect(kappa_surface != null and not kappa_surface.visible, "Kappa should remain hidden before the sighting event")
	var ripple_audio := river.get_node_or_null("Yokai/KappaGlimpse/RippleAudio") as AudioStreamPlayer2D
	var kappa_cue_audio := river.get_node_or_null("Yokai/KappaGlimpse/KappaCueAudio") as AudioStreamPlayer2D
	_expect(ripple_audio != null and ripple_audio.stream != null, "Kappa trace should include the production water ripple cue")
	_expect(kappa_cue_audio != null and kappa_cue_audio.stream != null, "Kappa sighting should include the subtle production audio cue")
	var spawn_point := MapSpawnPointComponent.new()
	spawn_point.spawn_id = &"validation_entry"
	var spawn_parent := Node2D.new()
	house.add_child(spawn_parent)
	spawn_parent.add_child(spawn_point)
	_expect(house.get_spawn_point(&"validation_entry") == spawn_point, "Location should resolve its own spawn point")
	house.free()
	outdoor.free()
	river.free()


func _test_return_home_rules() -> void:
	_expect(ReturnHomeFlowComponent.is_return_period(&"evening"), "Evening should allow the return-home flow")
	_expect(ReturnHomeFlowComponent.is_return_period(&"night"), "Night should allow the return-home flow")
	_expect(not ReturnHomeFlowComponent.is_return_period(&"morning"), "Morning should keep grandma's normal dialogue")
	var dinner: DialogueResource = load("res://resources/dialogue/grandma_evening_dinner.tres")
	_expect(dinner != null and dinner.is_valid_dialogue(), "Dinner dialogue should be valid data")


func _test_location_catalog() -> void:
	_expect(LocationCatalogData.get_scene_path(&"bedroom").ends_with("bedroom.tscn"), "Save location catalog should resolve the bedroom")
	_expect(LocationCatalogData.get_scene_path(&"grandma_house").ends_with("grandma_house.tscn"), "Save location catalog should resolve grandma house")
	_expect(LocationCatalogData.get_scene_path(&"home_outdoor").ends_with("home_outdoor.tscn"), "Save location catalog should resolve home outdoor")
	_expect(LocationCatalogData.get_scene_path(&"engawa_yard").ends_with("engawa_yard.tscn"), "Save location catalog should resolve the engawa yard")
	_expect(LocationCatalogData.get_scene_path(&"paddy_road").ends_with("paddy_road.tscn"), "Save location catalog should resolve the paddy road")
	_expect(LocationCatalogData.get_scene_path(&"irrigation_shade").ends_with("irrigation_shade.tscn"), "Save location catalog should resolve the irrigation shade")
	_expect(LocationCatalogData.get_scene_path(&"river_entrance").ends_with("river_entrance.tscn"), "Save location catalog should resolve the river entrance")
	_expect(LocationCatalogData.get_scene_path(&"river").ends_with("river.tscn"), "Save location catalog should resolve river")
	_expect(not LocationCatalogData.has_area(&"unknown_area"), "Unknown save locations should be rejected")
	_expect(LocationCatalogData.is_outdoor(&"river"), "River should be treated as an outdoor location")
	_expect(LocationCatalogData.is_outdoor(&"engawa_yard"), "The engawa yard should be treated as outdoor")
	_expect(not LocationCatalogData.is_outdoor(&"grandma_house"), "Grandma house should stay indoor")
	_expect(not LocationCatalogData.is_outdoor(&"bedroom"), "The bedroom should stay indoor")
	var overlay := WeatherRainOverlayComponent.new()
	add_child(overlay)
	GameState.set_area(&"grandma_house")
	WeatherManager.debug_set_weather(&"rain")
	overlay.refresh()
	_expect(not overlay.visible, "Indoor rain should not spawn raindrops")
	GameState.set_area(&"home_outdoor")
	overlay.refresh()
	_expect(overlay.visible, "Outdoor rain should show a modest rain overlay")
	WeatherManager.debug_set_weather(&"sunny")
	overlay.refresh()
	_expect(not overlay.visible, "Sunny outdoor weather should hide raindrops")
	GameState.set_area(&"foundation_test")
	WeatherManager.reset_state()
	overlay.queue_free()


func _test_insect_entity() -> void:
	var invalid_data := InsectDataResource.new()
	_expect(not invalid_data.is_valid_insect(), "Insect data requires a stable id and display name")
	var insect: Insect = load("res://scenes/minigames/insect.tscn").instantiate()
	insect.data = load("res://resources/insects/aburazemi.tres")
	add_child(insect)
	_expect(insect.get_insect_id() == &"aburazemi", "Insect should expose its stable id")
	var insect_sprite := insect.get_node_or_null("InsectSprite") as Sprite2D
	_expect(insect_sprite != null and insect_sprite.texture != null, "Vertical Slice insect should use the aburazemi production sprite")
	if insect_sprite != null and insect_sprite.texture != null:
		_expect(insect_sprite.texture.get_size() == Vector2(24, 24), "Aburazemi production sprite should match its pixel-art canvas")
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


func _test_insect_spawn_profiles() -> void:
	var home_profile: InsectSpawnProfileResource = load("res://resources/insects/spawn_profiles/home_outdoor_aburazemi.tres")
	var river_profile: InsectSpawnProfileResource = load("res://resources/insects/spawn_profiles/river_aburazemi.tres")
	_expect(home_profile != null and home_profile.is_valid_profile(), "Home outdoor should use a valid insect spawn profile")
	_expect(river_profile != null and river_profile.is_valid_profile(), "River should use a valid insect spawn profile")
	if home_profile != null:
		var rng := RandomNumberGenerator.new()
		rng.seed = 1
		_expect(home_profile.get_spawn_count(rng, 1) >= 1, "Day 1 should guarantee at least one tutorial insect")
		_expect(home_profile.preferred_day_one_spawn_point_names == [&"HousePathMid", &"HousePathEast"], "Day 1 tutorial insect should prioritize the house-to-fields route")
		_expect(home_profile.suppress_after_daily_catch, "Caught species should not respawn on same-day area re-entry")
	var outdoor: Node = load("res://scenes/maps/village/home_outdoor.tscn").instantiate()
	var river: Node = load("res://scenes/maps/river/river.tscn").instantiate()
	_expect(outdoor.get_node_or_null("Objects/InsectSpawner") is InsectAreaSpawner, "Home outdoor should own an area insect spawner")
	_expect(outdoor.get_node("Objects/InsectSpawner/SpawnPoints").get_child_count() >= 3, "Home outdoor should provide multiple habitat spawn points")
	_expect(river.get_node_or_null("Objects/InsectSpawner") is InsectAreaSpawner, "River should own an area insect spawner")
	_expect(river.get_node("Objects/InsectSpawner/SpawnPoints").get_child_count() >= 3, "River should provide multiple habitat spawn points")
	outdoor.free()
	river.free()
	DiaryManager.reset_state()
	CalendarManager.debug_set_day(1)
	var first_location := _make_insect_spawn_test_location(home_profile)
	var first_spawner := first_location.get_node("Objects/InsectSpawner") as InsectAreaSpawner
	var first_spawn := first_spawner.spawn_for_current_day()
	var first_positions: Array[Vector2] = []
	for insect in first_spawn:
		first_positions.append(insect.position)
	var second_location := _make_insect_spawn_test_location(home_profile)
	var second_spawner := second_location.get_node("Objects/InsectSpawner") as InsectAreaSpawner
	var second_spawn := second_spawner.spawn_for_current_day()
	var second_positions: Array[Vector2] = []
	for insect in second_spawn:
		second_positions.append(insect.position)
	_expect(not first_spawn.is_empty(), "Day 1 area spawning should produce the guaranteed tutorial insect")
	_expect(first_positions == second_positions, "Same day and area should reproduce stable insect placement")
	_expect(first_positions[0] == Vector2(32.0, 64.0), "Day 1 guaranteed insect should use the first prioritized spawn point")
	DiaryManager.record_insect(&"aburazemi")
	var caught_location := _make_insect_spawn_test_location(home_profile)
	var caught_spawner := caught_location.get_node("Objects/InsectSpawner") as InsectAreaSpawner
	_expect(caught_spawner.spawn_for_current_day().is_empty(), "A caught species should not respawn on same-day area re-entry")
	first_location.free()
	second_location.free()
	caught_location.free()
	DiaryManager.reset_state()


func _make_insect_spawn_test_location(profile: InsectSpawnProfileResource) -> LocationScene:
	var location := LocationScene.new()
	location.area_id = &"spawn_test_area"
	var objects := Node2D.new()
	objects.name = "Objects"
	location.add_child(objects)
	var spawner := InsectAreaSpawner.new()
	spawner.name = "InsectSpawner"
	spawner.profile = profile
	objects.add_child(spawner)
	var points := Node2D.new()
	points.name = "SpawnPoints"
	spawner.add_child(points)
	for index in range(3):
		var point := Marker2D.new()
		point.name = "Habitat%d" % index
		point.position = Vector2(32.0 + index * 24.0, 64.0)
		points.add_child(point)
	return location


func _test_bug_catching() -> void:
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	var production_player := player_scene.instantiate()
	add_child(production_player)
	var presenter := production_player.get_node_or_null("BugCatchPresenter") as Node2D
	var net_sprite := production_player.get_node_or_null("BugCatchPresenter/NetSprite") as Sprite2D
	var swing_audio := production_player.get_node_or_null("BugCatchPresenter/SwingAudio") as AudioStreamPlayer2D
	var success_audio := production_player.get_node_or_null("BugCatchPresenter/SuccessAudio") as AudioStreamPlayer2D
	_expect(presenter != null, "Player scene should include the bug-catching presentation component")
	_expect(net_sprite != null and net_sprite.texture != null, "Bug-catching presentation should use the production net sprite")
	if net_sprite != null and net_sprite.texture != null:
		_expect(net_sprite.texture.get_size() == Vector2(32, 48), "Bug net production sprite should match its pixel-art canvas")
	_expect(swing_audio != null and swing_audio.stream != null, "Bug net swing should have a production audio cue")
	_expect(success_audio != null and success_audio.stream != null, "Successful bug catch should have a production audio cue")
	if swing_audio != null and swing_audio.stream != null:
		_expect(swing_audio.stream.get_length() < 1.0, "Bug net swing cue should stay short")
		_expect(not (swing_audio.stream as AudioStreamOggVorbis).loop, "Bug net swing cue should not loop")
	if success_audio != null and success_audio.stream != null:
		_expect(success_audio.stream.get_length() < 1.0, "Bug catch success cue should stay short")
		_expect(not (success_audio.stream as AudioStreamOggVorbis).loop, "Bug catch success cue should not loop")
	_expect(
		is_equal_approx(BugCatchPresenterComponent.get_net_rotation_for_direction(Vector2.RIGHT), PI / 4.0),
		"Bug net rotation should follow the player's facing direction",
	)
	var production_catcher := production_player.get_node("BugCatcher") as BugCatcher
	production_catcher.use_cooldown_seconds = 0.0
	_expect(not production_catcher.attempt_catch(), "Using the production net without an insect should remain a miss")
	_expect(net_sprite.visible, "Using the bug-catching tool should immediately show the net swing")
	_expect(swing_audio.playing, "Using the bug-catching tool should play its swing cue")
	swing_audio.stop()
	success_audio.stop()
	production_player.queue_free()
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


func _test_inventory_manager() -> void:
	InventoryManager.reset_state()
	_expect(InventoryManager.has(&"bug_net"), "A new playthrough should start with the bug net")
	_expect(InventoryManager.count(&"bug_net") == 1, "The starting bug net count should be 1")
	_expect(InventoryManager.get_money() == 0, "A new playthrough should start with 0 yen")
	_expect(not InventoryManager.has(&"cucumber"), "A new playthrough should not start with extra items")

	var bug_net := InventoryManager.get_item_data(&"bug_net")
	_expect(bug_net != null, "The item catalog should include bug_net")
	_expect(bug_net != null and bug_net.display_name == "虫取り網", "bug_net should keep its Japanese display name")
	_expect(bug_net != null and bug_net.kind == ItemDataResource.Kind.TOOL, "bug_net should be a tool")
	var cucumber := InventoryManager.get_item_data(&"cucumber")
	_expect(cucumber != null and cucumber.kind == ItemDataResource.Kind.CONSUMABLE, "cucumber should be a consumable")

	_expect(InventoryManager.add(&"cucumber", 2), "Known items should be addable")
	_expect(InventoryManager.count(&"cucumber") == 2, "Added cucumber count should be 2")
	_expect(not InventoryManager.add(&"cucumber", 0), "Zero-count adds should fail")
	_expect(not InventoryManager.add(&"unknown_item", 1), "Unknown catalog items should be rejected")
	_expect(InventoryManager.remove(&"cucumber", 1), "Known items should be removable")
	_expect(InventoryManager.count(&"cucumber") == 1, "Removing one cucumber should leave 1")
	_expect(not InventoryManager.remove(&"cucumber", 2), "Removing more than owned should fail")
	_expect(InventoryManager.count(&"cucumber") == 1, "A failed remove should leave the count unchanged")

	_expect(InventoryManager.add_money(120), "Positive money additions should succeed")
	_expect(InventoryManager.get_money() == 120, "Money should increase by the added amount")
	_expect(InventoryManager.add_money(-40), "Spending money should succeed when funds remain")
	_expect(InventoryManager.get_money() == 80, "Spending 40 yen should leave 80")
	_expect(not InventoryManager.add_money(0), "Zero yen changes should fail")
	_expect(not InventoryManager.add_money(-200), "Spending more than owned should fail")
	_expect(InventoryManager.get_money() == 80, "A failed spend should leave money unchanged")
	_expect(not InventoryManager.set_money(-1), "Negative money should be rejected")

	var item_gate := EventConditionResource.new()
	item_gate.required_items = [&"cucumber"]
	_expect(bool(item_gate.evaluate().matches), "An event that requires a cucumber should pass after adding one")
	item_gate.required_items = [&"unknown_item"]
	_expect(not bool(item_gate.evaluate().matches), "An event that requires a missing item should fail")
	item_gate.required_items = []
	_expect(bool(item_gate.evaluate().matches), "An empty required_items list should not block events")

	InventoryManager.reset_state()
	_expect(not InventoryManager.has(&"cucumber"), "Reset should clear extra items")
	_expect(InventoryManager.has(&"bug_net"), "Reset should restore the starting bug net")
	_expect(InventoryManager.get_money() == 0, "Reset should restore 0 yen")


func _test_inventory_ui() -> void:
	InventoryManager.reset_state()
	_expect(InventoryUIComponent.format_item_line("虫取り網", 1) == "虫取り網　×1", "Inventory UI should format an item name and count")
	_expect(InventoryUIComponent.format_money(80) == "お小遣い　80円", "Inventory UI should format pocket money")
	var player := PlayerController.new()
	add_child(player)
	var ui_scene: PackedScene = load("res://scenes/ui/inventory_ui.tscn")
	var ui := ui_scene.instantiate()
	add_child(ui)
	var paper := ui.get_node_or_null("Panel/Paper") as Control
	var cancel_audio := ui.get_node_or_null("CancelAudio") as AudioStreamPlayer
	_expect(paper != null, "Inventory UI should use a paper memo panel")
	_expect(cancel_audio != null and cancel_audio.stream != null, "Closing inventory should have a production cancel cue")
	_expect(not ui.is_open(), "Inventory UI should start closed")
	_expect(not player.movement_locked, "Inventory UI should not lock movement while closed")
	ui.set_open(true)
	_expect(ui.is_open(), "Inventory UI should open")
	_expect(player.movement_locked, "Opening inventory should lock movement")
	_expect(ui.money_label.text == "お小遣い　0円", "Open inventory should show current money")
	_expect(_inventory_row_texts(ui).has("虫取り網　×1"), "Open inventory should list the starting bug net")
	_expect(not _inventory_row_texts(ui).has("キュウリ　×2"), "Open inventory should not invent extra items")
	InventoryManager.add(&"cucumber", 2)
	InventoryManager.set_money(80)
	_expect(_inventory_row_texts(ui).has("キュウリ　×2"), "Open inventory should refresh when items change")
	_expect(ui.money_label.text == "お小遣い　80円", "Open inventory should refresh when money changes")
	ui.close_button.pressed.emit()
	_expect(not ui.is_open(), "The close button should close inventory")
	_expect(not player.movement_locked, "Closing inventory should unlock movement")
	_expect(cancel_audio.playing, "Closing inventory should play cancel feedback")
	cancel_audio.stop()
	InventoryManager.reset_state()
	ui.queue_free()
	player.queue_free()


func _inventory_row_texts(ui: InventoryUIComponent) -> PackedStringArray:
	var lines := PackedStringArray()
	for child in ui.item_list.get_children():
		for grandchild in child.get_children():
			if grandchild is Label:
				lines.append(grandchild.text)
	return lines


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
	CalendarManager.debug_set_day(1)
	GameClock.debug_set_time(12, 0)
	GameState.set_area(&"river")
	_expect(EventManager.trigger_event(&"kappa_first_trace"), "Kappa trace should trigger under documented conditions")
	_expect(YokaiManager.get_stage(&"kappa") == &"TRACE", "Kappa trace should advance stage to TRACE")
	_expect(WorldState.has_flag(&"kappa_first_trace_complete"), "Kappa trace should set completion flag")
	_expect(EventManager.trigger_event(&"kappa_first_sighting"), "Kappa sighting should follow the trace later on day 1")
	_expect(YokaiManager.get_stage(&"kappa") == &"SEEN", "Kappa sighting should advance stage to SEEN")
	_expect(WorldState.has_flag(&"kappa_first_sighting_complete"), "Kappa sighting should set completion flag")
	_expect(GameClock.time_minutes == 1020, "Kappa sighting should move the slice into evening")
	var glimpse_scene: PackedScene = load("res://scenes/yokai/kappa_glimpse.tscn")
	var glimpse := glimpse_scene.instantiate() as KappaGlimpsePresenter
	add_child(glimpse)
	glimpse.present_trace()
	_expect(glimpse.ripple_audio.playing, "Kappa trace presentation should play the water ripple cue")
	glimpse.present_sighting()
	_expect(glimpse.kappa_cue_audio.playing, "Kappa sighting presentation should play the subtle audio cue")
	glimpse.ripple_audio.stop()
	glimpse.kappa_cue_audio.stop()
	glimpse.queue_free()


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
	_expect(formatted.contains("おばあちゃん") and formatted.contains("河童"), "Diary UI should format stable IDs as player-facing names")
	var diary_scene: PackedScene = load("res://scenes/ui/diary_ui.tscn")
	var diary := diary_scene.instantiate()
	var page_turn_audio := diary.get_node_or_null("PageTurnAudio") as AudioStreamPlayer
	var cancel_audio := diary.get_node_or_null("CancelAudio") as AudioStreamPlayer
	var cover_art := diary.get_node_or_null("Panel/Cover/CoverArt") as TextureRect
	var notebook := diary.get_node_or_null("Panel/Notebook") as TextureRect
	var kappa_stamp := diary.get_node_or_null("Panel/Notebook/KappaStamp") as TextureRect
	var insect_stamp := diary.get_node_or_null("Panel/Notebook/InsectStamp") as TextureRect
	_expect(notebook != null and notebook.texture != null, "Diary UI should use the production notebook page")
	_expect(cover_art != null and cover_art.texture != null, "Diary UI should use the production diary cover")
	if cover_art != null and cover_art.texture != null:
		_expect(cover_art.texture.get_size() == Vector2(224, 280), "Diary production cover should match its pixel-art canvas")
	if notebook != null and notebook.texture != null:
		_expect(notebook.texture.get_size() == Vector2(512, 320), "Diary production page should match its pixel-art canvas")
	_expect(kappa_stamp != null and kappa_stamp.texture != null, "Diary UI should include the kappa record stamp")
	_expect(insect_stamp != null and insect_stamp.texture != null, "Diary UI should include the aburazemi record stamp")
	_expect(page_turn_audio != null and page_turn_audio.stream != null, "Diary page transition should have a production audio cue")
	if page_turn_audio != null and page_turn_audio.stream != null:
		_expect(page_turn_audio.stream.get_length() < 1.0, "Diary page-turn cue should stay short")
		_expect(not (page_turn_audio.stream as AudioStreamOggVorbis).loop, "Diary page-turn cue should not loop")
	_expect(cancel_audio != null and cancel_audio.stream != null, "Closing the diary should have a production cancel cue")
	if cancel_audio != null and cancel_audio.stream != null:
		_expect(cancel_audio.stream.get_length() < 0.5, "UI cancel cue should stay short")
		_expect(not (cancel_audio.stream as AudioStreamOggVorbis).loop, "UI cancel cue should not loop")
	diary.free()


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
	_expect(CalendarManager.day_index == 1, "Preset should keep the vertical slice on day 1")
	_expect(GameClock.time_minutes == 720, "Preset should set the sighting setup time")
	_expect(GameState.current_area_id == &"river", "Preset should set area")
	_expect(YokaiManager.get_stage(&"kappa") == &"TRACE", "Preset should set kappa stage")
	_expect(WorldState.has_flag(&"kappa_first_trace_complete"), "Preset should set required flags")
	_expect(not WorldState.has_flag(&"old_flag"), "Preset should clear previous runtime flags")
	_expect(EventManager.has_seen(&"kappa_first_trace"), "Preset should set event history")
	_expect(player.global_position == Vector2(400, 240), "Preset should position player")
	_expect(controller.teleport(&"home"), "Known teleport point should work")
	_expect(player.global_position == Vector2(280, 180), "Teleport should move player")
	InventoryManager.add(&"cucumber", 1)
	InventoryManager.set_money(50)
	var snapshot := controller.get_snapshot()
	_expect(snapshot.kappa_stage == &"TRACE", "Snapshot should expose yokai stage")
	_expect(int(snapshot.money) == 50, "Snapshot should expose current money")
	_expect(int(snapshot.items.get("cucumber", 0)) == 1, "Snapshot should expose current items")
	controller.reset_runtime_state()
	_expect(CalendarManager.day_index == 1, "Runtime reset should restore day 1")
	_expect(GameState.current_area_id == &"foundation_test", "Runtime reset should restore foundation area")
	_expect(YokaiManager.get_stage(&"kappa") == &"UNKNOWN", "Runtime reset should clear yokai state")
	_expect(InventoryManager.has(&"bug_net"), "Runtime reset should restore the starting bug net")
	_expect(not InventoryManager.has(&"cucumber"), "Runtime reset should clear extra items")
	_expect(InventoryManager.get_money() == 0, "Runtime reset should restore 0 yen")
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
	missing_optional.erase("weather")
	missing_optional.erase("inventory")
	_expect(SaveManager.deserialize(missing_optional), "Missing optional fields should be tolerated")
	_expect(WeatherManager.get_weather() == &"sunny", "Missing weather should restore sunny")
	_expect(InventoryManager.has(&"bug_net"), "Missing inventory should restore the starting bug net")
	_expect(InventoryManager.get_money() == 0, "Missing inventory should restore 0 yen")
	var unknown_location := valid_data.duplicate(true)
	unknown_location["player"]["scene_id"] = "unknown_location"
	_expect(not SaveManager.deserialize(unknown_location), "Unknown save location IDs should be rejected")


func _test_save_round_trip() -> void:
	var save_player := PlayerController.new()
	add_child(save_player)
	CalendarManager.debug_set_day(7)
	GameClock.debug_set_time(18, 45)
	WeatherManager.debug_set_weather(&"rain")
	WorldState.set_flag(&"save_round_trip_flag")
	YokaiManager.set_stage(&"kappa", &"SEEN", true)
	EventManager.deserialize_history(["save_round_trip_event"])
	DiaryManager.reset_state()
	DiaryManager.record_insect(&"aburazemi")
	InventoryManager.reset_state()
	InventoryManager.add(&"cucumber", 2)
	InventoryManager.set_money(300)
	save_player.set_facing(&"up_left")
	_expect(SaveManager.save_game(TEST_SAVE_PATH), "Save should write a valid file")
	CalendarManager.debug_set_day(1)
	GameClock.debug_set_time(7, 0)
	WeatherManager.reset_state()
	WorldState.reset_state()
	YokaiManager.reset_state()
	EventManager.deserialize_history([])
	DiaryManager.reset_state()
	InventoryManager.reset_state()
	_expect(SaveManager.load_game(TEST_SAVE_PATH), "Load should read a valid file")
	_expect(CalendarManager.day_index == 7, "Save round trip should preserve day")
	_expect(GameClock.time_minutes == 1125, "Save round trip should preserve time")
	_expect(WeatherManager.get_weather() == &"rain", "Save round trip should preserve weather")
	_expect(DiaryManager.get_or_create_record(7).weather == &"rain", "Save round trip should preserve DayRecord weather")
	_expect(WorldState.has_flag(&"save_round_trip_flag"), "Save round trip should preserve world flags")
	_expect(YokaiManager.get_stage(&"kappa") == &"SEEN", "Save round trip should preserve yokai stage")
	_expect(EventManager.has_seen(&"save_round_trip_event"), "Save round trip should preserve event history")
	_expect(DiaryManager.get_or_create_record(7).caught_insects.has(&"aburazemi"), "Save round trip should preserve DayRecord")
	_expect(save_player.facing == &"up_left", "Save round trip should preserve player facing")
	_expect(InventoryManager.count(&"cucumber") == 2, "Save round trip should preserve cucumber count")
	_expect(InventoryManager.has(&"bug_net"), "Save round trip should preserve the starting bug net")
	_expect(InventoryManager.get_money() == 300, "Save round trip should preserve money")
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
