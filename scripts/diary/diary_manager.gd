extends Node

signal diary_opened(record: DayRecord, options: Array[Dictionary])
signal entry_saved(entry: DiaryEntry)
signal entries_reset

var entries: Array[DiaryEntry] = []
var draft_options: Array[Dictionary] = []
var draft_record: DayRecord
var is_editing := false


func _ready() -> void:
	DayFlowManager.day_summary_dismissed.connect(_on_day_summary_dismissed)
	GameState.state_reset.connect(reset_entries)


func begin_entry(record: DayRecord) -> bool:
	if is_editing or record == null:
		return false
	draft_record = record
	draft_options = _build_memory_options(record)
	is_editing = true
	GameState.set_progress_phase(GameState.ProgressPhase.DIARY)
	diary_opened.emit(record, draft_options)
	return true


func save_draft(selected_indices: Array[int]) -> DiaryEntry:
	if not is_editing or draft_record == null:
		return null

	var selected := {}
	for index in selected_indices:
		if index >= 0 and index < draft_options.size():
			selected[index] = true
	if selected.is_empty():
		selected[0] = true

	var entry := DiaryEntry.new()
	entry.day = draft_record.day
	entry.title = "川で見た影" if draft_record.triggered_events.has(&"kappa_first_glimpse") else "夏の一日"
	var paragraphs: Array[String] = []
	for index in range(draft_options.size()):
		if not selected.has(index):
			continue
		var option := draft_options[index]
		entry.memory_ids.append(option["id"])
		paragraphs.append(option["text"])
	entry.body = "\n".join(paragraphs)

	entries.append(entry)
	is_editing = false
	draft_record = null
	draft_options.clear()
	GameState.set_progress_phase(GameState.ProgressPhase.DAY_COMPLETE)
	entry_saved.emit(entry)
	return entry


func get_latest_entry() -> DiaryEntry:
	if entries.is_empty():
		return null
	return entries.back()


func reset_entries() -> void:
	entries.clear()
	draft_options.clear()
	draft_record = null
	is_editing = false
	entries_reset.emit()


func to_save_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for entry in entries:
		data.append(entry.to_save_data())
	return data


func restore_from_save_data(data: Array) -> void:
	entries.clear()
	for entry_data in data:
		if not entry_data is Dictionary:
			continue
		var entry := DiaryEntry.new()
		entry.restore_from_save_data(entry_data)
		if entry.is_valid():
			entries.append(entry)


func sync_after_load() -> void:
	is_editing = false
	draft_record = null
	draft_options.clear()
	if GameState.progress_phase == GameState.ProgressPhase.DIARY:
		var record := DayRecordManager.get_latest_record()
		if record != null:
			begin_entry(record)
	elif GameState.progress_phase == GameState.ProgressPhase.DAY_COMPLETE:
		var entry := get_latest_entry()
		if entry != null:
			entry_saved.emit(entry)


func _build_memory_options(record: DayRecord) -> Array[Dictionary]:
	var options: Array[Dictionary] = [
		{
			"id": &"walk_to_river",
			"text": "おばあちゃんの家から、田んぼの道を通って川まで歩いた。",
		}
	]
	if record.get_total_insects() > 0:
		options.append({
			"id": &"caught_insects",
			"text": "道の途中で、セミを%d匹つかまえた。" % record.get_total_insects(),
		})
	if record.triggered_events.has(&"kappa_first_glimpse"):
		options.append({
			"id": &"kappa_glimpse",
			"text": "川の水面に、緑色の小さな影を見た。河童だったのかもしれない。",
		})
	return options


func _on_day_summary_dismissed(record: DayRecord) -> void:
	begin_entry(record)
