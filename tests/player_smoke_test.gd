extends Node

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func _ready() -> void:
	var player := PLAYER_SCENE.instantiate() as ThirdPersonController
	assert(player != null)
	add_child(player)

	assert(player.has_node("CollisionShape3D"))
	assert(player.has_node("VisualRoot/ProtagonistModel"))
	assert(player.has_node("CameraPivot/SpringArm3D/Camera3D"))
	assert(player.has_node("InteractionDetector"))
	assert(InputMap.has_action("move_forward"))
	assert(InputMap.has_action("jump"))
	assert(InputMap.has_action("interact"))

	var interactor := player.get_node("InteractionDetector") as PlayerInteractor
	assert(interactor != null)
	assert(interactor.collision_mask == 2)

	var camera_pivot := player.get_node("CameraPivot") as DioramaCamera
	var camera := player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	assert(camera_pivot.top_level)
	assert(camera.projection == Camera3D.PROJECTION_ORTHOGONAL)
	assert(is_equal_approx(camera.size, 12.5))
	var camera_basis_before_turn := camera_pivot.global_basis
	player.rotate_y(PI / 2.0)
	assert(camera_pivot.global_basis.is_equal_approx(camera_basis_before_turn))

	var forward := player.get_camera_relative_direction(Vector2(0.0, -1.0))
	assert(forward.is_normalized())
	assert(forward.z < -0.4)
	assert(absf(forward.x) > 0.4)

	player.global_position = Vector3(4.0, 1.25, -8.0)
	player.rotation.y = 0.75
	SaveManager.save_started.emit()
	player.global_position = Vector3.ZERO
	player.rotation.y = 0.0
	SaveManager.load_completed.emit("user://test.json")
	assert(player.global_position.is_equal_approx(Vector3(4.0, 1.25, -8.0)))
	assert(is_equal_approx(player.rotation.y, 0.75))
	assert(camera_pivot.global_basis.is_equal_approx(camera_basis_before_turn))

	GameState.player_state = {
		"position": [9999.0, 9999.0, 9999.0],
		"rotation_y": 0.0,
	}
	SaveManager.load_completed.emit("user://unsafe_position_test.json")
	assert(player.global_position.is_equal_approx(ThirdPersonController.FALLBACK_SPAWN_POSITION))

	var visual := player.get_node("VisualRoot") as ProtagonistVisual
	assert(visual.find_child("LeftArm", true, false) != null)
	assert(visual.find_child("RightLeg", true, false) != null)
	assert(visual.find_child("HatBrim", true, false) != null)
	assert(visual.find_child("Satchel", true, false) != null)
	player.velocity = Vector3(3.0, 0.0, 0.0)
	visual._process(0.1)
	var left_arm := visual.find_child("LeftArm", true, false) as Node3D
	assert(not is_zero_approx(left_arm.rotation.x))

	print("Player smoke test passed.")
	get_tree().quit(0)
