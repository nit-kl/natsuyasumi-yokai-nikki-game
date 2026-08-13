class_name DayRecordRecorder
extends Node


func _ready() -> void:
	if not EventManager.event_completed.is_connected(DiaryManager.record_event):
		EventManager.event_completed.connect(DiaryManager.record_event)
	if not YokaiManager.stage_changed.is_connected(_on_yokai_stage_changed):
		YokaiManager.stage_changed.connect(_on_yokai_stage_changed)
	if not GameState.area_changed.is_connected(DiaryManager.record_location):
		GameState.area_changed.connect(DiaryManager.record_location)
	if is_instance_valid(GameState.player):
		GameState.player.bug_catch_succeeded.connect(DiaryManager.record_insect)
	_connect_existing_npcs()
	_connect_existing_npcs.call_deferred()
	get_tree().node_added.connect(_on_node_added)
	DiaryManager.record_location(GameState.current_area_id)


func _on_yokai_stage_changed(yokai_id: StringName, stage: StringName) -> void:
	if YokaiManager.get_stage_index(stage) >= YokaiManager.get_stage_index(&"SEEN"):
		DiaryManager.record_yokai(yokai_id)


func _on_node_added(node: Node) -> void:
	if node is NPC:
		_connect_npc.call_deferred(node)


func _connect_npc(npc: Node) -> void:
	if npc.has_signal("interacted") and not npc.interacted.is_connected(DiaryManager.record_npc):
		npc.interacted.connect(DiaryManager.record_npc)


func _connect_existing_npcs() -> void:
	var nodes: Array[Node] = [get_tree().root]
	while not nodes.is_empty():
		var node: Node = nodes.pop_back()
		if node is NPC:
			_connect_npc(node)
		for child in node.get_children():
			nodes.append(child)
