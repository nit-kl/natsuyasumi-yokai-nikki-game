extends Node

const KAPPA_EVENT: EventDefinition = preload("res://resources/events/kappa_first_glimpse.tres")
const ABURA_ZEMI: InsectData = preload("res://resources/insects/abura_zemi.tres")


func _ready() -> void:
	GameState.start_new_game()
	EventManager.reset_history()
	BugCatchingManager.reset_collection()
	DayRecordManager.reset_records()
	GameClock.set_paused(false)
	GameClock.set_time(7, 0)
	GameState.set_progress_phase(GameState.ProgressPhase.FREE_ROAM)
	GameState.set_current_area(&"river")

	assert(BugCatchingManager.catch_insect(ABURA_ZEMI))
	assert(EventManager.try_trigger(KAPPA_EVENT, &"river", GameClock.current_minutes))
	assert(GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME)
	assert(GameClock.current_minutes == GameClock.evening_start_minutes)
	assert(not DayFlowManager.can_complete_day())

	GameState.set_current_area(&"grandma_house")
	assert(DayFlowManager.can_complete_day())
	var record := DayFlowManager.complete_day()
	assert(record != null)
	assert(record.day == 1)
	assert(record.end_minutes == GameClock.evening_start_minutes)
	assert(record.get_total_insects() == 1)
	assert(record.triggered_events.has(&"kappa_first_glimpse"))
	assert(GameState.progress_phase == GameState.ProgressPhase.DAY_SUMMARY)
	assert(DayFlowManager.is_summary_active)
	assert(GameClock.clock_paused)

	var save_data := DayRecordManager.to_save_data()
	DayRecordManager.reset_records()
	DayRecordManager.restore_from_save_data(save_data)
	assert(DayRecordManager.get_latest_record().get_total_insects() == 1)

	DayFlowManager.dismiss_day_summary()
	assert(not DayFlowManager.is_summary_active)
	assert(GameState.progress_phase == GameState.ProgressPhase.DIARY)
	assert(DiaryManager.is_editing)
	assert(DiaryManager.draft_record == DayRecordManager.get_latest_record())

	print("Day flow smoke test passed.")
	get_tree().quit(0)
