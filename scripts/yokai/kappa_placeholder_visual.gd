extends Node2D


func _draw() -> void:
	# Production Spriteではない。Reference Sheetからの切り出しも行わない。
	draw_circle(Vector2(0, -6), 8.0, Color("526d46"))
	draw_circle(Vector2(0, -13), 5.0, Color("d4cf9a"))
	draw_rect(Rect2(-7, 0, 14, 8), Color("405b3d"))
