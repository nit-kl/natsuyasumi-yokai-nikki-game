class_name ForegroundOccluder2D
extends Polygon2D

@export var occlusion_y: float

var depth_z_index := 0


func _ready() -> void:
	refresh()


func refresh() -> void:
	depth_z_index = roundi(global_position.y + occlusion_y)
	z_index = depth_z_index
