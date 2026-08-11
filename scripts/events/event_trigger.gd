class_name EventTrigger
extends Area3D

signal event_approached(event: EventDefinition)

@export var event_definition: EventDefinition
@export_range(0.0, 10.0, 0.1) var approach_delay_seconds := 0.0

var is_pending := false


func _ready() -> void:
	if event_definition == null:
		push_warning("EventTrigger requires an EventDefinition.")
		return
	EventManager.register_event(event_definition)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body is ThirdPersonController or event_definition == null or is_pending:
		return
	if not event_definition.matches(
		event_definition.location_id,
		GameClock.current_minutes,
		{}
	):
		return
	if event_definition.one_shot and EventManager.has_triggered(event_definition.event_id):
		return
	is_pending = true
	if event_definition.one_shot:
		set_deferred("monitoring", false)
	event_approached.emit(event_definition)
	if approach_delay_seconds > 0.0:
		await get_tree().create_timer(approach_delay_seconds).timeout
	var did_trigger := EventManager.try_trigger(
		event_definition,
		event_definition.location_id,
		GameClock.current_minutes,
		{}
	)
	is_pending = false
	if did_trigger:
		if event_definition.one_shot:
			set_deferred("monitoring", false)
		return
	set_deferred("monitoring", true)
