class_name EnvironmentAudio
extends Node

@export var profiles: Array[AmbientProfile] = []


func _ready() -> void:
	for profile in profiles:
		AudioManager.register_profile(profile)
	AudioManager.refresh_ambience()


func _exit_tree() -> void:
	for profile in profiles:
		if profile != null:
			AudioManager.unregister_profile(profile.area_id)
	AudioManager.stop_ambience()
