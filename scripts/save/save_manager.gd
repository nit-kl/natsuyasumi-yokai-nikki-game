extends Node

signal save_completed(path: String)
signal load_completed(path: String)
signal save_failed(message: String)
signal load_failed(message: String)

const CURRENT_SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://save_01.json"

var auto_save_enabled := true
var last_error := ""
var _is_loading := false


func _ready() -> void:
	DiaryManager.entry_saved.connect(_on_diary_entry_saved)


func save_game(path: String = DEFAULT_SAVE_PATH) -> bool:
	last_error = ""
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _fail_save("Could not open save file: %s" % error_string(FileAccess.get_open_error()))
	file.store_string(JSON.stringify(_build_save_data(), "  "))
	file.close()
	save_completed.emit(path)
	return true


func load_game(path: String = DEFAULT_SAVE_PATH) -> bool:
	last_error = ""
	if not FileAccess.file_exists(path):
		return _fail_load("Save file does not exist: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail_load("Could not open save file: %s" % error_string(FileAccess.get_open_error()))
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return _fail_load("Save file is not a valid JSON object.")
	var data := parsed as Dictionary
	var save_version := int(data.get("save_version", 0))
	if save_version <= 0:
		return _fail_load("Save file has no valid version.")
	if save_version > CURRENT_SAVE_VERSION:
		return _fail_load("Save file version %d is newer than supported version %d." % [
			save_version,
			CURRENT_SAVE_VERSION,
		])
	_is_loading = true
	_restore_save_data(data)
	_is_loading = false
	load_completed.emit(path)
	return true


func _build_save_data() -> Dictionary:
	return {
		"save_version": CURRENT_SAVE_VERSION,
		"game_state": GameState.to_save_data(),
		"game_clock": {
			"current_minutes": GameClock.current_minutes,
			"time_scale": GameClock.time_scale,
			"paused": GameClock.clock_paused,
		},
		"bug_catching": BugCatchingManager.to_save_data(),
		"event_history": EventManager.to_save_data(),
		"day_records": DayRecordManager.to_save_data(),
		"diary_entries": DiaryManager.to_save_data(),
	}


func _restore_save_data(data: Dictionary) -> void:
	BugCatchingManager.restore_from_save_data(data.get("bug_catching", {}))
	EventManager.restore_from_save_data(data.get("event_history", {}))
	DayRecordManager.restore_from_save_data(data.get("day_records", []))
	DiaryManager.restore_from_save_data(data.get("diary_entries", []))
	GameState.restore_from_save_data(data.get("game_state", {}))

	var clock_data: Dictionary = data.get("game_clock", {})
	var minutes := clampi(
		int(clock_data.get("current_minutes", 7 * 60)),
		0,
		GameClock.MINUTES_PER_DAY - 1
	)
	GameClock.set_time(minutes / 60, minutes % 60)
	GameClock.set_time_scale(float(clock_data.get("time_scale", 1.0)))
	GameClock.set_paused(bool(clock_data.get("paused", false)))
	DayFlowManager.sync_after_load()
	DiaryManager.sync_after_load()


func _on_diary_entry_saved(_entry: DiaryEntry) -> void:
	if auto_save_enabled and not _is_loading:
		save_game()


func _fail_save(message: String) -> bool:
	last_error = message
	save_failed.emit(message)
	return false


func _fail_load(message: String) -> bool:
	last_error = message
	load_failed.emit(message)
	return false
