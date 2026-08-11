extends Node

const STUDY_SCENE := preload("res://scenes/visual_direction/diorama_composition_study.tscn")


func _ready() -> void:
	var study := STUDY_SCENE.instantiate()
	add_child(study)
	assert(study.has_node("Ground"))
	assert(study.has_node("Path"))
	assert(study.has_node("IrrigationChannel"))
	assert(study.has_node("GrandmaHouse"))
	var house := study.get_node("GrandmaHouse") as Node3D
	assert(house.find_child("RoofRidge", true, false) != null)
	assert(house.find_child("PorchLanternBody", true, false) != null)
	assert(study.has_node("YardProps"))
	var yard := study.get_node("YardProps") as Node3D
	assert(yard.find_child("GardenSoil1", true, false) != null)
	assert(yard.find_child("HydrangeaBloom1", true, false) != null)
	assert(study.has_node("Grandma"))
	var grandma := study.get_node("Grandma") as Node3D
	assert(grandma.find_child("HairBun", true, false) != null)
	assert(grandma.find_child("WaistSash", true, false) != null)
	assert(study.has_node("ForegroundTree"))
	assert(study.has_node("Player"))
	var player := study.get_node("Player") as ThirdPersonController
	var camera_pivot := player.get_node("CameraPivot") as DioramaCamera
	var camera := player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	assert(camera_pivot.top_level)
	assert(camera.projection == Camera3D.PROJECTION_ORTHOGONAL)
	assert(is_equal_approx(camera.size, 12.5))
	assert(camera_pivot.pitch_degrees <= -45.0)
	print("Diorama composition smoke test passed.")
	get_tree().quit(0)
