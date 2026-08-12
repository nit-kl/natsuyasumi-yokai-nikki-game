class_name DialogueResource
extends Resource

@export var dialogue_id: StringName
@export var lines: Array[DialogueLine] = []


func is_valid_dialogue() -> bool:
	if dialogue_id.is_empty() or lines.is_empty():
		return false
	for line in lines:
		if line == null or not line.is_valid():
			return false
	return true
