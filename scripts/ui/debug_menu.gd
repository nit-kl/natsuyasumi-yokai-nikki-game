extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var day_spin_box: SpinBox = %DaySpinBox
@onready var hour_spin_box: SpinBox = %HourSpinBox
@onready var minute_spin_box: SpinBox = %MinuteSpinBox
@onready var status_label: Label = %StatusLabel
@onready var event_report_label: Label = %EventReportLabel


func _ready() -> void:
	if not OS.has_feature("debug"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	CalendarManager.day_changed.connect(_sync_values)
	GameClock.minute_changed.connect(_sync_values)
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	SaveManager.operation_failed.connect(_on_operation_failed)
	_sync_values()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_menu"):
		panel.visible = not panel.visible
		GameState.set_paused(panel.visible)
		GameClock.set_clock_paused(panel.visible)
		get_viewport().set_input_as_handled()


func _on_apply_day_pressed() -> void:
	CalendarManager.debug_set_day(int(day_spin_box.value))
	_set_status("Day set to %d." % CalendarManager.day_index)


func _on_apply_time_pressed() -> void:
	GameClock.debug_set_time(int(hour_spin_box.value), int(minute_spin_box.value))
	_set_status("Time set to %s." % GameClock.get_time_text())


func _on_save_pressed() -> void:
	SaveManager.save_game()


func _on_load_pressed() -> void:
	SaveManager.load_game()


func _on_show_events_pressed() -> void:
	var lines: Array[String] = []
	for entry in EventManager.get_debug_report():
		var state := "OK" if bool(entry.matches) else "NO"
		var reasons: Array = entry.reasons
		var reason_strings := PackedStringArray(reasons.map(func(reason: Variant) -> String: return String(reason)))
		var reason_text := "" if reasons.is_empty() else " — %s" % "; ".join(reason_strings)
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


func _sync_values(_unused: Variant = null) -> void:
	day_spin_box.value = CalendarManager.day_index
	hour_spin_box.value = GameClock.time_minutes / 60
	minute_spin_box.value = GameClock.time_minutes % 60


func _on_save_completed(_path: String) -> void:
	_set_status("Save completed.")


func _on_load_completed(_path: String) -> void:
	_sync_values()
	_set_status("Load completed.")


func _on_operation_failed(message: String) -> void:
	_set_status(message)


func _set_status(message: String) -> void:
	status_label.text = message
