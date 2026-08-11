extends Node

const TEST_SAVE_PATH := "user://save_manager_smoke_test.json"
const ABURA_ZEMI: InsectData = preload("res://resources/insects/abura_zemi.tres")


func _ready() -> void:
	SaveManager.auto_save_enabled = false
	GameState.start_new_game()
	BugCatchingManager.reset_collection()
	EventManager.reset_history()
	DayRecordManager.reset_records()
	DiaryManager.reset_entries()

	GameState.set_current_day(3)
	GameState.set_current_area(&"river")
	GameState.set_progress_phase(GameState.ProgressPhase.FREE_ROAM)
	GameState.player_state = {
		"position": [1.25, 0.15, -8.5],
		"rotation_y": 0.4,
	}
	GameClock.set_time(12, 34)
	GameClock.set_time_scale(2.5)
	GameClock.set_paused(true)
	assert(BugCatchingManager.catch_insect(ABURA_ZEMI))
	EventManager.restore_from_save_data({"kappa_first_glimpse": 1})

	var record := DayRecordManager.create_current_day_record()
	assert(DiaryManager.begin_entry(record))
	assert(DiaryManager.save_draft([0, 1, 2]) != null)
	assert(GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE)
	assert(GameState.player_state["position"] == [1.25, 0.15, -8.5])
	assert(is_equal_approx(float(GameState.player_state["rotation_y"]), 0.4))
	assert(SaveManager.save_game(TEST_SAVE_PATH))

	GameState.start_new_game()
	BugCatchingManager.reset_collection()
	EventManager.reset_history()
	GameClock.set_time(7, 0)
	GameClock.set_time_scale(1.0)
	GameClock.set_paused(false)
	assert(SaveManager.load_game(TEST_SAVE_PATH))

	assert(GameState.current_day == 3)
	assert(GameState.current_area == &"river")
	assert(GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE)
	assert(GameState.player_state["position"] == [1.25, 0.15, -8.5])
	assert(is_equal_approx(float(GameState.player_state["rotation_y"]), 0.4))
	assert(GameClock.current_minutes == 12 * 60 + 34)
	assert(is_equal_approx(GameClock.time_scale, 2.5))
	assert(GameClock.clock_paused)
	assert(BugCatchingManager.get_caught_count(&"abura_zemi") == 1)
	assert(EventManager.has_triggered(&"kappa_first_glimpse"))
	assert(DayRecordManager.completed_records.size() == 1)
	assert(DiaryManager.entries.size() == 1)
	assert(DiaryManager.get_latest_entry().is_valid())

	var future_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	future_file.store_string(JSON.stringify({"save_version": SaveManager.CURRENT_SAVE_VERSION + 1}))
	future_file.close()
	assert(not SaveManager.load_game(TEST_SAVE_PATH))
	assert(SaveManager.last_error.contains("newer"))

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	SaveManager.auto_save_enabled = true
	print("Save manager smoke test passed.")
	get_tree().quit(0)
