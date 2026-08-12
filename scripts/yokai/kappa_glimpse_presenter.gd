class_name KappaGlimpsePresenter
extends Node2D

@export var trace_event_id: StringName = &"kappa_first_trace"
@export var sighting_event_id: StringName = &"kappa_first_sighting"
@export_range(0.1, 5.0, 0.1) var glimpse_seconds: float = 1.2

@onready var ripple: Node2D = %Ripple
@onready var silhouette: Node2D = %Silhouette


func _ready() -> void:
	EventManager.event_started.connect(_on_event_started)
	ripple.visible = false
	silhouette.visible = false


func _on_event_started(event: EventDefinition) -> void:
	if event.event_id == trace_event_id:
		present_trace()
	elif event.event_id == sighting_event_id:
		present_sighting()


func present_trace() -> void:
	ripple.visible = true
	var tween := create_tween()
	tween.tween_interval(glimpse_seconds)
	tween.tween_callback(func() -> void: ripple.visible = false)


func present_sighting() -> void:
	ripple.visible = true
	silhouette.visible = true
	var tween := create_tween()
	tween.tween_interval(glimpse_seconds)
	tween.tween_callback(_hide_glimpse)


func _hide_glimpse() -> void:
	ripple.visible = false
	silhouette.visible = false
