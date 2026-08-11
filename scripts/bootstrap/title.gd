extends Control

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)
	continue_button.disabled = not SaveManager.has_save_game()
	status_label.text = SceneFlow.last_error
	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	_set_buttons_disabled(true)
	status_label.text = "夏休みを始めています…"
	if SceneFlow.start_new_game() != OK:
		_show_transition_error()


func _on_continue_pressed() -> void:
	_set_buttons_disabled(true)
	status_label.text = "日記の続きから始めています…"
	if SceneFlow.continue_game() != OK:
		_show_transition_error()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _set_buttons_disabled(value: bool) -> void:
	new_game_button.disabled = value
	continue_button.disabled = value or not SaveManager.has_save_game()
	%QuitButton.disabled = value


func _show_transition_error() -> void:
	status_label.text = SceneFlow.last_error
	_set_buttons_disabled(false)
	new_game_button.grab_focus()
