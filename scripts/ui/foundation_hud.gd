class_name GameplayHUD
extends CanvasLayer

const PERIOD_NAMES := {
	&"morning": "朝",
	&"daytime": "昼",
	&"evening": "夕方",
	&"night": "夜",
}

const WEATHER_NAMES := WeatherPresentation.WEATHER_NAMES

const INSECT_NAMES := {
	&"aburazemi": "アブラゼミ",
}

@onready var day_label: Label = %DayLabel
@onready var time_label: Label = %TimeLabel
@onready var period_label: Label = %PeriodLabel
@onready var weather_icon: TextureRect = %WeatherIcon
@onready var weather_label: Label = %WeatherLabel
@onready var tool_panel: TextureRect = %ToolPanel
@onready var prompt_panel: TextureRect = %PromptPanel
@onready var interaction_label: Label = %InteractionLabel
@onready var notice_timer: Timer = %NoticeTimer
@onready var diary_button: Button = %DiaryButton

var _candidate_target: Node
var _candidate_prompt := ""
var _showing_notice := false


func _ready() -> void:
	CalendarManager.day_changed.connect(_refresh)
	GameClock.minute_changed.connect(_refresh)
	GameClock.period_changed.connect(_refresh)
	WeatherManager.weather_changed.connect(_refresh)
	DiaryManager.record_changed.connect(_on_record_changed)
	notice_timer.timeout.connect(_on_notice_timeout)
	diary_button.pressed.connect(_on_diary_button_pressed)
	var player := GameState.player
	if is_instance_valid(player):
		player.interaction_candidate_changed.connect(_on_interaction_candidate_changed)
		player.interaction_performed.connect(_on_interaction_performed)
		player.bug_catch_succeeded.connect(_on_bug_catch_succeeded)
		player.bug_catch_missed.connect(_on_bug_catch_missed)
		tool_panel.visible = player.has_node("BugCatcher")
	else:
		tool_panel.visible = false
	_refresh()
	_refresh_prompt()


func _refresh(_unused: Variant = null) -> void:
	day_label.text = "夏休み %d日目" % CalendarManager.day_index
	time_label.text = GameClock.get_time_text()
	period_label.text = display_name(GameClock.get_period(), PERIOD_NAMES)
	var weather := WeatherManager.get_weather()
	weather_label.text = display_name(weather, WEATHER_NAMES)
	var icon := WeatherPresentation.icon_texture(weather)
	weather_icon.texture = icon
	weather_icon.visible = icon != null


static func display_name(value: StringName, names: Dictionary) -> String:
	return String(names.get(value, String(value)))


func _on_record_changed(day_index: int) -> void:
	if day_index == CalendarManager.day_index:
		_refresh()


func _on_interaction_candidate_changed(target: Node, prompt_text: String) -> void:
	_candidate_target = target
	_candidate_prompt = prompt_text
	if not _showing_notice:
		_refresh_prompt()


func _on_interaction_performed(_target: Node) -> void:
	_candidate_target = null
	_candidate_prompt = ""
	if not _showing_notice:
		_refresh_prompt()


func _on_bug_catch_succeeded(insect_id: StringName) -> void:
	_show_notice("%sをつかまえた" % display_name(insect_id, INSECT_NAMES))


func _on_bug_catch_missed() -> void:
	_show_notice("虫取り網は空振りだった")


func _show_notice(text: String) -> void:
	_showing_notice = true
	interaction_label.text = text
	prompt_panel.visible = true
	notice_timer.start()


func _on_notice_timeout() -> void:
	_showing_notice = false
	_refresh_prompt()


func _refresh_prompt() -> void:
	var has_candidate := is_instance_valid(_candidate_target) and not _candidate_prompt.is_empty()
	prompt_panel.visible = has_candidate
	if has_candidate:
		interaction_label.text = "左クリック / E / Z　%s" % _candidate_prompt


func _on_diary_button_pressed() -> void:
	if GameState.is_paused:
		return
	var player := GameState.player
	if is_instance_valid(player) and player.movement_locked:
		return
	var diary := get_tree().get_first_node_in_group("diary_ui") as DiaryUI
	if diary != null and not diary.is_open():
		diary.set_open(true)
