extends Node

signal return_home_requested
signal day_completed(record: DayRecord)
signal day_summary_dismissed(record: DayRecord)

const MORNING_DIALOGUE_ID: StringName = &"grandma_morning"
const RETURN_HOME_EVENT_ID: StringName = &"kappa_first_glimpse"

var is_summary_active := false


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	EventManager.event_triggered.connect(_on_event_triggered)
	GameState.state_reset.connect(_on_state_reset)


func can_complete_day() -> bool:
	return (
		GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME
		and GameState.current_area == &"grandma_house"
		and EventManager.has_triggered(RETURN_HOME_EVENT_ID)
	)


func complete_day() -> DayRecord:
	if not can_complete_day():
		return null
	var record := DayRecordManager.create_current_day_record()
	is_summary_active = true
	GameState.set_progress_phase(GameState.ProgressPhase.DAY_SUMMARY)
	GameClock.set_paused(true)
	day_completed.emit(record)
	return record


func dismiss_day_summary() -> void:
	if not is_summary_active:
		return
	var record := DayRecordManager.get_latest_record()
	is_summary_active = false
	GameState.set_progress_phase(GameState.ProgressPhase.DIARY)
	day_summary_dismissed.emit(record)


func sync_after_load() -> void:
	is_summary_active = GameState.progress_phase == GameState.ProgressPhase.DAY_SUMMARY
	if is_summary_active:
		GameClock.set_paused(true)
		var record := DayRecordManager.get_latest_record()
		if record != null:
			day_completed.emit(record)


func _on_dialogue_ended(sequence: DialogueSequence) -> void:
	if sequence.dialogue_id == MORNING_DIALOGUE_ID and GameState.progress_phase == GameState.ProgressPhase.INTRO:
		GameState.set_progress_phase(GameState.ProgressPhase.FREE_ROAM)


func _on_event_triggered(event: EventDefinition) -> void:
	if event.event_id != RETURN_HOME_EVENT_ID:
		return
	if GameClock.current_minutes < GameClock.evening_start_minutes:
		GameClock.set_time(
			GameClock.evening_start_minutes / 60,
			GameClock.evening_start_minutes % 60
		)
	GameState.set_progress_phase(GameState.ProgressPhase.RETURN_HOME)
	return_home_requested.emit()


func _on_state_reset() -> void:
	is_summary_active = false
