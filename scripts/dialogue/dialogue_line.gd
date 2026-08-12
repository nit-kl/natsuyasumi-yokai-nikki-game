class_name DialogueLine
extends Resource

@export var speaker: String = ""
@export_multiline var text: String = ""
@export var choices: Array[DialogueChoice] = []


func has_choices() -> bool:
	return not choices.is_empty()


func is_valid() -> bool:
	return not text.strip_edges().is_empty()
