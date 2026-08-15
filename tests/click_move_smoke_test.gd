extends Node


func _ready() -> void:
	var monitor := ClickMoveMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class ClickMoveMonitor extends Node:
	const OUTDOOR_SCENE := "res://scenes/maps/village/home_outdoor.tscn"
	const START_POSITION := Vector2(180, 184)
	const DESTINATION := Vector2(250, 300)
	const MAX_PHYSICS_FRAMES := 420


	func run() -> void:
		GameState.set_paused(false)
		GameClock.set_clock_paused(false)
		var error := await SceneTransitionManager.change_scene(OUTDOOR_SCENE, &"house_exit")
		if error != OK:
			_fail("Could not open the outdoor map for click movement.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var player := GameState.player
		var click_move := player.get_node("ClickMoveController") as ClickMoveController
		player.global_position = START_POSITION
		await get_tree().physics_frame
		if not click_move.set_destination(DESTINATION):
			_fail("A ground destination should start click movement.")
			return
		var farthest_x := player.global_position.x
		for _frame in range(MAX_PHYSICS_FRAMES):
			await get_tree().physics_frame
			farthest_x = maxf(farthest_x, player.global_position.x)
			if not click_move.is_active:
				break
		if player.global_position.distance_to(DESTINATION) > click_move.arrival_distance + 2.0:
			_fail("Click movement should reach its destination across the irrigation obstacle (position=%s next=%s velocity=%s finished=%s path=%s)." % [player.global_position, click_move.navigation_agent.get_next_path_position(), player.velocity, click_move.navigation_agent.is_navigation_finished(), click_move.navigation_agent.get_current_navigation_path()])
			return
		if farthest_x < 234.0:
			_fail("Click movement should route through the irrigation gap instead of pushing into collision.")
			return
		if not click_move.set_destination(Vector2(410, 300)):
			_fail("A second click destination should be accepted.")
			return
		click_move.cancel_movement()
		await get_tree().physics_frame
		if click_move.is_active or player.is_moving:
			_fail("Cancelling click movement should stop the player.")
			return
		player.set_movement_locked(true)
		if click_move.set_destination(Vector2(410, 300)):
			_fail("Movement lock should reject new click destinations.")
			return
		player.set_movement_locked(false)
		_quit_cleanly(0)


	func _fail(message: String) -> void:
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
		get_tree().quit(exit_code)
