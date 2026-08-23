class_name PlaytestDebugController
extends Node

signal preset_applied(preset_id: StringName)
signal runtime_reset()

const DEFAULT_DAY := 1
const DEFAULT_TIME_MINUTES := 420
const DEFAULT_AREA: StringName = &"foundation_test"
const DEFAULT_POSITION := Vector2(320, 180)

@export var presets: Array[PlaytestPreset] = []
@export var teleport_points: Dictionary = {
	&"home": Vector2(280, 180),
	&"insect": Vector2(320, 132),
	&"kappa": Vector2(400, 240),
}


func _ready() -> void:
	add_to_group("playtest_debug_controller")


func get_preset(preset_id: StringName) -> PlaytestPreset:
	for preset in presets:
		if preset != null and preset.preset_id == preset_id:
			return preset
	return null


func apply_preset(preset_id: StringName) -> bool:
	var preset := get_preset(preset_id)
	if preset == null or not preset.is_valid_preset():
		return false
	reset_runtime_state(false)
	CalendarManager.debug_set_day(preset.day_index)
	GameClock.set_time_minutes(preset.time_minutes)
	GameState.set_area(preset.area_id)
	for flag_id in preset.world_flags:
		WorldState.set_flag(flag_id)
	YokaiManager.set_stage(&"kappa", preset.kappa_stage, true)
	EventManager.deserialize_history(Array(preset.event_history))
	_set_player_transform(preset.player_position, preset.player_facing)
	preset_applied.emit(preset.preset_id)
	return true


func teleport(point_id: StringName, area_id: StringName = &"") -> bool:
	if not teleport_points.has(point_id) or not is_instance_valid(GameState.player):
		return false
	GameState.player.global_position = Vector2(teleport_points[point_id]).round()
	if not area_id.is_empty():
		GameState.set_area(area_id)
	return true


func reset_runtime_state(emit_signal: bool = true) -> void:
	CalendarManager.debug_set_day(DEFAULT_DAY)
	GameClock.set_time_minutes(DEFAULT_TIME_MINUTES)
	GameState.set_area(DEFAULT_AREA)
	WorldState.reset_state()
	YokaiManager.reset_state()
	EventManager.deserialize_history([])
	DiaryManager.reset_state()
	WeatherManager.reset_state()
	InventoryManager.reset_state()
	_set_player_transform(DEFAULT_POSITION, &"down")
	if emit_signal:
		runtime_reset.emit()


func get_snapshot() -> Dictionary:
	var player_position := Vector2.ZERO
	var player_facing: StringName = &"down"
	if is_instance_valid(GameState.player):
		player_position = GameState.player.global_position
		player_facing = StringName(GameState.player.get("facing"))
	return {
		"day": CalendarManager.day_index,
		"time": GameClock.get_time_text(),
		"weather": WeatherManager.get_weather(),
		"area": GameState.current_area_id,
		"position": player_position,
		"facing": player_facing,
		"kappa_stage": YokaiManager.get_stage(&"kappa"),
		"money": InventoryManager.get_money(),
		"items": InventoryManager.serialize().get("items", {}),
		"flags": WorldState.serialize().get("flags", []),
		"event_history": EventManager.serialize_history(),
		"save_exists": SaveManager.save_exists(),
	}


func get_snapshot_text() -> String:
	var snapshot := get_snapshot()
	return "Day %d  %s  %s\nArea: %s  Pos: %s\nFacing: %s  Kappa: %s\nMoney: %s  Items: %s\nFlags: %s\nEvents: %s\nSave file: %s" % [
		snapshot.day,
		snapshot.time,
		snapshot.weather,
		snapshot.area,
		snapshot.position,
		snapshot.facing,
		snapshot.kappa_stage,
		snapshot.money,
		JSON.stringify(snapshot.items),
		_json_array_text(snapshot.flags),
		_json_array_text(snapshot.event_history),
		"yes" if snapshot.save_exists else "no",
	]


func _set_player_transform(position: Vector2, facing: StringName) -> void:
	if not is_instance_valid(GameState.player):
		return
	GameState.player.global_position = position.round()
	if GameState.player.has_method("set_facing"):
		GameState.player.set_facing(facing)


static func _json_array_text(values: Variant) -> String:
	return JSON.stringify(values) if values is Array else "[]"
