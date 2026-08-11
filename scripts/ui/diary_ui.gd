extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var title_label: Label = %TitleLabel
@onready var instruction_label: Label = %InstructionLabel
@onready var memory_buttons: Array[CheckButton] = [%Memory1, %Memory2, %Memory3]
@onready var entry_body: Label = %EntryBody
@onready var footer_label: Label = %FooterLabel


func _ready() -> void:
	panel.visible = false
	DiaryManager.diary_opened.connect(_on_diary_opened)
	DiaryManager.entry_saved.connect(_on_entry_saved)


func _unhandled_input(event: InputEvent) -> void:
	if not DiaryManager.is_editing or event.is_echo():
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_toggle_memory(0)
			KEY_2:
				_toggle_memory(1)
			KEY_3:
				_toggle_memory(2)
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_save_entry()
		get_viewport().set_input_as_handled()


func _on_diary_opened(record: DayRecord, options: Array[Dictionary]) -> void:
	panel.visible = true
	title_label.text = "Day %d — 妖怪日記" % record.day
	instruction_label.visible = true
	instruction_label.text = "残したい記憶を1〜3キーで選んでください。"
	entry_body.visible = false
	footer_label.text = "[1 / 2 / 3] 選択    [E / Space] 日記を書く"
	for index in range(memory_buttons.size()):
		var button := memory_buttons[index]
		button.visible = index < options.size()
		button.button_pressed = index < options.size()
		if button.visible:
			button.text = "%d. %s" % [index + 1, options[index]["text"]]


func _on_entry_saved(entry: DiaryEntry) -> void:
	title_label.text = entry.title
	instruction_label.visible = false
	for button in memory_buttons:
		button.visible = false
	entry_body.visible = true
	entry_body.text = entry.body
	footer_label.text = "Day %d complete — Vertical Slice finished" % entry.day


func _toggle_memory(index: int) -> void:
	if index < 0 or index >= memory_buttons.size():
		return
	var button := memory_buttons[index]
	if button.visible:
		button.button_pressed = not button.button_pressed


func _save_entry() -> void:
	var selected_indices: Array[int] = []
	for index in range(memory_buttons.size()):
		if memory_buttons[index].visible and memory_buttons[index].button_pressed:
			selected_indices.append(index)
	DiaryManager.save_draft(selected_indices)
