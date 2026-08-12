extends Node

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
	CalendarManager.debug_set_day(7)
	GameClock.debug_set_time(18, 45)
	_expect(SaveManager.save_game(TEST_SAVE_PATH), "Save should write a valid file")
	CalendarManager.debug_set_day(1)
	GameClock.debug_set_time(7, 0)
	_expect(SaveManager.load_game(TEST_SAVE_PATH), "Load should read a valid file")
	_expect(CalendarManager.day_index == 7, "Save round trip should preserve day")
	_expect(GameClock.time_minutes == 1125, "Save round trip should preserve time")


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
