extends Node

const KAPPA_EVENT: EventDefinition = preload("res://resources/events/kappa_first_glimpse.tres")


func _ready() -> void:
	EventManager.reset_history()
	assert(KAPPA_EVENT.is_valid())
	assert(EventManager.register_event(KAPPA_EVENT))

	var morning_candidates := EventManager.get_candidates(&"river", 7 * 60)
	assert(morning_candidates.size() == 1)
	assert(morning_candidates[0] == KAPPA_EVENT)
	assert(EventManager.get_candidates(&"village_road", 7 * 60).is_empty())
	assert(EventManager.get_candidates(&"river", 22 * 60).is_empty())

	assert(EventManager.try_trigger(KAPPA_EVENT, &"river", 7 * 60))
	assert(EventManager.has_triggered(&"kappa_first_glimpse"))
	assert(EventManager.get_trigger_count(&"kappa_first_glimpse") == 1)
	assert(not EventManager.try_trigger(KAPPA_EVENT, &"river", 7 * 60))
	assert(EventManager.get_candidates(&"river", 7 * 60).is_empty())

	var save_data := EventManager.to_save_data()
	EventManager.reset_history()
	assert(not EventManager.has_triggered(&"kappa_first_glimpse"))
	EventManager.restore_from_save_data(save_data)
	assert(EventManager.has_triggered(&"kappa_first_glimpse"))

	print("Event manager smoke test passed.")
	get_tree().quit(0)

