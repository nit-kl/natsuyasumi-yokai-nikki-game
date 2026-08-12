extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var day_spin_box: SpinBox = %DaySpinBox
@onready var hour_spin_box: SpinBox = %HourSpinBox
@onready var minute_spin_box: SpinBox = %MinuteSpinBox
@onready var status_label: Label = %StatusLabel


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
