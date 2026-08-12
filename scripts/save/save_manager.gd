extends Node

signal save_completed(path: String)
signal load_completed(path: String)
signal operation_failed(message: String)

const SAVE_VERSION := 1
const SAVE_PATH := "user://save_01.json"

var last_error_message: String = ""


func save_exists(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)


func serialize() -> Dictionary:
	var player_position := Vector2.ZERO
	if is_instance_valid(GameState.player):
		player_position = GameState.player.global_position
	return {
		"save_version": SAVE_VERSION,
		"meta": {"play_time_seconds": 0, "last_saved_at": Time.get_datetime_string_from_system(true)},
		"calendar": {
			"day_index": CalendarManager.day_index,
			"time_minutes": GameClock.time_minutes,
		},
		"weather": "sunny",
		"player": {
			"scene_id": String(GameState.current_area_id),
			"position": [player_position.x, player_position.y],
			"facing": "down",
		},
		"inventory": {"items": {}, "money": 0},
		"world": {"flags": [], "discovered_locations": []},
		"npc_states": {},
		"yokai_states": {},
		"event_history": [],
		"diary": {"days": []},
		"settings_snapshot": {},
	}


func deserialize(data: Dictionary) -> bool:
	var validation_error := validate_data(data)
	if not validation_error.is_empty():
		_set_error(validation_error)
		return false
	var calendar_data: Dictionary = data["calendar"]
	CalendarManager.deserialize(calendar_data)
	GameClock.deserialize(calendar_data)
	var player_data: Dictionary = data.get("player", {})
	GameState.set_area(StringName(player_data.get("scene_id", GameState.DEFAULT_AREA)))
	var saved_position: Variant = player_data.get("position", [])
	if is_instance_valid(GameState.player) and saved_position is Array and saved_position.size() == 2:
		GameState.player.global_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	last_error_message = ""
	return true


func validate_data(data: Dictionary) -> String:
	if int(data.get("save_version", -1)) != SAVE_VERSION:
		return "Unsupported save version."
	if not data.has("calendar") or not data["calendar"] is Dictionary:
		return "Missing calendar data."
	var calendar_data: Dictionary = data["calendar"]
	if not calendar_data.has("day_index") or not calendar_data.has("time_minutes"):
		return "Missing required calendar fields."
	var day := int(calendar_data["day_index"])
	var minutes := int(calendar_data["time_minutes"])
	if day < CalendarManager.FIRST_DAY or day > CalendarManager.LAST_DAY:
		return "day_index is outside the supported range."
	if minutes < 0 or minutes >= GameClock.MINUTES_PER_DAY:
		return "time_minutes is outside the supported range."
	return ""


func save_game(path: String = SAVE_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_set_error("Could not open save file for writing (error %d)." % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(serialize(), "  "))
	file.close()
	last_error_message = ""
	save_completed.emit(path)
	return true


func load_game(path: String = SAVE_PATH) -> bool:
	if not save_exists(path):
		_set_error("Save file does not exist.")
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_set_error("Could not open save file for reading (error %d)." % FileAccess.get_open_error())
		return false
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not json.data is Dictionary:
		_set_error("Save data is not valid JSON object data.")
		return false
	if not deserialize(json.data):
		return false
	load_completed.emit(path)
	return true


func _set_error(message: String) -> void:
	last_error_message = message
	operation_failed.emit(message)
