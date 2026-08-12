class_name PlaytestPreset
extends Resource

@export var preset_id: StringName
@export var display_name: String = ""
@export_range(1, 30, 1) var day_index: int = 1
@export_range(0, 1439, 1) var time_minutes: int = 420
@export var area_id: StringName = &"foundation_test"
@export var player_position := Vector2(320, 180)
@export var player_facing: StringName = &"down"
@export var world_flags: Array[StringName] = []
@export var kappa_stage: StringName = &"UNKNOWN"
@export var event_history: Array[StringName] = []


func is_valid_preset() -> bool:
	return not preset_id.is_empty() and not display_name.strip_edges().is_empty()
