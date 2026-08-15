class_name InsectAreaSpawner
extends Node

@export var profile: InsectSpawnProfile
@export var spawn_points_root_path: NodePath = NodePath("SpawnPoints")


func _ready() -> void:
	# The spawner becomes ready while its Location parent is still assembling children.
	# Defer runtime entities until that setup pass has completed.
	spawn_for_current_day.call_deferred()


func spawn_for_current_day() -> Array[Insect]:
	var spawned: Array[Insect] = []
	if profile == null or not profile.is_valid_profile():
		push_warning("InsectAreaSpawner requires a valid spawn profile.")
		return spawned
	if profile.suppress_after_daily_catch and _was_caught_today(profile.insect_data.insect_id):
		return spawned
	var points := _get_spawn_points()
	if points.is_empty():
		push_warning("InsectAreaSpawner requires at least one spawn point.")
		return spawned
	var rng := RandomNumberGenerator.new()
	rng.seed = _make_daily_seed(_resolve_area_id(), CalendarManager.day_index)
	_shuffle_points(points, rng)
	var count := mini(profile.get_spawn_count(rng, CalendarManager.day_index), points.size())
	for index in range(count):
		var insect := profile.insect_scene.instantiate() as Insect
		if insect == null:
			push_warning("Insect spawn scene must instantiate an Insect.")
			break
		insect.data = profile.insect_data
		insect.starts_moving = profile.starts_moving
		insect.name = _make_insect_name(index)
		get_parent().add_child(insect)
		insect.global_position = points[index].global_position.round()
		spawned.append(insect)
	return spawned


func _get_spawn_points() -> Array[Node2D]:
	var result: Array[Node2D] = []
	var root := get_node_or_null(spawn_points_root_path)
	if root == null:
		return result
	for child in root.get_children():
		if child is Node2D:
			result.append(child as Node2D)
	result.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.name.naturalnocasecmp_to(b.name) < 0)
	return result


func _resolve_area_id() -> StringName:
	var current := get_parent()
	while current != null:
		if current is LocationScene:
			return (current as LocationScene).area_id
		current = current.get_parent()
	return GameState.current_area_id


func _was_caught_today(insect_id: StringName) -> bool:
	return DiaryManager.get_or_create_record().caught_insects.has(insect_id)


func _make_daily_seed(area_id: StringName, day_index: int) -> int:
	return absi(String("%s:%d" % [area_id, day_index]).hash())


func _shuffle_points(points: Array[Node2D], rng: RandomNumberGenerator) -> void:
	for index in range(points.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var value := points[index]
		points[index] = points[swap_index]
		points[swap_index] = value


func _make_insect_name(index: int) -> String:
	var base_name := String(profile.insect_data.insect_id).to_pascal_case()
	return base_name if index == 0 else "%s%d" % [base_name, index + 1]
