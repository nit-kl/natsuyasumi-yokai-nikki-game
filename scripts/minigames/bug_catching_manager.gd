extends Node

signal insect_caught(insect: InsectData, total_for_species: int)
signal collection_reset

var caught_counts: Dictionary = {}


func catch_insect(insect: InsectData) -> bool:
	if insect == null or not insect.is_valid():
		return false
	var next_count := get_caught_count(insect.insect_id) + 1
	caught_counts[insect.insect_id] = next_count
	insect_caught.emit(insect, next_count)
	return true


func get_caught_count(insect_id: StringName) -> int:
	return int(caught_counts.get(insect_id, 0))


func get_total_caught() -> int:
	var total := 0
	for count in caught_counts.values():
		total += int(count)
	return total


func reset_collection() -> void:
	caught_counts.clear()
	collection_reset.emit()


func to_save_data() -> Dictionary:
	var data := {}
	for insect_id in caught_counts:
		data[String(insect_id)] = caught_counts[insect_id]
	return data


func restore_from_save_data(data: Dictionary) -> void:
	caught_counts.clear()
	for insect_id in data:
		caught_counts[StringName(insect_id)] = maxi(int(data[insect_id]), 0)

