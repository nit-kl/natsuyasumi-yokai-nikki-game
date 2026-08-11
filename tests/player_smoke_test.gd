extends Node

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func _ready() -> void:
	var player := PLAYER_SCENE.instantiate() as ThirdPersonController
	assert(player != null)
	add_child(player)

	assert(player.has_node("CollisionShape3D"))
	assert(player.has_node("CameraPivot/SpringArm3D/Camera3D"))
	assert(player.has_node("InteractionDetector"))
	assert(InputMap.has_action("move_forward"))
	assert(InputMap.has_action("jump"))
	assert(InputMap.has_action("interact"))

	var interactor := player.get_node("InteractionDetector") as PlayerInteractor
	assert(interactor != null)
	assert(interactor.collision_mask == 2)

	var camera_pivot := player.get_node("CameraPivot") as ThirdPersonCamera
	assert(camera_pivot.top_level)
	var camera_basis_before_turn := camera_pivot.global_basis
	player.rotate_y(PI / 2.0)
	assert(camera_pivot.global_basis.is_equal_approx(camera_basis_before_turn))

	var forward := player.get_camera_relative_direction(Vector2(0.0, -1.0))
	assert(forward.is_normalized())
	assert(forward.z < -0.9)

	print("Player smoke test passed.")
	get_tree().quit(0)
