extends Node

signal flag_changed(flag_id: StringName, enabled: bool)

var _flags: Dictionary = {}
var _discovered_locations: Dictionary = {}


func has_flag(flag_id: StringName) -> bool:
	return bool(_flags.get(flag_id, false))


func set_flag(flag_id: StringName, enabled: bool = true) -> void:
	if flag_id.is_empty() or has_flag(flag_id) == enabled:
		return
	if enabled:
		_flags[flag_id] = true
	else:
		_flags.erase(flag_id)
	flag_changed.emit(flag_id, enabled)


func clear_flag(flag_id: StringName) -> void:
	set_flag(flag_id, false)


func discover_location(location_id: StringName) -> void:
	if not location_id.is_empty():
		_discovered_locations[location_id] = true


func serialize() -> Dictionary:
	var flags: Array = _flags.keys()
	var locations: Array = _discovered_locations.keys()
	flags.sort()
	locations.sort()
	return {
		"flags": flags.map(func(value: Variant) -> String: return String(value)),
		"discovered_locations": locations.map(func(value: Variant) -> String: return String(value)),
	}


func deserialize(data: Dictionary) -> void:
	_flags.clear()
	_discovered_locations.clear()
	for flag: Variant in data.get("flags", []):
		var flag_id := StringName(flag)
		if not flag_id.is_empty():
			_flags[flag_id] = true
	for location: Variant in data.get("discovered_locations", []):
		var location_id := StringName(location)
		if not location_id.is_empty():
			_discovered_locations[location_id] = true


func reset_state() -> void:
	_flags.clear()
	_discovered_locations.clear()
