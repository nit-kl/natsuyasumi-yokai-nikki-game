extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var day_spin_box: SpinBox = %DaySpinBox
@onready var hour_spin_box: SpinBox = %HourSpinBox
@onready var minute_spin_box: SpinBox = %MinuteSpinBox
@onready var weather_option: OptionButton = %WeatherOption
@onready var status_label: Label = %StatusLabel
@onready var event_report_label: Label = %EventReportLabel
@onready var preset_option: OptionButton = %PresetOption
@onready var teleport_option: OptionButton = %TeleportOption

const WEATHER_LABELS := {
	&"sunny": "晴れ",
	&"cloudy": "曇り",
	&"rain": "雨",
	&"thunderstorm": "雷雨",
}

var _playtest_controller: PlaytestDebugController
var _preset_ids: Array[StringName] = []
var _teleport_ids: Array[StringName] = []
var _clock_was_paused := false


func _ready() -> void:
	if not OS.has_feature("debug"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	CalendarManager.day_changed.connect(_sync_values)
	GameClock.minute_changed.connect(_sync_values)
	WeatherManager.weather_changed.connect(_sync_values)
	_populate_weather_options()
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	SaveManager.operation_failed.connect(_on_operation_failed)
	_playtest_controller = get_tree().get_first_node_in_group("playtest_debug_controller") as PlaytestDebugController
	_populate_playtest_controls()
	_sync_values()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		_set_menu_visible(not panel.visible)
		get_viewport().set_input_as_handled()


func _set_menu_visible(is_visible: bool) -> void:
	if is_visible == panel.visible:
		return
	if is_visible:
		_clock_was_paused = GameClock.is_paused
	panel.visible = is_visible
	GameState.set_paused(is_visible)
	GameClock.set_clock_paused(true if is_visible else _clock_was_paused)


func _on_apply_day_pressed() -> void:
	CalendarManager.debug_set_day(int(day_spin_box.value))
	_set_status("Day set to %d." % CalendarManager.day_index)


func _on_apply_time_pressed() -> void:
	GameClock.debug_set_time(int(hour_spin_box.value), int(minute_spin_box.value))
	_set_status("Time set to %s." % GameClock.get_time_text())


func _on_apply_weather_pressed() -> void:
	if weather_option.selected < 0 or weather_option.selected >= WeatherManager.WEATHER_IDS.size():
		_set_status("Weather selection is unavailable.")
		return
	var weather := WeatherManager.WEATHER_IDS[weather_option.selected]
	if WeatherManager.debug_set_weather(weather):
		_set_status("Weather set to %s." % WEATHER_LABELS.get(weather, String(weather)))
	else:
		_set_status("Weather change failed.")


func _on_save_pressed() -> void:
	SaveManager.save_game()


func _on_load_pressed() -> void:
	_set_menu_visible(false)
	await SaveManager.load_game_into_world()


func _on_show_events_pressed() -> void:
	var lines: Array[String] = []
	for entry in EventManager.get_debug_report():
		var state := "OK" if bool(entry.matches) else "NO"
		var reasons: Array = entry.reasons
		var reason_strings := PackedStringArray(reasons.map(func(reason: Variant) -> String: return String(reason)))
		var reason_text := "" if reasons.is_empty() else " - %s" % "; ".join(reason_strings)
		lines.append("[%s] %s%s" % [state, entry.event_id, reason_text])
	event_report_label.text = "\n".join(lines) if not lines.is_empty() else "No registered events."


func _on_trigger_event_pressed() -> void:
	var candidates := EventManager.get_candidates()
	if candidates.is_empty():
		_set_status("No matching event candidate.")
		return
	var event: EventDefinition = candidates[0]
	_set_status("Triggered %s." % event.event_id if EventManager.trigger_event(event.event_id) else "Trigger failed.")
	_on_show_events_pressed()


func _on_force_kappa_trace_pressed() -> void:
	_set_status("Forced kappa_first_trace." if EventManager.trigger_event(&"kappa_first_trace", true) else "Event is not registered.")
	_on_show_events_pressed()


func _on_force_kappa_sighting_pressed() -> void:
	_set_status("Forced kappa_first_sighting." if EventManager.trigger_event(&"kappa_first_sighting", true) else "Event is not registered.")
	_on_show_events_pressed()


func _on_apply_preset_pressed() -> void:
	if _playtest_controller == null or preset_option.selected < 0:
		_set_status("Playtest controller is unavailable.")
		return
	var preset_id := _preset_ids[preset_option.selected]
	_set_status("Applied %s." % preset_id if _playtest_controller.apply_preset(preset_id) else "Preset failed.")
	_sync_values()
	_on_show_events_pressed()


func _on_teleport_pressed() -> void:
	if _playtest_controller == null or teleport_option.selected < 0:
		_set_status("Playtest controller is unavailable.")
		return
	var point_id := _teleport_ids[teleport_option.selected]
	_set_status("Teleported to %s." % point_id if _playtest_controller.teleport(point_id) else "Teleport failed.")


func _on_snapshot_pressed() -> void:
	event_report_label.text = _playtest_controller.get_snapshot_text() if _playtest_controller != null else "Playtest controller is unavailable."


func _on_reset_runtime_pressed() -> void:
	if _playtest_controller == null:
		_set_status("Playtest controller is unavailable.")
		return
	_playtest_controller.reset_runtime_state()
	_sync_values()
	_set_status("Runtime state reset. Save file was kept.")
	_on_show_events_pressed()


func _sync_values(_unused: Variant = null) -> void:
	day_spin_box.value = CalendarManager.day_index
	hour_spin_box.value = GameClock.time_minutes / 60
	minute_spin_box.value = GameClock.time_minutes % 60
	var weather_index := WeatherManager.WEATHER_IDS.find(WeatherManager.get_weather())
	if weather_index >= 0:
		weather_option.select(weather_index)


func _on_save_completed(_path: String) -> void:
	_set_status("Save completed.")


func _on_load_completed(_path: String) -> void:
	_sync_values()
	_set_status("Load completed.")


func _on_operation_failed(message: String) -> void:
	_set_status(message)


func _set_status(message: String) -> void:
	status_label.text = message


func _populate_weather_options() -> void:
	weather_option.clear()
	for weather in WeatherManager.WEATHER_IDS:
		weather_option.add_item(String(WEATHER_LABELS.get(weather, String(weather))))


func _populate_playtest_controls() -> void:
	preset_option.clear()
	teleport_option.clear()
	_preset_ids.clear()
	_teleport_ids.clear()
	if _playtest_controller == null:
		return
	for preset in _playtest_controller.presets:
		if preset == null or not preset.is_valid_preset():
			continue
		preset_option.add_item(preset.display_name)
		_preset_ids.append(preset.preset_id)
	var point_ids: Array = _playtest_controller.teleport_points.keys()
	point_ids.sort()
	for point_id: Variant in point_ids:
		teleport_option.add_item(String(point_id))
		_teleport_ids.append(StringName(point_id))
