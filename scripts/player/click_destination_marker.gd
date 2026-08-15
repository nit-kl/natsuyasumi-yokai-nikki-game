class_name ClickDestinationMarker
extends Node2D

const MARKER_COLOR := Color(0.96, 0.84, 0.42, 0.9)
const MARKER_SHADOW := Color(0.18, 0.15, 0.08, 0.7)


func _ready() -> void:
	top_level = true
	visible = false


func show_destination(destination: Vector2) -> void:
	global_position = destination.round()
	visible = true


func hide_destination() -> void:
	visible = false


func _draw() -> void:
	draw_line(Vector2(-7, 0), Vector2(-3, 0), MARKER_SHADOW, 3.0)
	draw_line(Vector2(3, 0), Vector2(7, 0), MARKER_SHADOW, 3.0)
	draw_line(Vector2(0, -4), Vector2(0, -2), MARKER_SHADOW, 3.0)
	draw_line(Vector2(0, 2), Vector2(0, 4), MARKER_SHADOW, 3.0)
	draw_line(Vector2(-7, -1), Vector2(-3, -1), MARKER_COLOR, 1.0)
	draw_line(Vector2(3, -1), Vector2(7, -1), MARKER_COLOR, 1.0)
	draw_line(Vector2(0, -5), Vector2(0, -3), MARKER_COLOR, 1.0)
	draw_line(Vector2(0, 1), Vector2(0, 3), MARKER_COLOR, 1.0)
