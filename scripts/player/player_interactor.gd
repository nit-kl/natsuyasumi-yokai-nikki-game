class_name PlayerInteractor
extends Area3D

signal focus_changed(interactable: Interactable)
signal interaction_performed(interactable: Interactable)

var current_interactable: Interactable


func _physics_process(_delta: float) -> void:
	_set_current_interactable(_find_nearest_interactable())


func _unhandled_input(event: InputEvent) -> void:
	if (
		DialogueManager.is_active
		or DayFlowManager.is_summary_active
		or DiaryManager.is_editing
		or GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE
	):
		return
	if not event.is_action_pressed("interact") or event.is_echo():
		return
	if not is_instance_valid(current_interactable):
		return
	if not current_interactable.can_interact(self):
		return

	current_interactable.interact(self)
	interaction_performed.emit(current_interactable)
	get_viewport().set_input_as_handled()


func _find_nearest_interactable() -> Interactable:
	var nearest: Interactable
	var nearest_distance_squared := INF

	for area in get_overlapping_areas():
		if not area is Interactable:
			continue
		var interactable := area as Interactable
		if not interactable.can_interact(self):
			continue
		var distance_squared := global_position.distance_squared_to(interactable.global_position)
		if distance_squared < nearest_distance_squared:
			nearest = interactable
			nearest_distance_squared = distance_squared

	return nearest


func _set_current_interactable(next_interactable: Interactable) -> void:
	if next_interactable == current_interactable:
		return
	current_interactable = next_interactable
	focus_changed.emit(current_interactable)
