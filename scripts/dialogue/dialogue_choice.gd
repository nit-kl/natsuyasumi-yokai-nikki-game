class_name DialogueChoice
extends Resource

@export var text: String = ""
@export var next_line_index: int = -1


func is_valid() -> bool:
	return not text.strip_edges().is_empty()
