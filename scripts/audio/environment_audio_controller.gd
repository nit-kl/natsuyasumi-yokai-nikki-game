class_name EnvironmentAudioController
extends Node

signal ambience_changed(area_id: StringName, period: StringName, has_stream: bool)

const SILENT_VOLUME_DB := -60.0

@export var profiles: Array[EnvironmentAudioProfile] = []
@export_range(0.0, 5.0, 0.05) var crossfade_seconds := 1.0
@export var loop_ambience := true

@onready var player_a: AudioStreamPlayer = %PlayerA
@onready var player_b: AudioStreamPlayer = %PlayerB

var _active_player: AudioStreamPlayer
var _fade_tween: Tween


func _ready() -> void:
	_active_player = player_a
	GameState.area_changed.connect(_on_area_changed)
	GameClock.period_changed.connect(_on_period_changed)
	SceneTransitionManager.transition_started.connect(_on_transition_started)
	refresh(false)


func _exit_tree() -> void:
	shutdown()


func shutdown() -> void:
	if _fade_tween != null:
		_fade_tween.kill()
		_fade_tween = null
	for player in [player_a, player_b]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null


func refresh(use_crossfade: bool = true) -> void:
	var area_id := GameState.current_area_id
	var period := GameClock.get_period()
	var profile := get_profile(area_id)
	var stream := profile.get_stream(period) if profile != null else null
	var volume_db := profile.volume_db if profile != null else 0.0
	_switch_stream(stream, volume_db, use_crossfade)
	ambience_changed.emit(area_id, period, stream != null)


func get_profile(area_id: StringName) -> EnvironmentAudioProfile:
	for profile in profiles:
		if profile != null and profile.is_valid_profile() and profile.area_id == area_id:
			return profile
	return null


func _switch_stream(stream: AudioStream, volume_db: float, use_crossfade: bool) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	if stream == null:
		_stop_players(use_crossfade)
		return
	configure_ambience_stream(stream, loop_ambience)
	if _active_player.stream == stream:
		_active_player.volume_db = volume_db
		if not _active_player.playing:
			_active_player.play()
		return
	var previous := _active_player
	var next := _active_player
	if previous.stream != null:
		next = player_b if _active_player == player_a else player_a
	next.stop()
	next.stream = stream
	next.volume_db = SILENT_VOLUME_DB if use_crossfade and crossfade_seconds > 0.0 else volume_db
	next.play()
	_active_player = next
	if not use_crossfade or crossfade_seconds <= 0.0:
		previous.stop()
		return
	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.tween_property(next, "volume_db", volume_db, crossfade_seconds)
	if previous.playing:
		_fade_tween.tween_property(previous, "volume_db", SILENT_VOLUME_DB, crossfade_seconds)
		_fade_tween.chain().tween_callback(previous.stop)


static func configure_ambience_stream(stream: AudioStream, should_loop: bool) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = should_loop


func _stop_players(use_fade: bool) -> void:
	var playing_players := [player_a, player_b].filter(func(player: AudioStreamPlayer) -> bool: return player.playing)
	if playing_players.is_empty():
		return
	if not use_fade or crossfade_seconds <= 0.0:
		for player: AudioStreamPlayer in playing_players:
			player.stop()
		return
	_fade_tween = create_tween().set_parallel(true)
	for player: AudioStreamPlayer in playing_players:
		_fade_tween.tween_property(player, "volume_db", SILENT_VOLUME_DB, crossfade_seconds)
	_fade_tween.chain().tween_callback(func() -> void:
		for player: AudioStreamPlayer in playing_players:
			player.stop()
	)


func _on_area_changed(_area_id: StringName) -> void:
	refresh()


func _on_period_changed(_period: StringName) -> void:
	refresh()


func _on_transition_started(_scene_path: String) -> void:
	shutdown()
