class_name EventAction
extends Resource

enum Type {
	SET_FLAG,
	CLEAR_FLAG,
	SET_YOKAI_STAGE,
	ADVANCE_TIME_TO,
}

@export var type: Type = Type.SET_FLAG
@export var target_id: StringName
@export var value: StringName
@export_range(0, 1439, 1) var target_time_minutes: int = 0


func execute() -> bool:
	if type != Type.ADVANCE_TIME_TO and target_id.is_empty():
		return false
	match type:
		Type.SET_FLAG:
			WorldState.set_flag(target_id)
			return true
		Type.CLEAR_FLAG:
			WorldState.clear_flag(target_id)
			return true
		Type.SET_YOKAI_STAGE:
			return YokaiManager.set_stage(target_id, value)
		Type.ADVANCE_TIME_TO:
			if target_time_minutes <= GameClock.time_minutes:
				return false
			GameClock.set_time_minutes(target_time_minutes)
			return true
	return false
