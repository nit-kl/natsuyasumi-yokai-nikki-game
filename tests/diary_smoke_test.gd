extends Node


func _ready() -> void:
	GameState.start_new_game()
	DiaryManager.reset_entries()

	var record := DayRecord.new()
	record.day = 1
	record.end_minutes = 16 * 60 + 30
	record.end_area = &"grandma_house"
	record.caught_insects = {"abura_zemi": 2}
	record.triggered_events = [&"kappa_first_glimpse"]

	assert(DiaryManager.begin_entry(record))
	assert(DiaryManager.is_editing)
	assert(DiaryManager.draft_options.size() == 3)
	assert(DiaryManager.draft_options[0]["id"] == &"walk_to_river")
	assert(DiaryManager.draft_options[1]["id"] == &"caught_insects")
	assert(DiaryManager.draft_options[2]["id"] == &"kappa_glimpse")

	var entry := DiaryManager.save_draft([0, 2])
	assert(entry != null and entry.is_valid())
	assert(entry.title == "川で見た影")
	assert(entry.memory_ids.has(&"walk_to_river"))
	assert(entry.memory_ids.has(&"kappa_glimpse"))
	assert(not entry.memory_ids.has(&"caught_insects"))
	assert(entry.body.contains("河童"))
	assert(not DiaryManager.is_editing)
	assert(GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE)

	var save_data := DiaryManager.to_save_data()
	DiaryManager.reset_entries()
	DiaryManager.restore_from_save_data(save_data)
	assert(DiaryManager.get_latest_entry().body == entry.body)

	print("Diary smoke test passed.")
	get_tree().quit(0)

