class_name DayRecordRecorder
extends Node


func _ready() -> void:
	EventManager.event_completed.connect(DiaryManager.record_event)
	YokaiManager.stage_changed.connect(_on_yokai_stage_changed)
	GameState.area_changed.connect(DiaryManager.record_location)
	if is_instance_valid(GameState.player):
		GameState.player.bug_catch_succeeded.connect(DiaryManager.record_insect)
	for npc in get_tree().get_nodes_in_group("npc"):
		_connect_npc(npc)
	get_tree().node_added.connect(_on_node_added)
	DiaryManager.record_location(GameState.current_area_id)


func _on_yokai_stage_changed(yokai_id: StringName, stage: StringName) -> void:
	if YokaiManager.get_stage_index(stage) >= YokaiManager.get_stage_index(&"SEEN"):
		DiaryManager.record_yokai(yokai_id)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("npc"):
		_connect_npc.call_deferred(node)


func _connect_npc(npc: Node) -> void:
	if npc.has_signal("interacted") and not npc.interacted.is_connected(DiaryManager.record_npc):
		npc.interacted.connect(DiaryManager.record_npc)
