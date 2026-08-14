class_name KappaGlimpsePresenter
extends Node2D

@export var trace_event_id: StringName = &"kappa_first_trace"
@export var sighting_event_id: StringName = &"kappa_first_sighting"
@export_range(0.1, 5.0, 0.1) var glimpse_seconds: float = 1.2

@onready var ripple: AnimatedSprite2D = %Ripple
@onready var kappa_surface: AnimatedSprite2D = %KappaSurface
@onready var ripple_audio: AudioStreamPlayer2D = %RippleAudio
@onready var kappa_cue_audio: AudioStreamPlayer2D = %KappaCueAudio


func _ready() -> void:
	EventManager.event_started.connect(_on_event_started)
	ripple.visible = false
	kappa_surface.visible = false


func _exit_tree() -> void:
	if is_instance_valid(ripple_audio):
		ripple_audio.stop()
		ripple_audio.stream = null
	if is_instance_valid(kappa_cue_audio):
		kappa_cue_audio.stop()
		kappa_cue_audio.stream = null


func _on_event_started(event: EventDefinition) -> void:
	if event.event_id == trace_event_id:
		present_trace()
	elif event.event_id == sighting_event_id:
		present_sighting()


func present_trace() -> void:
	ripple_audio.play()
	ripple.frame = 0
	ripple.play(&"ripple")
	ripple.visible = true
	var tween := create_tween()
	tween.tween_interval(glimpse_seconds)
	tween.tween_callback(func() -> void: ripple.visible = false)


func present_sighting() -> void:
	ripple_audio.play()
	kappa_cue_audio.play()
	ripple.frame = 0
	ripple.play(&"ripple")
	ripple.visible = true
	kappa_surface.frame = 0
	kappa_surface.play(&"surface")
	kappa_surface.visible = true
	var tween := create_tween()
	tween.tween_interval(glimpse_seconds)
	tween.tween_callback(_hide_glimpse)


func _hide_glimpse() -> void:
	ripple.visible = false
	kappa_surface.visible = false
