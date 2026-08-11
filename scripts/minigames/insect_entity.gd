class_name InsectEntity
extends Interactable

signal caught(insect: InsectData)

@export var insect_data: InsectData
@export_range(0.0, 1.0, 0.01) var hover_amplitude := 0.12
@export_range(0.0, 10.0, 0.1) var hover_speed := 2.4
@export_range(0.0, 10.0, 0.1) var rotation_speed := 1.2

var is_caught := false
var _elapsed := 0.0
var _base_height := 0.0


func _ready() -> void:
	_base_height = position.y
	if insect_data != null:
		interaction_text = "Catch %s" % insect_data.display_name


func _process(delta: float) -> void:
	if is_caught:
		return
	_elapsed += delta
	position.y = _base_height + sin(_elapsed * hover_speed) * hover_amplitude
	rotate_y(rotation_speed * delta)


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
	visible = false
	caught.emit(insect_data)

