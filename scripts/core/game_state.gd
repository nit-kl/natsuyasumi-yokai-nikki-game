extends Node

signal phase_changed(phase: StringName)
signal area_changed(area_id: StringName)
signal pause_changed(is_paused: bool)

const PHASE_EXPLORATION: StringName = &"exploration"
const DEFAULT_AREA: StringName = &"foundation_test"

var current_phase: StringName = PHASE_EXPLORATION
var current_area_id: StringName = DEFAULT_AREA
var player: CharacterBody2D
var is_paused: bool = false


func set_phase(value: StringName) -> void:
	if value == current_phase:
		return
	current_phase = value
	phase_changed.emit(current_phase)


func set_area(value: StringName) -> void:
	if value == current_area_id:
		return
	current_area_id = value
	area_changed.emit(current_area_id)


func register_player(value: CharacterBody2D) -> void:
	player = value


func set_paused(value: bool) -> void:
	if value == is_paused:
		return
	is_paused = value
	pause_changed.emit(is_paused)


func serialize() -> Dictionary:
	return {
		"phase": String(current_phase),
		"area_id": String(current_area_id),
	}


func deserialize(data: Dictionary) -> void:
	set_phase(StringName(data.get("phase", PHASE_EXPLORATION)))
	set_area(StringName(data.get("area_id", DEFAULT_AREA)))
