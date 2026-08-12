class_name InsectData
extends Resource

@export var insect_id: StringName
@export var display_name: String = ""
@export_range(0.0, 200.0, 1.0) var move_speed: float = 24.0
@export_range(0.0, 10.0, 0.1) var direction_change_seconds: float = 2.5


func is_valid_insect() -> bool:
	return not insect_id.is_empty() and not display_name.strip_edges().is_empty()
