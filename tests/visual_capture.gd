extends Node3D

const WORLD_SCENE: PackedScene = preload("res://scenes/world/vertical_slice_graybox.tscn")
const CAPTURE_DIRECTORY := "res://.codex-captures"

var _camera: Camera3D


func _ready() -> void:
	GameClock.set_time(12, 30)
	GameClock.set_paused(true)
	var world := WORLD_SCENE.instantiate()
	add_child(world)
	var player := world.get_node("Player") as ThirdPersonController
	player.set_physics_process(false)
	(player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D).current = false
	(player.get_node("InteractionPrompt") as CanvasLayer).visible = false

	_camera = Camera3D.new()
	_camera.fov = 58.0
	_camera.current = true
	add_child(_camera)

	var absolute_directory := ProjectSettings.globalize_path(CAPTURE_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	assert(directory_error == OK or directory_error == ERR_ALREADY_EXISTS)

	await _capture_view(
		"graybox_player.png",
		Vector3(2.6, 2.1, 24.8),
		Vector3(0.0, 0.9, 21.0)
	)
	await _capture_view(
		"graybox_house.png",
		Vector3(10.5, 5.4, 10.0),
		Vector3(0.0, 1.8, 21.0)
	)
	var player_visual := player.get_node("VisualRoot") as Node3D
	player_visual.visible = false
	await _capture_view(
		"graybox_grandma.png",
		Vector3(2.4, 2.0, 20.2),
		Vector3(0.0, 1.05, 24.0)
	)
	player_visual.visible = true
	await _capture_view(
		"graybox_route.png",
		Vector3(13.5, 10.5, 28.0),
		Vector3(0.0, 0.8, -5.0)
	)
	var event_trigger := world.get_node("River/KappaEventTrigger") as EventTrigger
	EventManager.reset_history()
	assert(EventManager.try_trigger(event_trigger.event_definition, &"river", 12 * 60 + 30))
	await get_tree().create_timer(0.55).timeout
	await _capture_view(
		"graybox_river.png",
		Vector3(0.0, 6.0, -7.0),
		Vector3(0.0, -0.1, -18.0)
	)

	print("Visual captures saved to %s" % absolute_directory)
	get_tree().quit(0)


func _capture_view(file_name: String, camera_position: Vector3, target: Vector3) -> void:
	_camera.global_position = camera_position
	_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	assert(not image.is_empty())
	var output_path := "%s/%s" % [CAPTURE_DIRECTORY, file_name]
	assert(image.save_png(output_path) == OK)
