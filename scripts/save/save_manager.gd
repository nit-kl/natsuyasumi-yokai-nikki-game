extends Node

const LocationCatalogData = preload("res://scripts/maps/location_catalog.gd")

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
	var player_facing := "down"
	if is_instance_valid(GameState.player):
		player_position = GameState.player.global_position
		player_facing = String(GameState.player.get("facing"))
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
			"facing": player_facing,
		},
		"inventory": {"items": {}, "money": 0},
		"world": WorldState.serialize(),
		"npc_states": {},
		"yokai_states": YokaiManager.serialize(),
		"event_history": EventManager.serialize_history(),
		"diary": DiaryManager.serialize(),
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
		if GameState.player.has_method("snap_to_walk_path"):
			GameState.player.snap_to_walk_path()
	if is_instance_valid(GameState.player) and GameState.player.has_method("set_facing"):
		GameState.player.set_facing(StringName(player_data.get("facing", "down")))
	WorldState.deserialize(data.get("world", {}))
	YokaiManager.deserialize(data.get("yokai_states", {}))
	var history: Variant = data.get("event_history", [])
	EventManager.deserialize_history(history if history is Array else [])
	DiaryManager.deserialize(data.get("diary", {}))
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
	var player_data: Variant = data.get("player", {})
	if player_data is Dictionary and player_data.has("scene_id"):
		var scene_id := StringName(player_data.get("scene_id", ""))
		if not LocationCatalogData.has_area(scene_id):
			return "player.scene_id is not a known location."
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
	var data := _read_save_data(path)
	if data.is_empty():
		return false
	if not deserialize(data):
		return false
	load_completed.emit(path)
	return true


func load_game_into_world(path: String = SAVE_PATH) -> bool:
	var data := _read_save_data(path)
	if data.is_empty():
		return false
	var validation_error := validate_data(data)
	if not validation_error.is_empty():
		_set_error(validation_error)
		return false
	var player_data: Dictionary = data.get("player", {})
	var target_area := StringName(player_data.get("scene_id", GameState.DEFAULT_AREA))
	var target_scene := LocationCatalogData.get_scene_path(target_area)
	if target_scene.is_empty():
		_set_error("Save data references an unknown scene_id: %s." % target_area)
		return false
	if target_area != GameState.current_area_id:
		var transition_error := await SceneTransitionManager.change_scene(target_scene)
		if transition_error != OK:
			_set_error("Could not restore saved location (error %d)." % transition_error)
			return false
		await get_tree().process_frame
	if not deserialize(data):
		return false
	load_completed.emit(path)
	return true


func _read_save_data(path: String) -> Dictionary:
	if not save_exists(path):
		_set_error("Save file does not exist.")
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_set_error("Could not open save file for reading (error %d)." % FileAccess.get_open_error())
		return {}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not json.data is Dictionary:
		_set_error("Save data is not valid JSON object data.")
		return {}
	return json.data


func _set_error(message: String) -> void:
	last_error_message = message
	operation_failed.emit(message)
