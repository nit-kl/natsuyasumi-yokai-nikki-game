extends Node

const WORLD_SCENE := preload("res://scenes/world/vertical_slice_graybox.tscn")


func _ready() -> void:
	var was_paused := GameClock.clock_paused
	var previous_minutes := GameClock.current_minutes
	GameClock.set_paused(true)

	var lighting := WORLD_SCENE.instantiate() as DayNightLighting
	add_child(lighting)
	var sun := lighting.get_node("Sun") as DirectionalLight3D
	var environment := (lighting.get_node("WorldEnvironment") as WorldEnvironment).environment
	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	var evening_motes := lighting.get_node("EveningMotes") as GPUParticles3D

	GameClock.set_time(5, 0)
	var dawn_energy := sun.light_energy
	var dawn_rotation := sun.rotation_degrees.x

	GameClock.set_time(12, 0)
	var day_energy := sun.light_energy
	var day_sky_top := sky_material.sky_top_color
	var day_rotation := sun.rotation_degrees.x
	assert(not evening_motes.emitting)

	GameClock.set_time(16, 30)
	var sunset_horizon := sky_material.sky_horizon_color
	assert(evening_motes.emitting)
	assert(lighting.evening_vfx_active)

	GameClock.set_time(22, 0)
	var night_energy := sun.light_energy
	var night_sky_top := sky_material.sky_top_color
	assert(not evening_motes.emitting)

	assert(day_energy > dawn_energy)
	assert(dawn_energy > night_energy)
	assert(day_sky_top.get_luminance() > night_sky_top.get_luminance())
	assert(sunset_horizon.r > sunset_horizon.b)
	assert(not is_equal_approx(dawn_rotation, day_rotation))
	assert(lighting.current_period == GameClock.DayPeriod.NIGHT)

	GameClock.set_time(previous_minutes / 60, previous_minutes % 60)
	GameClock.set_paused(was_paused)
	print("Day/night lighting smoke test passed.")
	get_tree().quit(0)
