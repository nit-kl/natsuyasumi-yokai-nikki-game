class_name KappaGlimpse
extends Node3D

signal glimpse_started
signal glimpse_finished
signal clue_stage_changed(stage: StringName)
signal dive_splash_emitted

@export var event_id: StringName = &"kappa_first_glimpse"
@export_range(0.1, 10.0, 0.1) var visible_duration := 2.0
@export_range(0.1, 3.0, 0.05) var stillness_duration := 0.55
@export_range(0.1, 3.0, 0.05) var ripple_duration := 0.70
@export_range(0.1, 3.0, 0.05) var reflection_duration := 0.60
@export var approach_trigger_path: NodePath = NodePath("../KappaEventTrigger")

@onready var visual_root: Node3D = %VisualRoot
@onready var kappa_model: Node3D = %KappaModel
@onready var ripple: GeometryInstance3D = %Ripple
@onready var green_reflection: GeometryInstance3D = %GreenReflection
@onready var dive_splash: GPUParticles3D = %DiveSplash

var is_showing := false
var is_foreshadowing := false
var _rest_position := Vector3.ZERO
var _animation_tween: Tween


func _ready() -> void:
	_rest_position = visual_root.position
	visual_root.visible = false
	ripple.visible = false
	green_reflection.visible = false
	dive_splash.emitting = false
	EventManager.event_triggered.connect(_on_event_triggered)
	var trigger := get_node_or_null(approach_trigger_path) as EventTrigger
	if trigger != null:
		trigger.event_approached.connect(_on_event_approached)


func _on_event_approached(event: EventDefinition) -> void:
	if event.event_id != event_id or is_showing or is_foreshadowing:
		return
	_play_foreshadowing()


func _on_event_triggered(event: EventDefinition) -> void:
	if event.event_id != event_id or is_showing:
		return
	_show_glimpse()


func _show_glimpse() -> void:
	var should_restore_ambience := is_foreshadowing
	is_showing = true
	is_foreshadowing = false
	visual_root.position = _rest_position + Vector3(0.0, -0.72, 0.0)
	visual_root.rotation_degrees.y = -10.0
	visual_root.visible = true
	kappa_model.visible = true
	green_reflection.visible = false
	ripple.visible = true
	ripple.scale = Vector3(0.25, 0.25, 0.25)
	var ripple_tween := create_tween()
	ripple_tween.tween_property(ripple, "scale", Vector3(2.2, 1.0, 2.2), visible_duration)
	var rise_duration := minf(0.38, visible_duration * 0.28)
	var sink_duration := minf(0.48, visible_duration * 0.32)
	var look_duration := maxf(visible_duration - rise_duration - sink_duration, 0.1)
	_animation_tween = create_tween()
	_animation_tween.tween_property(visual_root, "position", _rest_position, rise_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_animation_tween.tween_property(visual_root, "rotation_degrees:y", 8.0, minf(0.28, look_duration)).set_trans(Tween.TRANS_SINE)
	_animation_tween.tween_interval(maxf(look_duration - 0.28, 0.0))
	_animation_tween.tween_callback(_emit_dive_splash)
	_animation_tween.tween_property(visual_root, "position", _rest_position + Vector3(0.0, -1.05, 0.0), sink_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	glimpse_started.emit()
	await _animation_tween.finished
	if not is_instance_valid(visual_root):
		return
	visual_root.visible = false
	visual_root.position = _rest_position
	is_showing = false
	if should_restore_ambience:
		AudioManager.set_ambience_ducked(false, 0.8)
	glimpse_finished.emit()


func _emit_dive_splash() -> void:
	dive_splash.emitting = true
	dive_splash.restart()
	AudioManager.play_cue(&"kappa_splash", -2.0)
	dive_splash_emitted.emit()


func _play_foreshadowing() -> void:
	is_foreshadowing = true
	AudioManager.set_ambience_ducked(true, 0.18)
	visual_root.position = _rest_position
	visual_root.visible = true
	kappa_model.visible = false
	ripple.visible = false
	green_reflection.visible = false
	clue_stage_changed.emit(&"stillness")
	await get_tree().create_timer(stillness_duration).timeout
	if not is_foreshadowing:
		return
	ripple.visible = true
	ripple.scale = Vector3(0.12, 0.12, 0.12)
	AudioManager.play_cue(&"kappa_ripple", -6.0)
	clue_stage_changed.emit(&"ripple")
	var ripple_tween := create_tween()
	ripple_tween.tween_property(ripple, "scale", Vector3(1.45, 1.0, 1.45), ripple_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(ripple_duration).timeout
	if not is_foreshadowing:
		return
	green_reflection.visible = true
	green_reflection.scale = Vector3(0.45, 1.0, 0.45)
	green_reflection.transparency = 0.72
	clue_stage_changed.emit(&"reflection")
	var reflection_tween := create_tween().set_parallel(true)
	reflection_tween.tween_property(green_reflection, "scale", Vector3(1.35, 1.0, 1.35), reflection_duration).set_trans(Tween.TRANS_SINE)
	reflection_tween.tween_property(green_reflection, "transparency", 0.18, reflection_duration)
	await get_tree().create_timer(reflection_duration + 0.35).timeout
	if is_foreshadowing:
		is_foreshadowing = false
		visual_root.visible = false
		AudioManager.set_ambience_ducked(false, 0.5)


func _exit_tree() -> void:
	if is_foreshadowing or is_showing:
		AudioManager.set_ambience_ducked(false, 0.1)
