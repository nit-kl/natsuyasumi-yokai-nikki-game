extends Node

const WORLD_SCENE := preload("res://scenes/world/vertical_slice_graybox.tscn")


func _ready() -> void:
	GameState.start_new_game()
	GameState.set_progress_phase(GameState.ProgressPhase.FREE_ROAM)
	GameClock.set_time(7, 0)
	EventManager.reset_history()

	var world := WORLD_SCENE.instantiate()
	add_child(world)
	await get_tree().process_frame
	var trigger := world.get_node("River/KappaEventTrigger") as EventTrigger
	var glimpse := world.get_node("River/KappaGlimpse") as KappaGlimpse
	var player := world.get_node("Player") as ThirdPersonController
	trigger.approach_delay_seconds = 0.12
	glimpse.stillness_duration = 0.02
	glimpse.ripple_duration = 0.03
	glimpse.reflection_duration = 0.03
	glimpse.visible_duration = 0.08

	var stages: Array[StringName] = []
	var splash_count := [0]
	glimpse.clue_stage_changed.connect(func(stage: StringName) -> void: stages.append(stage))
	glimpse.dive_splash_emitted.connect(func() -> void: splash_count[0] += 1)
	trigger._on_body_entered(player)
	assert(trigger.is_pending)
	assert(not EventManager.has_triggered(&"kappa_first_glimpse"))
	assert(glimpse.is_foreshadowing)
	assert(stages == [&"stillness"])

	await get_tree().create_timer(0.075).timeout
	assert(not EventManager.has_triggered(&"kappa_first_glimpse"))
	assert(stages.has(&"ripple"))
	assert(stages.has(&"reflection"))
	assert(glimpse.green_reflection.visible)

	await get_tree().create_timer(0.07).timeout
	assert(EventManager.has_triggered(&"kappa_first_glimpse"))
	assert(GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME)
	assert(glimpse.is_showing)
	assert(not glimpse.green_reflection.visible)

	await get_tree().create_timer(0.14).timeout
	assert(splash_count[0] == 1)
	assert(glimpse.dive_splash.emitting)
	assert(AudioManager.last_sfx_cue == &"kappa_splash")
	await get_tree().create_timer(0.06).timeout
	assert(not glimpse.is_showing)
	assert(not glimpse.is_foreshadowing)
	assert(not AudioManager.ambience_ducked)

	print("Kappa foreshadow smoke test passed.")
	get_tree().quit(0)
