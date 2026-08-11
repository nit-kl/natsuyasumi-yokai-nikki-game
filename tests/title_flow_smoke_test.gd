extends Node

const TITLE_SCENE: PackedScene = preload("res://scenes/bootstrap/title.tscn")


func _ready() -> void:
	assert(ProjectSettings.get_setting("application/run/main_scene") == SceneFlow.TITLE_SCENE)
	assert(ResourceLoader.exists(SceneFlow.TITLE_SCENE))
	assert(ResourceLoader.exists(SceneFlow.GAMEPLAY_SCENE))

	var title := TITLE_SCENE.instantiate()
	add_child(title)
	await get_tree().process_frame
	var continue_button := title.get_node("Content/VBox/ContinueButton") as Button
	var new_game_button := title.get_node("Content/VBox/NewGameButton") as Button
	assert(title.has_node("TitleCard"))
	assert(new_game_button.theme != null)
	assert(continue_button.disabled == not SaveManager.has_save_game())
	assert(not new_game_button.disabled)
	assert(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)

	print("Title flow smoke test passed.")
	get_tree().quit(0)
