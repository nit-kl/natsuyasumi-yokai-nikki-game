extends CharacterBody2D

const PLACEHOLDER_COLOR := Color("4f86c6")
const PLACEHOLDER_OUTLINE := Color("183153")


func _ready() -> void:
	GameState.register_player(self)
	queue_redraw()


func _exit_tree() -> void:
	if GameState.player == self:
		GameState.player = null


func _draw() -> void:
	# Milestone 0 placeholder only. Replace with a separately produced sprite asset.
	draw_circle(Vector2(0, -13), 6.0, Color("f1c27d"))
	draw_rect(Rect2(-7, -7, 14, 15), PLACEHOLDER_COLOR)
	draw_rect(Rect2(-7, -7, 14, 15), PLACEHOLDER_OUTLINE, false, 1.0)
	draw_line(Vector2(-4, 8), Vector2(-4, 13), PLACEHOLDER_OUTLINE, 3.0)
	draw_line(Vector2(4, 8), Vector2(4, 13), PLACEHOLDER_OUTLINE, 3.0)
