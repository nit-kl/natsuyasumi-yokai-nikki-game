class_name DiaryUI
extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel

var _clock_was_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_diary") and not GameState.is_paused:
		if not panel.visible and is_instance_valid(GameState.player) and GameState.player.movement_locked:
			return
		set_open(not panel.visible)
		get_viewport().set_input_as_handled()
	elif panel.visible and event.is_action_pressed("pause"):
		set_open(false)
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


func refresh(day_index: int = CalendarManager.day_index) -> void:
	var record := DiaryManager.get_or_create_record(day_index)
	title_label.text = "夏休み %d日目" % record.day_index
	body_label.text = format_record(record)


static func format_record(record: DayRecord) -> String:
	var lines: Array[String] = []
	lines.append("行った場所: %s" % _join_names(record.visited_locations))
	lines.append("会った人: %s" % _join_names(record.met_npcs))
	lines.append("見つけた妖怪: %s" % _join_names(record.met_yokai))
	lines.append("捕まえた虫: %s" % _join_names(record.caught_insects))
	lines.append("できごと: %s" % _join_names(record.events_seen))
	return "\n".join(lines)


static func _join_names(values: Array[StringName]) -> String:
	if values.is_empty():
		return "—"
	var strings := PackedStringArray(values.map(func(value: StringName) -> String: return String(value)))
	return "、".join(strings)
