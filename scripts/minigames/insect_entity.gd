class_name InsectEntity
extends Interactable

signal caught(insect: InsectData)

@export var insect_data: InsectData
@export_range(0.0, 1.0, 0.01) var hover_amplitude := 0.12
@export_range(0.0, 10.0, 0.1) var hover_speed := 2.4
@export_range(0.0, 10.0, 0.1) var rotation_speed := 1.2
@export_range(0.0, 30.0, 0.5) var wing_flutter_degrees := 10.0
@export_range(0.0, 40.0, 0.5) var wing_flutter_speed := 22.0

@onready var visual_root: Node3D = %VisualRoot
@onready var catch_burst: GPUParticles3D = %CatchBurst

var left_wing: Node3D
var right_wing: Node3D

var is_caught := false
var _elapsed := 0.0
var _base_height := 0.0
var _left_wing_rest_rotation := Vector3.ZERO
var _right_wing_rest_rotation := Vector3.ZERO


func _ready() -> void:
	_base_height = position.y
	if insect_data != null:
		interaction_text = "%sをつかまえる" % insect_data.display_name
	catch_burst.emitting = false
	left_wing = visual_root.find_child("LeftWing", true, false) as Node3D
	right_wing = visual_root.find_child("RightWing", true, false) as Node3D
	if left_wing != null:
		_left_wing_rest_rotation = left_wing.rotation
	if right_wing != null:
		_right_wing_rest_rotation = right_wing.rotation


func _process(delta: float) -> void:
	if is_caught:
		return
	_elapsed += delta
	position.y = _base_height + sin(_elapsed * hover_speed) * hover_amplitude
	rotate_y(rotation_speed * delta)
	var flutter := deg_to_rad(sin(_elapsed * wing_flutter_speed) * wing_flutter_degrees)
	if left_wing != null:
		left_wing.rotation = _left_wing_rest_rotation + Vector3(0.0, 0.0, flutter)
	if right_wing != null:
		right_wing.rotation = _right_wing_rest_rotation + Vector3(0.0, 0.0, -flutter)


func can_interact(interactor: Node) -> bool:
	return (
		not is_caught
		and insect_data != null
		and insect_data.is_valid()
		and super.can_interact(interactor)
	)


func interact(interactor: Node) -> void:
	if not can_interact(interactor):
		return
	super.interact(interactor)
	if not BugCatchingManager.catch_insect(insect_data):
		return
	is_caught = true
	interaction_enabled = false
	collision_layer = 0
	visual_root.visible = false
	catch_burst.emitting = true
	catch_burst.restart()
	caught.emit(insect_data)
