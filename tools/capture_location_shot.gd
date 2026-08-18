extends SceneTree

const VIEWPORT_SIZE := Vector2i(640, 360)


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 2:
		push_error("Usage: --script res://tools/capture_location_shot.gd -- <scene> <output.png> [player_x player_y [time_minutes [wait_seconds]]]")
		quit(1)
		return
	if DisplayServer.get_name() == "headless":
		push_error("Location shot requires a rendering display driver; do not pass --headless.")
		quit(1)
		return
	var packed_scene := load(arguments[0]) as PackedScene
	if packed_scene == null:
		push_error("Could not load scene: %s" % arguments[0])
		quit(1)
		return
	var calendar := root.get_node("CalendarManager")
	var clock := root.get_node("GameClock")
	var game_state := root.get_node("GameState")
	calendar.call("debug_set_day", 1)
	if arguments.size() >= 5:
		clock.call("set_time_minutes", int(arguments[4]))
		clock.call("set_clock_paused", true)
	root.size = VIEWPORT_SIZE
	var scene := packed_scene.instantiate() as Node2D
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	await process_frame
	if arguments.size() >= 4:
		var player := game_state.get("player") as Node2D
		if is_instance_valid(player):
			player.global_position = Vector2(arguments[2].to_float(), arguments[3].to_float()).round()
			await process_frame
	var wait_seconds := arguments[5].to_float() if arguments.size() >= 6 else 0.35
	if wait_seconds > 0.0:
		await create_timer(wait_seconds).timeout
	var insect := scene.get_node_or_null("Objects/Aburazemi") as Node2D
	if insect != null:
		print("Captured insect at %s" % insect.global_position)
	print("Captured %s clock=%s period=%s area=%s" % [
		arguments[1], clock.call("get_time_text"), clock.call("get_period"), game_state.get("current_area_id")
	])
	var output_path := ProjectSettings.globalize_path(arguments[1])
	var error := root.get_texture().get_image().save_png(output_path)
	if error != OK:
		push_error("Could not save location shot: %s" % output_path)
		scene.free()
		quit(error)
		return
	scene.free()
	quit()
