extends Node

signal current_day_changed(day: int)
signal current_area_changed(area_id: StringName)
signal phase_changed(phase: ProgressPhase)
signal state_reset

enum ProgressPhase {
	INTRO,
	FREE_ROAM,
	RETURN_HOME,
	DIARY,
	DAY_SUMMARY,
	DAY_COMPLETE,
}

const FIRST_DAY := 1
const LAST_DAY := 30

var current_day: int = FIRST_DAY
var current_area: StringName = &"grandma_house"
var progress_phase: ProgressPhase = ProgressPhase.INTRO
var player_state: Dictionary = {}


func start_new_game() -> void:
	current_day = FIRST_DAY
	current_area = &"grandma_house"
	progress_phase = ProgressPhase.INTRO
	player_state.clear()
	state_reset.emit()
	current_day_changed.emit(current_day)
	current_area_changed.emit(current_area)
	phase_changed.emit(progress_phase)


func set_current_day(day: int) -> void:
	var next_day := clampi(day, FIRST_DAY, LAST_DAY)
	if next_day == current_day:
		return
	current_day = next_day
	current_day_changed.emit(current_day)


func advance_day() -> void:
	set_current_day(current_day + 1)


func set_current_area(area_id: StringName) -> void:
	if area_id == current_area:
		return
	current_area = area_id
	current_area_changed.emit(current_area)


func set_progress_phase(next_phase: ProgressPhase) -> void:
	if next_phase == progress_phase:
		return
	progress_phase = next_phase
	phase_changed.emit(progress_phase)


func to_save_data() -> Dictionary:
	return {
		"day": current_day,
		"current_area": String(current_area),
		"progress_phase": progress_phase,
		"player_state": player_state.duplicate(true),
	}


func restore_from_save_data(data: Dictionary) -> void:
	set_current_day(int(data.get("day", FIRST_DAY)))
	set_current_area(StringName(data.get("current_area", "grandma_house")))
	set_progress_phase(int(data.get("progress_phase", ProgressPhase.INTRO)) as ProgressPhase)
	player_state = data.get("player_state", {}).duplicate(true)
