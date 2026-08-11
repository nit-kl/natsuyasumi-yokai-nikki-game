class_name VegetationBreeze
extends Node3D

@export_range(0.0, 2.0, 0.01) var amplitude_degrees := 0.3
@export_range(0.01, 1.0, 0.01) var frequency_hz := 0.12
@export_range(0.02, 0.5, 0.01) var update_interval_seconds := 0.08

var target_count: int:
	get:
		return _targets.size()

var _targets: Array[Node3D] = []
var _rest_rotations: Array[Vector3] = []
var _elapsed := 0.0
var _update_accumulator := 0.0


func _ready() -> void:
	for child in get_children():
		var target := child as Node3D
		if target == null:
			continue
		_targets.append(target)
		_rest_rotations.append(target.rotation)
	set_process(not _targets.is_empty() and amplitude_degrees > 0.0)


func _process(delta: float) -> void:
	_elapsed += delta
	_update_accumulator += delta
	if _update_accumulator < update_interval_seconds:
		return
	_update_accumulator = 0.0
	for index in _targets.size():
		var phase := float(index) * 1.618
		var variation := 0.78 + float(index % 5) * 0.055
		var sway := sin(_elapsed * TAU * frequency_hz + phase)
		var tilt := deg_to_rad(amplitude_degrees * variation * sway)
		_targets[index].rotation = _rest_rotations[index] + Vector3(tilt, 0.0, tilt * 0.55)


func _exit_tree() -> void:
	for index in mini(_targets.size(), _rest_rotations.size()):
		if is_instance_valid(_targets[index]):
			_targets[index].rotation = _rest_rotations[index]
