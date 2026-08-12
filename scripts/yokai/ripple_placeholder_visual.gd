extends Node2D


func _draw() -> void:
	# 水面VFX用の一時的な図形Placeholder。
	draw_arc(Vector2.ZERO, 8.0, 0.0, TAU, 24, Color("9bd4dc"), 1.0)
	draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 32, Color("72b8c5"), 1.0)
