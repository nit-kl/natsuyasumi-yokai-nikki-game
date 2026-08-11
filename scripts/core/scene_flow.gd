extends Node

signal transition_failed(message: String)

const TITLE_SCENE := "res://scenes/bootstrap/title.tscn"
const GAMEPLAY_SCENE := "res://scenes/bootstrap/main.tscn"

enum EntryMode {
	NONE,
	NEW_GAME,
	CONTINUE,
}

var pending_entry := EntryMode.NONE
var last_error := ""


func start_new_game() -> Error:
	last_error = ""
	_reset_runtime_state()
	pending_entry = EntryMode.NEW_GAME
	return _change_scene(GAMEPLAY_SCENE)


func continue_game() -> Error:
	last_error = ""
	if not SaveManager.has_save_game():
		return _fail("セーブデータが見つかりません。")
	pending_entry = EntryMode.CONTINUE
	return _change_scene(GAMEPLAY_SCENE)


func return_to_title() -> Error:
	pending_entry = EntryMode.NONE
	return _change_scene(TITLE_SCENE)


func complete_gameplay_entry() -> void:
	var entry_mode := pending_entry
	pending_entry = EntryMode.NONE
	if entry_mode != EntryMode.CONTINUE:
		return
	if SaveManager.load_game():
		return
	_fail(SaveManager.last_error)
	call_deferred("return_to_title")


func _reset_runtime_state() -> void:
	if DialogueManager.is_active:
		DialogueManager.finish_dialogue()
	GameState.start_new_game()
	BugCatchingManager.reset_collection()
	EventManager.reset_history()
	DayRecordManager.reset_records()
	DiaryManager.reset_entries()
	GameClock.set_time(7, 0)
	GameClock.set_time_scale(1.0)
	GameClock.set_paused(false)


func _change_scene(path: String) -> Error:
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		pending_entry = EntryMode.NONE
		return _fail("シーンを開けませんでした: %s" % path)
	return OK


func _fail(message: String) -> Error:
	last_error = message
	transition_failed.emit(message)
	push_error(message)
	return ERR_CANT_OPEN
