class_name KappaGlimpse
extends Node3D

signal glimpse_started
signal glimpse_finished

@export var event_id: StringName = &"kappa_first_glimpse"
@export_range(0.1, 10.0, 0.1) var visible_duration := 2.0

@onready var visual_root: Node3D = %VisualRoot

var is_showing := false


func _ready() -> void:
	visual_root.visible = false
	EventManager.event_triggered.connect(_on_event_triggered)


func _on_event_triggered(event: EventDefinition) -> void:
	if event.event_id != event_id or is_showing:
		return
	_show_glimpse()


func _show_glimpse() -> void:
	is_showing = true
	visual_root.visible = true
	glimpse_started.emit()
	await get_tree().create_timer(visible_duration).timeout
	if not is_instance_valid(visual_root):
		return
	visual_root.visible = false
	is_showing = false
	glimpse_finished.emit()

