class_name EventTriggerArea
extends Area2D

signal event_triggered(event_id: StringName)

@export var event_id: StringName

var _completed := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func try_trigger(actor: Node) -> bool:
	if _completed or event_id.is_empty() or actor != GameState.player:
		return false
	if not EventManager.trigger_event(event_id):
		return false
	_completed = true
	monitoring = false
	event_triggered.emit(event_id)
	return true


func _on_body_entered(body: Node) -> void:
	try_trigger(body)
