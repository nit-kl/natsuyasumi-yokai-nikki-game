class_name InteractionDetector
extends Area2D

signal candidate_changed(target: Node, prompt_text: String)
signal interaction_performed(target: Node)

@export_range(0.0, 64.0, 1.0) var facing_offset: float = 12.0

var current_candidate: Node
var _actor: CharacterBody2D
var _overlapping_targets: Array[Node] = []


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if _actor != null and _actor.has_signal("facing_changed"):
		_actor.facing_changed.connect(_on_facing_changed)
		_on_facing_changed(_actor.facing)


func _physics_process(_delta: float) -> void:
	refresh_candidate()


func _unhandled_input(event: InputEvent) -> void:
	if _actor != null and bool(_actor.get("movement_locked")):
		return
	if event.is_action_pressed("interact") and not GameState.is_paused:
		try_interact()
		get_viewport().set_input_as_handled()


func try_interact() -> bool:
	refresh_candidate()
	if not is_instance_valid(current_candidate):
		return false
	current_candidate.interact(_actor)
	interaction_performed.emit(current_candidate)
	refresh_candidate()
	return true


func refresh_candidate() -> void:
	_overlapping_targets = _overlapping_targets.filter(is_instance_valid)
	var actor_locked := _actor != null and bool(_actor.get("movement_locked"))
	var next_candidate: Node = null if actor_locked else select_candidate(_overlapping_targets, _actor, global_position)
	if next_candidate == current_candidate:
		return
	current_candidate = next_candidate
	var prompt_text := ""
	if is_instance_valid(current_candidate):
		prompt_text = String(current_candidate.get_interaction_text(_actor))
	candidate_changed.emit(current_candidate, prompt_text)


static func select_candidate(candidates: Array[Node], actor: Node, origin: Vector2) -> Node:
	var best_candidate: Node
	var best_distance := INF
	var best_priority := -2147483648
	for candidate in candidates:
		if not is_valid_interactable(candidate, actor):
			continue
		var candidate_2d := candidate as Node2D
		var distance := origin.distance_squared_to(candidate_2d.global_position)
		var priority_value: Variant = candidate.get("interaction_priority")
		var priority := int(priority_value) if priority_value != null else 0
		if distance < best_distance or (is_equal_approx(distance, best_distance) and priority > best_priority):
			best_candidate = candidate
			best_distance = distance
			best_priority = priority
	return best_candidate


static func is_valid_interactable(candidate: Node, actor: Node) -> bool:
	return (
		is_instance_valid(candidate)
		and candidate is Node2D
		and candidate.has_method("can_interact")
		and candidate.has_method("get_interaction_text")
		and candidate.has_method("interact")
		and bool(candidate.can_interact(actor))
	)


func _on_area_entered(area: Area2D) -> void:
	if not _overlapping_targets.has(area):
		_overlapping_targets.append(area)
	refresh_candidate()


func _on_area_exited(area: Area2D) -> void:
	_overlapping_targets.erase(area)
	refresh_candidate()


func _on_facing_changed(value: StringName) -> void:
	if _actor == null or not _actor.has_method("get_facing_vector"):
		return
	position = _actor.get_facing_vector(value) * facing_offset
