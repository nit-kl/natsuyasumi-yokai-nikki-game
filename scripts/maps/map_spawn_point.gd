class_name MapSpawnPoint
extends Marker2D

@export var spawn_id: StringName = &"default"
@export var facing: StringName = &"down"


func _ready() -> void:
	add_to_group("map_spawn_points")
