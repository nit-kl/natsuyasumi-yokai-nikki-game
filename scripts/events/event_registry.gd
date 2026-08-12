class_name EventRegistry
extends Node

@export var events: Array[EventDefinition] = []


func _ready() -> void:
	EventManager.register_events(events)


func _exit_tree() -> void:
	for event in events:
		if event != null:
			EventManager.unregister_event(event.event_id)
