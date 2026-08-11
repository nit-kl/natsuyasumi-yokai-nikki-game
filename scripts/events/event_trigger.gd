class_name EventTrigger
extends Area3D

@export var event_definition: EventDefinition


func _ready() -> void:
	if event_definition == null:
		push_warning("EventTrigger requires an EventDefinition.")
		return
	EventManager.register_event(event_definition)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body is ThirdPersonController or event_definition == null:
		return
	var did_trigger := EventManager.try_trigger(
		event_definition,
		event_definition.location_id,
		GameClock.current_minutes
	)
	if did_trigger and event_definition.one_shot:
		set_deferred("monitoring", false)

