class_name SfxLibrary
extends Resource

@export_group("Bug Catching")
@export var bug_notice: AudioStream
@export var bug_catch: AudioStream
@export var bug_escape: AudioStream

@export_group("Kappa")
@export var kappa_ripple: AudioStream
@export var kappa_splash: AudioStream

@export_group("Diary")
@export var diary_page: AudioStream
@export var pencil_write: AudioStream


func has_cue(cue_id: StringName) -> bool:
	return cue_id in [
		&"bug_notice",
		&"bug_catch",
		&"bug_escape",
		&"kappa_ripple",
		&"kappa_splash",
		&"diary_page",
		&"pencil_write",
	]


func get_stream(cue_id: StringName) -> AudioStream:
	match cue_id:
		&"bug_notice":
			return bug_notice
		&"bug_catch":
			return bug_catch
		&"bug_escape":
			return bug_escape
		&"kappa_ripple":
			return kappa_ripple
		&"kappa_splash":
			return kappa_splash
		&"diary_page":
			return diary_page
		&"pencil_write":
			return pencil_write
	return null
