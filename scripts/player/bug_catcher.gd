class_name BugCatcher
extends Area2D

signal tool_used()
signal catch_succeeded(insect_id: StringName)
signal catch_missed()

@export_range(0.0, 2.0, 0.05) var use_cooldown_seconds: float = 0.35
@export_range(0.0, 64.0, 1.0) var facing_offset: float = 18.0

var _actor: CharacterBody2D
var _cooldown_remaining: float = 0.0
var _nearby_insects: Array[Node] = []


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if _actor != null and _actor.has_signal("facing_changed"):
		_actor.facing_changed.connect(_on_facing_changed)
		_on_facing_changed(_actor.facing)


func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_tool") and can_use_tool():
		attempt_catch()
		get_viewport().set_input_as_handled()


func can_use_tool() -> bool:
	return (
		_cooldown_remaining <= 0.0
		and not GameState.is_paused
		and _actor != null
		and not bool(_actor.get("movement_locked"))
	)


func attempt_catch() -> bool:
	if not can_use_tool():
		return false
	_nearby_insects = _nearby_insects.filter(is_instance_valid)
	var insect := select_nearest_insect(_nearby_insects, global_position)
	return _perform_attempt(insect)


func attempt_catch_target(insect: Insect) -> bool:
	if not can_use_tool() or not is_instance_valid(insect) or insect.state == Insect.State.CAUGHT:
		return false
	_nearby_insects = _nearby_insects.filter(is_instance_valid)
	if not _nearby_insects.has(insect):
		return false
	return _perform_attempt(insect)


func _perform_attempt(insect: Insect) -> bool:
	_cooldown_remaining = use_cooldown_seconds
	tool_used.emit()
	if insect == null or not insect.request_catch(_actor):
		catch_missed.emit()
		return false
	var insect_id: StringName = insect.get_insect_id()
	insect.confirm_caught()
	_nearby_insects.erase(insect)
	catch_succeeded.emit(insect_id)
	return true


static func select_nearest_insect(candidates: Array[Node], origin: Vector2) -> Insect:
	var nearest: Insect
	var nearest_distance := INF
	for candidate in candidates:
		if not candidate is Insect or candidate.state == Insect.State.CAUGHT:
			continue
		var distance := origin.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


func _on_body_entered(body: Node2D) -> void:
	if body is Insect and not _nearby_insects.has(body):
		_nearby_insects.append(body)


func _on_body_exited(body: Node2D) -> void:
	_nearby_insects.erase(body)


func _on_facing_changed(value: StringName) -> void:
	if _actor != null and _actor.has_method("get_facing_vector"):
		position = _actor.get_facing_vector(value) * facing_offset
