class_name YokaiData
extends Resource

@export var yokai_id: StringName
@export var display_name: String = ""


func is_valid_yokai() -> bool:
	return not yokai_id.is_empty() and not display_name.strip_edges().is_empty()
