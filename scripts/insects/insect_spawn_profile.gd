class_name InsectSpawnProfile
extends Resource

@export var insect_scene: PackedScene
@export var insect_data: InsectData
@export_range(0, 8, 1) var minimum_count: int = 0
@export_range(0, 8, 1) var maximum_count: int = 1
@export var guarantee_on_day_one: bool = false
@export var starts_moving: bool = false
@export var suppress_after_daily_catch: bool = true


func is_valid_profile() -> bool:
	return insect_scene != null \
		and insect_data != null \
		and insect_data.is_valid_insect() \
		and minimum_count >= 0 \
		and maximum_count >= minimum_count


func get_spawn_count(rng: RandomNumberGenerator, day_index: int) -> int:
	if not is_valid_profile():
		return 0
	var count := rng.randi_range(minimum_count, maximum_count)
	if guarantee_on_day_one and day_index == CalendarManager.FIRST_DAY:
		count = maxi(count, 1)
	return count
