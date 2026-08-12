class_name NPCData
extends Resource

@export var npc_id: StringName
@export var display_name: String = ""
@export var default_facing: StringName = &"down"
@export var default_dialogue: DialogueResource


func is_valid_npc() -> bool:
	return not npc_id.is_empty() and not display_name.strip_edges().is_empty()
