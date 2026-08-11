class_name DiaryEntry
extends Resource

@export var day := 1
@export var title := ""
@export_multiline var body := ""
@export var memory_ids: Array[StringName] = []


func is_valid() -> bool:
	return day > 0 and not title.is_empty() and not body.is_empty()


func to_save_data() -> Dictionary:
	var ids: Array[String] = []
	for memory_id in memory_ids:
		ids.append(String(memory_id))
	return {
		"day": day,
		"title": title,
		"body": body,
		"memory_ids": ids,
	}


func restore_from_save_data(data: Dictionary) -> void:
	day = maxi(int(data.get("day", 1)), 1)
	title = String(data.get("title", "夏の一日"))
	body = String(data.get("body", ""))
	memory_ids.clear()
	for memory_id in data.get("memory_ids", []):
		memory_ids.append(StringName(memory_id))

