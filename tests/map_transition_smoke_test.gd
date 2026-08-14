extends Node

const DESTINATION := "res://scenes/maps/village/home_outdoor.tscn"


func _ready() -> void:
	var monitor := TransitionMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class TransitionMonitor extends Node:
	func run() -> void:
		var error := await SceneTransitionManager.change_scene(DESTINATION, &"house_exit")
		if error != OK:
			_finish_with_error("Scene transition returned error %d." % error)
			return
		await get_tree().process_frame
		var scene := get_tree().current_scene as LocationScene
		if scene == null or scene.area_id != &"home_outdoor":
			_finish_with_error("Outdoor scene was not installed after transition.")
			return
		var player := GameState.player
		if not is_instance_valid(player) or player.global_position != Vector2(320, 148):
			_finish_with_error("Player was not placed at the requested outdoor spawn.")
			return
		_quit_cleanly(0)


	func _finish_with_error(message: String) -> void:
		push_error(message)
		_quit_cleanly(1)


	func _quit_cleanly(exit_code: int) -> void:
		var scene := get_tree().current_scene
		var audio := scene.get_node_or_null("LocationRuntime/EnvironmentAudio") as EnvironmentAudioController if scene != null else null
		if audio != null:
			audio.shutdown()
			audio.free()
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().create_timer(0.1).timeout
		get_tree().quit(exit_code)
