class_name LocationScene
extends Node2D

@export var area_id: StringName
@export var default_spawn_id: StringName = &"default"


func _enter_tree() -> void:
	if area_id.is_empty():
		push_error("LocationScene requires an area_id.")
		return
	GameState.set_area(area_id)


func _ready() -> void:
	call_deferred("_place_player_at_entry")


func _place_player_at_entry() -> void:
	var player := GameState.player
	if not is_instance_valid(player):
		return
	var requested_spawn := SceneTransitionManager.consume_spawn_id(default_spawn_id)
	var spawn_point := get_spawn_point(requested_spawn)
	if spawn_point == null and requested_spawn != default_spawn_id:
		spawn_point = get_spawn_point(default_spawn_id)
	if spawn_point == null:
		return
	player.global_position = spawn_point.global_position.round()
	if player.has_method("set_facing"):
		player.set_facing(spawn_point.facing)


func get_spawn_point(spawn_id: StringName) -> MapSpawnPoint:
	var nodes: Array[Node] = [self]
	while not nodes.is_empty():
		var node: Node = nodes.pop_back()
		var point := node as MapSpawnPoint
		if point != null and point.spawn_id == spawn_id:
			return point
		for child in node.get_children():
			nodes.append(child)
	return null
