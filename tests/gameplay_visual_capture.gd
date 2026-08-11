extends Node

const TITLE_SCENE: PackedScene = preload("res://scenes/bootstrap/title.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/bootstrap/main.tscn")
const GRANDMA_DIALOGUE: DialogueSequence = preload("res://resources/dialogue/grandma_morning.tres")
const CAPTURE_DIRECTORY := "res://.codex-captures"


func _ready() -> void:
	var absolute_directory := ProjectSettings.globalize_path(CAPTURE_DIRECTORY)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	assert(directory_error == OK or directory_error == ERR_ALREADY_EXISTS)

	var title := TITLE_SCENE.instantiate()
	add_child(title)
	await _capture("actual_title.png")
	title.queue_free()
	await get_tree().process_frame

	GameState.start_new_game()
	GameClock.set_time(12, 30)
	GameClock.set_paused(true)
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	var world := main.get_node("VerticalSliceGraybox") as Node3D
	var player := world.get_node("Player") as ThirdPersonController
	player.set_physics_process(false)
	var camera_pivot := player.get_node("CameraPivot") as DioramaCamera

	await _capture("actual_house.png")
	assert(DialogueManager.start_dialogue(GRANDMA_DIALOGUE))
	await _capture("actual_dialogue_grandma.png")
	DialogueManager.advance()
	DialogueManager.advance()
	await _capture("actual_dialogue_protagonist.png")
	DialogueManager.finish_dialogue()
	player.global_position = Vector3(0.0, 0.15, 2.0)
	camera_pivot.snap_to_target()
	await _capture("actual_route.png")
	player.global_position = Vector3(0.0, 0.15, -12.0)
	camera_pivot.snap_to_target()
	await _capture("actual_river.png")

	print("Actual gameplay captures saved to %s" % absolute_directory)
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	assert(not image.is_empty())
	assert(image.save_png("%s/%s" % [CAPTURE_DIRECTORY, file_name]) == OK)
