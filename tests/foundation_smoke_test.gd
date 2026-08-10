extends Node


func _ready() -> void:
	GameState.start_new_game()
	assert(GameState.current_day == 1)
	GameState.set_current_area(&"river")
	var saved_state := GameState.to_save_data()
	GameState.start_new_game()
	GameState.restore_from_save_data(saved_state)
	assert(GameState.current_area == &"river")

	GameClock.set_time(4, 59)
	assert(GameClock.get_period() == GameClock.DayPeriod.NIGHT)
	GameClock.advance_minutes(1)
	assert(GameClock.get_period() == GameClock.DayPeriod.MORNING)
	GameClock.set_time(23, 59)
	GameClock.advance_minutes(1)
	assert(GameClock.get_time_text() == "00:00")

	print("Foundation smoke test passed.")
	get_tree().quit(0)
