class_name InsectData
extends Resource

@export var insect_id: StringName
@export var display_name := ""
@export_multiline var description := ""


func is_valid() -> bool:
	return not insect_id.is_empty() and not display_name.is_empty()

