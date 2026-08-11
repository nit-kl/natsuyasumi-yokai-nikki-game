extends Node

const RIVER_PROFILE: AmbientProfile = preload("res://resources/audio/river_ambience.tres")


func _ready() -> void:
	assert(AudioServer.get_bus_index(&"Music") >= 0)
	assert(AudioServer.get_bus_index(&"Ambience") >= 0)
	assert(AudioServer.get_bus_index(&"SFX") >= 0)
	assert(AudioManager.get_node_or_null("Ambience1") is AudioStreamPlayer)
	assert(AudioManager.get_node_or_null("Ambience2") is AudioStreamPlayer)
	var sfx_player := AudioManager.get_node_or_null("SFX") as AudioStreamPlayer
	assert(sfx_player != null)
	assert(sfx_player.max_polyphony == 8)
	assert(AudioManager.sfx_library != null)
	assert(AudioManager.has_cue(&"bug_catch"))
	assert(AudioManager.has_cue(&"kappa_ripple"))
	assert(AudioManager.has_cue(&"diary_page"))
	assert(not AudioManager.has_cue(&"unknown"))
	var requested_cues: Array[StringName] = []
	var stream_states: Array[bool] = []
	AudioManager.sfx_cue_requested.connect(
		func(cue_id: StringName, stream_available: bool) -> void:
			requested_cues.append(cue_id)
			stream_states.append(stream_available)
	)
	assert(not AudioManager.play_cue(&"bug_catch"))
	assert(AudioManager.last_sfx_cue == &"bug_catch")
	assert(requested_cues == [&"bug_catch"])
	assert(stream_states == [false])

	AudioManager.register_profile(RIVER_PROFILE)
	GameState.set_current_area(&"river")
	AudioManager.refresh_ambience()
	assert(not (AudioManager.get_node("Ambience1") as AudioStreamPlayer).playing)
	assert(not (AudioManager.get_node("Ambience2") as AudioStreamPlayer).playing)
	AudioManager.set_ambience_ducked(true, 0.01)
	assert(AudioManager.ambience_ducked)
	AudioManager.set_ambience_ducked(false, 0.01)
	assert(not AudioManager.ambience_ducked)
	AudioManager.play_sfx(null)
	AudioManager.unregister_profile(&"river")

	print("Audio manager smoke test passed.")
	get_tree().quit(0)
