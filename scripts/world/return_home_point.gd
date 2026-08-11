class_name ReturnHomePoint
extends Interactable


func _ready() -> void:
	interaction_text = "一日を終える"
	GameState.phase_changed.connect(_on_phase_changed)
	_update_availability()


func can_interact(interactor: Node) -> bool:
	return DayFlowManager.can_complete_day() and super.can_interact(interactor)


func interact(interactor: Node) -> void:
	if not can_interact(interactor):
		return
	super.interact(interactor)
	DayFlowManager.complete_day()


func _on_phase_changed(_phase: GameState.ProgressPhase) -> void:
	_update_availability()


func _update_availability() -> void:
	var should_enable := GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME
	visible = should_enable
	interaction_enabled = should_enable
	collision_layer = 2 if should_enable else 0
