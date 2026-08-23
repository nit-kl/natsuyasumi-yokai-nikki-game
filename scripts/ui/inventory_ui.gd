class_name InventoryUI
extends CanvasLayer

signal opened()
signal closed()

@onready var panel: Control = %Panel
@onready var item_list: VBoxContainer = %ItemList
@onready var money_label: Label = %MoneyLabel
@onready var close_button: Button = %CloseButton
@onready var cancel_audio: AudioStreamPlayer = %CancelAudio

var _clock_was_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("inventory_ui")
	close_button.pressed.connect(_on_close_pressed)
	panel.gui_input.connect(_on_panel_gui_input)
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	InventoryManager.money_changed.connect(_on_money_changed)
	panel.visible = false
	refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("pause"):
		_close_with_feedback()
		get_viewport().set_input_as_handled()


func set_open(value: bool) -> void:
	if value == panel.visible:
		return
	if value:
		_clock_was_paused = GameClock.is_paused
	panel.visible = value
	if is_instance_valid(GameState.player):
		GameState.player.set_movement_locked(value)
	GameClock.set_clock_paused(true if value else _clock_was_paused)
	if value:
		refresh()
		opened.emit()
	else:
		closed.emit()


func is_open() -> bool:
	return panel.visible


func refresh() -> void:
	for child in item_list.get_children():
		child.free()
	for item_id in InventoryManager.get_owned_item_ids():
		item_list.add_child(_make_row(item_id, InventoryManager.count(item_id)))
	money_label.text = format_money(InventoryManager.get_money())


static func format_item_line(display_name: String, count: int) -> String:
	return "%s　×%d" % [display_name, count]


static func format_money(money: int) -> String:
	return "お小遣い　%d円" % money


func _make_row(item_id: StringName, count: int) -> Control:
	var data := InventoryManager.get_item_data(item_id)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if data != null and data.icon != null:
		icon.texture = data.icon
	row.add_child(icon)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override("font_color", Color(0.24, 0.18, 0.10, 1))
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.text = format_item_line(data.display_name if data != null else String(item_id), count)
	row.add_child(name_label)
	return row


func _on_inventory_changed(_item_id: StringName, _count: int) -> void:
	if panel.visible:
		refresh()


func _on_money_changed(_money: int) -> void:
	if panel.visible:
		refresh()


func _on_close_pressed() -> void:
	if panel.visible:
		_close_with_feedback()


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event := event as InputEventMouseButton
		if not _is_over_paper(mouse_event.position):
			_close_with_feedback()


func _is_over_paper(local_position: Vector2) -> bool:
	var paper := panel.get_node_or_null("Paper") as Control
	if paper == null:
		return false
	return Rect2(paper.position, paper.size).has_point(local_position)


func _close_with_feedback() -> void:
	cancel_audio.play()
	set_open(false)
