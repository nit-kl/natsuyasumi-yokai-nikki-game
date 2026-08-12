class_name ReturnHomeFlow
extends Node

signal diary_review_started(day_index: int)
signal day_completed(completed_day: int, next_day: int)
signal final_day_reviewed(day_index: int)

const MORNING_TIME_MINUTES := 420
const COMPLETION_FRAGMENT: StringName = &"evening_diary_written"

@export var dinner_dialogue: DialogueResource
@export var grandma_path: NodePath
@export var dialogue_controller_path: NodePath
@export var diary_ui_path: NodePath
@export var bedroom_spawn_path: NodePath
@export var autosave_enabled := true

var _grandma: NPC
var _interaction_area: NPCInteractionArea
var _dialogue_controller: DialogueController
var _diary_ui: DiaryUI
var _bedroom_spawn: MapSpawnPoint
var _default_dialogue: DialogueResource
var _reviewed_day := 0
var _awaiting_diary_close := false


func _ready() -> void:
	_grandma = get_node_or_null(grandma_path) as NPC
	_dialogue_controller = get_node_or_null(dialogue_controller_path) as DialogueController
	_diary_ui = get_node_or_null(diary_ui_path) as DiaryUI
	_bedroom_spawn = get_node_or_null(bedroom_spawn_path) as MapSpawnPoint
	if _grandma != null:
		_interaction_area = _grandma.get_node_or_null("InteractionArea") as NPCInteractionArea
	if _interaction_area != null:
		_default_dialogue = _interaction_area.dialogue
	if _dialogue_controller != null:
		_dialogue_controller.dialogue_finished.connect(_on_dialogue_finished)
	if _diary_ui != null:
		_diary_ui.closed.connect(_on_diary_closed)
	GameClock.period_changed.connect(_on_period_changed)
	_refresh_grandma_dialogue()


static func is_return_period(period: StringName) -> bool:
	return period == &"evening" or period == &"night"


func begin_diary_review() -> bool:
	if _awaiting_diary_close or _diary_ui == null:
		return false
	_reviewed_day = CalendarManager.day_index
	var record := DiaryManager.get_or_create_record(_reviewed_day)
	record.sleep_time = GameClock.time_minutes
	DiaryManager.add_fragment(COMPLETION_FRAGMENT)
	_awaiting_diary_close = true
	_diary_ui.refresh(_reviewed_day)
	_diary_ui.set_open(true)
	diary_review_started.emit(_reviewed_day)
	return true


func complete_day() -> bool:
	if _reviewed_day <= 0 or _reviewed_day != CalendarManager.day_index:
		return false
	var completed_day := _reviewed_day
	_reviewed_day = 0
	if not CalendarManager.next_day():
		WorldState.set_flag(&"vertical_slice_final_day_reviewed")
		_refresh_grandma_dialogue()
		if autosave_enabled:
			SaveManager.save_game()
		final_day_reviewed.emit(completed_day)
		return true
	GameClock.set_time_minutes(MORNING_TIME_MINUTES)
	_place_player_in_bedroom()
	if autosave_enabled:
		SaveManager.save_game()
	day_completed.emit(completed_day, CalendarManager.day_index)
	return true


func _refresh_grandma_dialogue() -> void:
	if _interaction_area == null:
		return
	var record := DiaryManager.get_or_create_record()
	var already_reviewed := record.diary_fragments.has(COMPLETION_FRAGMENT)
	var use_dinner := is_return_period(GameClock.get_period()) and dinner_dialogue != null and not already_reviewed
	_interaction_area.dialogue = dinner_dialogue if use_dinner else _default_dialogue


func _place_player_in_bedroom() -> void:
	if _bedroom_spawn == null or not is_instance_valid(GameState.player):
		return
	GameState.player.global_position = _bedroom_spawn.global_position.round()
	if GameState.player.has_method("set_facing"):
		GameState.player.set_facing(_bedroom_spawn.facing)


func _on_period_changed(_period: StringName) -> void:
	_refresh_grandma_dialogue()


func _on_dialogue_finished(dialogue_id: StringName) -> void:
	if dinner_dialogue != null and dialogue_id == dinner_dialogue.dialogue_id:
		begin_diary_review.call_deferred()


func _on_diary_closed() -> void:
	if not _awaiting_diary_close:
		return
	_awaiting_diary_close = false
	complete_day()
