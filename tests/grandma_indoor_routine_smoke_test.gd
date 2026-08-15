extends Node


func _ready() -> void:
	var monitor := GrandmaIndoorRoutineMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class GrandmaIndoorRoutineMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"
	const HOME_POSITION := Vector2(244.0, 164.0)
	const TABLE_SOUTH := Vector2(320.0, 217.0)
	const KITCHEN_ENTRANCE := Vector2(462.0, 212.0)
	const MAX_MOVE_FRAMES := 720


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom")
		if error != OK:
			_fail("Could not open grandma house for indoor routine testing.")
			return
		await get_tree().physics_frame
		await get_tree().physics_frame
		var house := get_tree().current_scene
		var grandma := house.get_node("NPCs/Grandma") as NPC
		var routine := house.get_node("GrandmaIndoorRoutine") as GrandmaIndoorRoutine
		var agent := grandma.get_node_or_null("NavigationAgent") as NavigationAgent2D
		var sprite := grandma.get_node("AnimatedSprite2D") as AnimatedSprite2D
		var grandma_shape := grandma.get_node("CollisionShape2D").shape as CapsuleShape2D
		if agent == null or routine == null or grandma.collision_mask & 1 == 0:
			_fail("Grandma should have indoor navigation and avoid the Player body.")
			return
		if grandma_shape == null or grandma_shape.radius != 5.0:
			_fail("Grandma should use the narrow indoor movement footprint.")
			return
		var navigation_map := grandma.get_world_2d().navigation_map
		var path := NavigationServer2D.map_get_path(navigation_map, HOME_POSITION, TABLE_SOUTH, true)
		if path.size() < 2 or path[path.size() - 1].distance_to(TABLE_SOUTH) > 3.0:
			_fail("Grandma's living-room routine points should share a complete navigation path.")
			return
		var kitchen_path := NavigationServer2D.map_get_path(navigation_map, HOME_POSITION, KITCHEN_ENTRANCE, true)
		if kitchen_path.size() < 2 or kitchen_path[kitchen_path.size() - 1].distance_to(KITCHEN_ENTRANCE) > 3.0:
			_fail("Grandma should have a complete path from the table to the kitchen entrance.")
			return
		if not routine.go_to_waypoint(1):
			_fail("Grandma routine should accept the south side of the low table.")
			return
		await get_tree().physics_frame
		if not grandma.is_moving or not String(sprite.animation).begins_with("walk_"):
			_fail("Grandma should use her directional walk animation while following the indoor path.")
			return
		if not await _wait_until(func() -> bool: return grandma.global_position.distance_to(TABLE_SOUTH) <= 8.0):
			_fail("Grandma should walk around the low table without crossing furniture (position=%s next=%s path=%s)." % [grandma.global_position, agent.get_next_path_position(), path])
			return
		var player := GameState.player
		player.global_position = grandma.global_position + Vector2(20.0, 0.0)
		var interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		var dialogue := house.get_node("LocationRuntime/DialogueController") as DialogueController
		interaction.interact(player)
		await get_tree().physics_frame
		if not dialogue.is_active() or grandma.is_moving or not String(sprite.animation).begins_with("idle_"):
			_fail("Grandma should stop and use an idle facing during conversation.")
			return
		var conversation_position := grandma.global_position
		for _frame in range(12):
			await get_tree().physics_frame
		if grandma.global_position.distance_to(conversation_position) > 0.1:
			_fail("Grandma should remain still while dialogue pauses the clock.")
			return
		dialogue.finish_dialogue()
		player.global_position = Vector2(142.0, 174.0)
		if not routine.go_to_waypoint(3):
			_fail("Grandma should resume her routine toward the kitchen after conversation.")
			return
		await get_tree().physics_frame
		if not grandma.is_moving:
			_fail("Grandma should continue walking after dialogue and personal space clear.")
			return
		if not await _wait_until(func() -> bool: return grandma.global_position.distance_to(KITCHEN_ENTRANCE) <= 8.0):
			_fail("Grandma should reach the kitchen entrance through the passage below the plant (position=%s path=%s)." % [grandma.global_position, kitchen_path])
			return
		GameClock.debug_set_time(17, 0)
		if not routine.is_returning_home():
			_fail("Evening should return grandma to her stable dinner position.")
			return
		if not await _wait_until(func() -> bool: return grandma.global_position.distance_to(HOME_POSITION) <= 8.0 and not grandma.is_moving):
			_fail("Grandma should return to the table before the evening dinner flow.")
			return
		GameClock.debug_set_time(7, 0)
		if routine.is_returning_home() or not routine.go_to_waypoint(1):
			_fail("A new morning should resume grandma's indoor routine.")
			return
		await get_tree().physics_frame
		if not grandma.is_moving:
			_fail("Grandma should be able to walk again after the evening state clears.")
			return
		_quit_cleanly(0)


	func _wait_until(predicate: Callable) -> bool:
		for _frame in range(MAX_MOVE_FRAMES):
			if predicate.call():
				return true
			await get_tree().physics_frame
		return false


	func _reset_state() -> void:
		CalendarManager.debug_set_day(1)
		GameClock.debug_set_time(7, 0)
		GameClock.set_clock_paused(false)
		GameState.set_paused(false)
		WorldState.reset_state()
		YokaiManager.reset_state()
		EventManager.reset_runtime()
		DiaryManager.reset_state()


	func _fail(message: String) -> void:
		push_error(message)
		_quit_cleanly(1)


	func _quit_cleanly(exit_code: int) -> void:
		var scene := get_tree().current_scene
		var audio := scene.get_node_or_null("LocationRuntime/EnvironmentAudio") as EnvironmentAudioController if scene != null else null
		if audio != null:
			audio.shutdown()
			await get_tree().create_timer(0.2).timeout
		if scene != null:
			scene.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
