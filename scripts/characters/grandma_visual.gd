class_name GrandmaVisual
extends Node3D

const DIALOGUE_ID: StringName = &"grandma_morning"

@export_range(0.0, 0.5, 0.01) var gesture_strength := 0.2

var is_talking := false
var _head: Node3D
var _left_arm: Node3D
var _right_arm: Node3D
var _base_position := Vector3.ZERO
var _animation_time := 0.0


func _ready() -> void:
	_head = find_child("Head", true, false) as Node3D
	_left_arm = find_child("LeftArm", true, false) as Node3D
	_right_arm = find_child("RightArm", true, false) as Node3D
	_base_position = position
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _process(delta: float) -> void:
	_animation_time += delta
	var talking_weight := 1.0 if is_talking else 0.0
	var smoothing := 1.0 - exp(-8.0 * delta)
	var gesture := sin(_animation_time * 4.2) * gesture_strength * talking_weight
	_left_arm.rotation.x = lerp_angle(_left_arm.rotation.x, gesture * 0.45, smoothing)
	_right_arm.rotation.x = lerp_angle(_right_arm.rotation.x, -0.22 * talking_weight + gesture, smoothing)
	_head.rotation.y = lerp_angle(_head.rotation.y, sin(_animation_time * 2.1) * 0.08 * talking_weight, smoothing)
	position.y = _base_position.y + sin(_animation_time * 1.4) * 0.006


func _on_dialogue_started(sequence: DialogueSequence) -> void:
	is_talking = sequence.dialogue_id == DIALOGUE_ID


func _on_dialogue_ended(sequence: DialogueSequence) -> void:
	if sequence.dialogue_id == DIALOGUE_ID:
		is_talking = false
