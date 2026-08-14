class_name DiaryUI
extends CanvasLayer

signal opened(day_index: int)
signal closed()

enum DiaryView {
	COVER,
	DAILY_PAGE,
}

const DISPLAY_NAMES := {
	&"grandma_house": "祖母の家",
	&"home_outdoor": "家のまわり",
	&"river": "川辺",
	&"grandma": "おばあちゃん",
	&"kappa": "河童",
	&"aburazemi": "アブラゼミ",
	&"kappa_first_trace": "川で不思議な波紋を見た",
	&"kappa_first_sighting": "河童を一瞬見た",
	&"evening_diary_written": "夕方に日記を書いた",
}

const WEATHER_NAMES := {
	&"sunny": "晴れ",
}

@onready var panel: Control = %Panel
@onready var cover: Control = %Cover
@onready var cover_hint: Label = %CoverHint
@onready var notebook: TextureRect = %Notebook
@onready var title_label: Label = %TitleLabel
@onready var body_label: Label = %BodyLabel
@onready var weather_icon: TextureRect = %WeatherIcon
@onready var weather_label: Label = %WeatherLabel
@onready var kappa_stamp: TextureRect = %KappaStamp
@onready var kappa_label: Label = %KappaLabel
@onready var insect_stamp: TextureRect = %InsectStamp
@onready var insect_label: Label = %InsectLabel
@onready var memo_label: Label = %MemoLabel

var _clock_was_paused: bool = false
var _current_view := DiaryView.COVER
var _is_transitioning := false
var _page_turn_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	_show_cover()


func _unhandled_input(event: InputEvent) -> void:
	if panel.visible and event.is_action_pressed("interact"):
		if _current_view == DiaryView.COVER and not _is_transitioning:
			_show_daily_page(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_diary") and not GameState.is_paused:
		if not panel.visible and is_instance_valid(GameState.player) and GameState.player.movement_locked:
			return
		set_open(not panel.visible)
		get_viewport().set_input_as_handled()
	elif panel.visible and event.is_action_pressed("pause"):
		set_open(false)
		get_viewport().set_input_as_handled()


func set_open(value: bool, show_cover: bool = true) -> void:
	if value == panel.visible:
		if value:
			if show_cover:
				_show_cover()
			else:
				_show_daily_page(false)
		return
	if value:
		_clock_was_paused = GameClock.is_paused
	panel.visible = value
	if is_instance_valid(GameState.player):
		GameState.player.set_movement_locked(value)
	GameClock.set_clock_paused(true if value else _clock_was_paused)
	if value:
		refresh()
		if show_cover:
			_show_cover()
		else:
			_show_daily_page(false)
		opened.emit(CalendarManager.day_index)
	else:
		_stop_page_turn()
		closed.emit()


func is_open() -> bool:
	return panel.visible


func is_showing_cover() -> bool:
	return panel.visible and _current_view == DiaryView.COVER


func refresh(day_index: int = CalendarManager.day_index) -> void:
	var record := DiaryManager.get_or_create_record(day_index)
	title_label.text = "夏休み %d日目" % record.day_index
	body_label.text = format_record(record)
	weather_label.text = "きょうの天気　%s" % _display_name(record.weather, WEATHER_NAMES)
	weather_icon.visible = record.weather == &"sunny"
	kappa_stamp.visible = record.met_yokai.has(&"kappa")
	kappa_label.text = "妖怪\n%s" % _join_names(record.met_yokai)
	insect_stamp.visible = record.caught_insects.has(&"aburazemi")
	insect_label.text = "虫\n%s" % _join_names(record.caught_insects)
	var memories := record.events_seen.duplicate()
	memories.append_array(record.diary_fragments)
	memo_label.text = "今日のこと\n%s" % _join_names(memories)


static func format_record(record: DayRecord) -> String:
	var lines: Array[String] = []
	lines.append("行った場所\n%s" % _join_names(record.visited_locations))
	lines.append("会った人\n%s" % _join_names(record.met_npcs))
	lines.append("見つけた妖怪　%s" % _join_names(record.met_yokai))
	lines.append("捕まえた虫　%s" % _join_names(record.caught_insects))
	return "\n".join(lines)


static func _join_names(values: Array[StringName]) -> String:
	if values.is_empty():
		return "—"
	var strings := PackedStringArray(values.map(
		func(value: StringName) -> String: return _display_name(value, DISPLAY_NAMES)
	))
	return "、".join(strings)


static func _display_name(value: StringName, names: Dictionary) -> String:
	return String(names.get(value, String(value)))


func _show_cover() -> void:
	_stop_page_turn()
	_current_view = DiaryView.COVER
	cover.visible = true
	cover.modulate = Color.WHITE
	cover.scale = Vector2.ONE
	cover_hint.visible = true
	notebook.visible = false
	notebook.modulate = Color.WHITE
	notebook.scale = Vector2.ONE


func _show_daily_page(animated: bool) -> void:
	_stop_page_turn()
	_current_view = DiaryView.DAILY_PAGE
	cover_hint.visible = false
	notebook.visible = true
	if not animated:
		cover.visible = false
		cover.modulate = Color.WHITE
		cover.scale = Vector2.ONE
		notebook.modulate = Color.WHITE
		notebook.scale = Vector2.ONE
		return
	_is_transitioning = true
	cover.visible = true
	cover.modulate = Color.WHITE
	cover.scale = Vector2.ONE
	notebook.modulate = Color(1.0, 1.0, 1.0, 0.0)
	notebook.scale = Vector2(0.94, 1.0)
	_page_turn_tween = create_tween()
	_page_turn_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_page_turn_tween.set_parallel(true)
	_page_turn_tween.tween_property(cover, "scale", Vector2(0.08, 1.0), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_page_turn_tween.tween_property(cover, "modulate:a", 0.0, 0.14)
	_page_turn_tween.tween_property(notebook, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_page_turn_tween.tween_property(notebook, "modulate:a", 1.0, 0.22)
	_page_turn_tween.chain().tween_callback(_finish_page_turn)


func _finish_page_turn() -> void:
	cover.visible = false
	cover.modulate = Color.WHITE
	cover.scale = Vector2.ONE
	notebook.modulate = Color.WHITE
	notebook.scale = Vector2.ONE
	_is_transitioning = false
	_page_turn_tween = null


func _stop_page_turn() -> void:
	if _page_turn_tween != null and _page_turn_tween.is_valid():
		_page_turn_tween.kill()
	_page_turn_tween = null
	_is_transitioning = false
