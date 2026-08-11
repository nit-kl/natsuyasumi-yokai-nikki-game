class_name DialogueSequence
extends Resource

@export var dialogue_id: StringName
@export var lines: Array[DialogueLine] = []


func is_valid() -> bool:
	return not dialogue_id.is_empty() and not lines.is_empty()

