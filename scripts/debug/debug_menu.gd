extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var status_label: Label = %StatusLabel
@onready var pause_button: Button = %PauseButton
@onready var time_scale_spin_box: SpinBox = %TimeScaleSpinBox


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	panel.visible = false
	time_scale_spin_box.value = GameClock.time_scale
	GameClock.time_changed.connect(_on_clock_changed)
	GameClock.period_changed.connect(_on_period_changed)
	GameState.current_day_changed.connect(_on_day_changed)
	refresh_status()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()


func refresh_status() -> void:
	status_label.text = "Day %d / %s / %s\nArea: %s" % [
		GameState.current_day,
		GameClock.get_time_text(),
		GameClock.get_period_name(),
		String(GameState.current_area),
	]
	pause_button.text = "Resume Clock" if GameClock.clock_paused else "Pause Clock"


func _on_previous_day_pressed() -> void:
	GameState.set_current_day(GameState.current_day - 1)


func _on_next_day_pressed() -> void:
	GameState.set_current_day(GameState.current_day + 1)


func _on_minus_hour_pressed() -> void:
	GameClock.set_time(posmod(GameClock.get_hour() - 1, 24), GameClock.get_minute())


func _on_plus_hour_pressed() -> void:
	GameClock.set_time((GameClock.get_hour() + 1) % 24, GameClock.get_minute())


func _on_pause_pressed() -> void:
	GameClock.set_paused(not GameClock.clock_paused)
	refresh_status()


func _on_time_scale_changed(value: float) -> void:
	GameClock.set_time_scale(value)


func _on_reset_pressed() -> void:
	GameState.start_new_game()
	GameClock.set_time(7, 0)
	GameClock.set_paused(false)
	GameClock.set_time_scale(1.0)
	time_scale_spin_box.value = GameClock.time_scale
	refresh_status()


func _on_clock_changed(_hour: int, _minute: int) -> void:
	refresh_status()


func _on_period_changed(_period: GameClock.DayPeriod) -> void:
	refresh_status()


func _on_day_changed(_day: int) -> void:
	refresh_status()

