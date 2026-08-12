class_name EventDefinition
extends Resource

@export var event_id: StringName
@export var priority: int = 0
@export var condition: EventCondition
@export var actions: Array[EventAction] = []
@export var one_shot: bool = true
@export var exclusive_group: StringName


func is_valid_event() -> bool:
	return not event_id.is_empty() and condition != null
