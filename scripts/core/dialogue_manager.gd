extends Node

signal dialogue_started(sequence: DialogueSequence)
signal line_changed(line: DialogueLine, index: int, total: int)
signal dialogue_ended(sequence: DialogueSequence)

var is_active := false
var current_sequence: DialogueSequence
var current_line_index := -1
var _clock_was_paused := false


func start_dialogue(sequence: DialogueSequence) -> bool:
	if is_active or sequence == null or not sequence.is_valid():
		return false

	is_active = true
	current_sequence = sequence
	current_line_index = 0
	_clock_was_paused = GameClock.clock_paused
	GameClock.set_paused(true)
	dialogue_started.emit(current_sequence)
	_emit_current_line()
	return true


func advance() -> void:
	if not is_active:
		return
	if current_line_index + 1 >= current_sequence.lines.size():
		finish_dialogue()
		return
	current_line_index += 1
	_emit_current_line()


func finish_dialogue() -> void:
	if not is_active:
		return
	var finished_sequence := current_sequence
	is_active = false
	current_sequence = null
	current_line_index = -1
	GameClock.set_paused(_clock_was_paused)
	dialogue_ended.emit(finished_sequence)


func get_current_line() -> DialogueLine:
	if not is_active:
		return null
	return current_sequence.lines[current_line_index]


func _emit_current_line() -> void:
	line_changed.emit(
		get_current_line(),
		current_line_index,
		current_sequence.lines.size()
	)

