class_name DialogueController
extends CanvasLayer

signal dialogue_started(dialogue_id: StringName)
signal line_changed(line_index: int, line: DialogueLine)
signal dialogue_finished(dialogue_id: StringName)

@onready var panel: TextureRect = %Panel
@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: Label = %BodyLabel
@onready var continue_label: Label = %ContinueLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var confirm_audio: AudioStreamPlayer = %ConfirmAudio

var current_dialogue: DialogueResource
var current_line_index: int = -1
var actor: Node
var _clock_was_paused: bool = false


func _ready() -> void:
	add_to_group("dialogue_controller")
	panel.gui_input.connect(_on_panel_gui_input)
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_active() or GameState.is_paused:
		return
	if event.is_action_pressed("interact"):
		var line := get_current_line()
		if line != null and line.has_choices():
			_choose_focused_or_first()
		else:
			advance()
		get_viewport().set_input_as_handled()


func start_dialogue(dialogue: DialogueResource, dialogue_actor: Node) -> bool:
	if is_active() or dialogue == null or not dialogue.is_valid_dialogue():
		return false
	current_dialogue = dialogue
	current_line_index = 0
	actor = dialogue_actor
	_clock_was_paused = GameClock.is_paused
	GameClock.set_clock_paused(true)
	_set_actor_locked(true)
	panel.visible = true
	dialogue_started.emit(current_dialogue.dialogue_id)
	_show_current_line()
	return true


func advance() -> void:
	if not is_active():
		return
	var line := get_current_line()
	if line != null and line.has_choices():
		return
	confirm_audio.play()
	go_to_line(current_line_index + 1)


func choose(choice_index: int) -> bool:
	var line := get_current_line()
	if line == null or choice_index < 0 or choice_index >= line.choices.size():
		return false
	var choice := line.choices[choice_index]
	if choice == null or not choice.is_valid():
		return false
	confirm_audio.play()
	var next_index := choice.next_line_index
	if next_index < 0:
		next_index = current_line_index + 1
	go_to_line(next_index)
	return true


func go_to_line(line_index: int) -> void:
	if not is_active():
		return
	if line_index < 0 or line_index >= current_dialogue.lines.size():
		finish_dialogue()
		return
	current_line_index = line_index
	_show_current_line()


func finish_dialogue() -> void:
	if not is_active():
		return
	var finished_id := current_dialogue.dialogue_id
	_set_actor_locked(false)
	GameClock.set_clock_paused(_clock_was_paused)
	_clear_choices()
	panel.visible = false
	current_dialogue = null
	current_line_index = -1
	actor = null
	dialogue_finished.emit(finished_id)


func is_active() -> bool:
	return current_dialogue != null


func get_current_line() -> DialogueLine:
	if not is_active() or current_line_index < 0 or current_line_index >= current_dialogue.lines.size():
		return null
	return current_dialogue.lines[current_line_index]


func _show_current_line() -> void:
	var line := get_current_line()
	if line == null:
		finish_dialogue()
		return
	speaker_label.text = line.speaker
	speaker_label.visible = not line.speaker.strip_edges().is_empty()
	body_label.text = line.text
	_clear_choices()
	continue_label.visible = not line.has_choices()
	if line.has_choices():
		for index in range(line.choices.size()):
			var choice := line.choices[index]
			if choice == null or not choice.is_valid():
				continue
			var button := Button.new()
			button.custom_minimum_size = Vector2(240.0, 42.0)
			button.text = choice.text
			button.set_meta("choice_index", index)
			button.pressed.connect(choose.bind(index))
			choices_container.add_child(button)
		if choices_container.get_child_count() > 0:
			choices_container.get_child(0).grab_focus()
	line_changed.emit(current_line_index, line)


func _choose_focused_or_first() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and focused.get_parent() == choices_container:
		choose(int(focused.get_meta("choice_index", 0)))
	elif choices_container.get_child_count() > 0:
		choose(0)


func _clear_choices() -> void:
	for child in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()


func _set_actor_locked(value: bool) -> void:
	if is_instance_valid(actor) and actor.has_method("set_movement_locked"):
		actor.set_movement_locked(value)


func _on_panel_gui_input(event: InputEvent) -> void:
	if not is_active() or GameState.is_paused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var line := get_current_line()
		if line != null and not line.has_choices():
			advance()
		panel.accept_event()
