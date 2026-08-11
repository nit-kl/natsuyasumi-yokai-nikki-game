extends Node

signal ambience_changed(area_id: StringName, period: GameClock.DayPeriod)
signal sfx_cue_requested(cue_id: StringName, stream_available: bool)

const SILENT_VOLUME_DB := -60.0
const DUCKED_VOLUME_DB := -24.0
const DEFAULT_FADE_SECONDS := 1.0
const DEFAULT_SFX_LIBRARY: SfxLibrary = preload("res://resources/audio/sfx_library.tres")

var fade_seconds := DEFAULT_FADE_SECONDS
var _profiles: Dictionary = {}
var _ambience_players: Array[AudioStreamPlayer] = []
var _active_player_index := 0
var _fade_tween: Tween
var _duck_tween: Tween
var _sfx_player: AudioStreamPlayer
var ambience_ducked := false
var sfx_library: SfxLibrary = DEFAULT_SFX_LIBRARY
var last_sfx_cue: StringName = &""


func _ready() -> void:
	for index in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "Ambience%d" % (index + 1)
		player.bus = &"Ambience"
		player.volume_db = SILENT_VOLUME_DB
		add_child(player)
		_ambience_players.append(player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFX"
	_sfx_player.bus = &"SFX"
	_sfx_player.max_polyphony = 8
	add_child(_sfx_player)

	GameState.current_area_changed.connect(_on_area_changed)
	GameClock.period_changed.connect(_on_period_changed)


func register_profile(profile: AmbientProfile) -> void:
	if profile == null or not profile.is_valid():
		return
	_profiles[profile.area_id] = profile
	if profile.area_id == GameState.current_area:
		refresh_ambience()


func unregister_profile(area_id: StringName) -> void:
	_profiles.erase(area_id)
	if area_id == GameState.current_area:
		refresh_ambience()


func refresh_ambience() -> void:
	var profile := _profiles.get(GameState.current_area) as AmbientProfile
	var stream: AudioStream
	if profile != null:
		stream = profile.get_stream(GameClock.get_period())
	_transition_to(stream)
	ambience_changed.emit(GameState.current_area, GameClock.get_period())


func stop_ambience(immediate := false) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
		_fade_tween = null
	var fading_players: Array[AudioStreamPlayer] = []
	for player in _ambience_players:
		if immediate or not player.playing:
			player.stop()
			player.stream = null
			player.volume_db = SILENT_VOLUME_DB
		else:
			fading_players.append(player)
	if fading_players.is_empty():
		return
	_fade_tween = create_tween().set_parallel(true)
	for player in fading_players:
		_fade_tween.tween_property(player, "volume_db", SILENT_VOLUME_DB, fade_seconds)
		_fade_tween.chain().tween_callback(_clear_player.bind(player))


func play_sfx(stream: AudioStream, volume_db := 0.0) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.volume_db = volume_db
	_sfx_player.play()


func play_cue(cue_id: StringName, volume_db := 0.0) -> bool:
	last_sfx_cue = cue_id
	var stream: AudioStream
	if sfx_library != null:
		stream = sfx_library.get_stream(cue_id)
	sfx_cue_requested.emit(cue_id, stream != null)
	if stream == null:
		return false
	play_sfx(stream, volume_db)
	return true


func has_cue(cue_id: StringName) -> bool:
	return sfx_library != null and sfx_library.has_cue(cue_id)


func set_ambience_ducked(ducked: bool, duration := 0.25) -> void:
	ambience_ducked = ducked
	if _duck_tween != null:
		_duck_tween.kill()
	var target_db := DUCKED_VOLUME_DB if ducked else 0.0
	var playing_players: Array[AudioStreamPlayer] = []
	for player in _ambience_players:
		if player.playing:
			playing_players.append(player)
	if playing_players.is_empty():
		return
	_duck_tween = create_tween().set_parallel(true)
	for player in playing_players:
		_duck_tween.tween_property(player, "volume_db", target_db, maxf(duration, 0.01))


func set_bus_volume(bus_name: StringName, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var clamped_volume := clampf(linear_volume, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, is_zero_approx(clamped_volume))
	if not is_zero_approx(clamped_volume):
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamped_volume))


func _transition_to(stream: AudioStream) -> void:
	var active_player := _ambience_players[_active_player_index]
	if stream != null and active_player.stream == stream and active_player.playing:
		return
	if stream == null:
		stop_ambience()
		return

	if _fade_tween != null:
		_fade_tween.kill()
	var next_index := 1 - _active_player_index
	var next_player := _ambience_players[next_index]
	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = SILENT_VOLUME_DB
	next_player.play()

	_fade_tween = create_tween().set_parallel(true)
	var target_db := DUCKED_VOLUME_DB if ambience_ducked else 0.0
	_fade_tween.tween_property(next_player, "volume_db", target_db, fade_seconds)
	if active_player.playing:
		_fade_tween.tween_property(active_player, "volume_db", SILENT_VOLUME_DB, fade_seconds)
		_fade_tween.chain().tween_callback(_clear_player.bind(active_player))
	_active_player_index = next_index


func _clear_player(player: AudioStreamPlayer) -> void:
	player.stop()
	player.stream = null
	player.volume_db = SILENT_VOLUME_DB


func _on_area_changed(_area_id: StringName) -> void:
	refresh_ambience()


func _on_period_changed(_period: GameClock.DayPeriod) -> void:
	refresh_ambience()
