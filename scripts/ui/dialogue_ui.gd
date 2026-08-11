extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var speaker_label: Label = %SpeakerLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var progress_label: Label = %ProgressLabel


func _ready() -> void:
	panel.visible = false
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.line_changed.connect(_on_line_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _unhandled_input(event: InputEvent) -> void:
	if not DialogueManager.is_active or event.is_echo():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		DialogueManager.advance()
		get_viewport().set_input_as_handled()


func _on_dialogue_started(_sequence: DialogueSequence) -> void:
	panel.visible = true


func _on_line_changed(line: DialogueLine, index: int, total: int) -> void:
	speaker_label.text = line.speaker
	dialogue_label.text = line.text
	progress_label.text = "%d / %d    [E / Space]" % [index + 1, total]


func _on_dialogue_ended(_sequence: DialogueSequence) -> void:
	panel.visible = false

