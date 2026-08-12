class_name EventAction
extends Resource

enum Type {
	SET_FLAG,
	CLEAR_FLAG,
	SET_YOKAI_STAGE,
}

@export var type: Type = Type.SET_FLAG
@export var target_id: StringName
@export var value: StringName


func execute() -> bool:
	if target_id.is_empty():
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
	return false
