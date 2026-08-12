extends Camera2D

@export var pixel_snap_enabled: bool = true


func _process(_delta: float) -> void:
	if pixel_snap_enabled:
		global_position = global_position.round()
