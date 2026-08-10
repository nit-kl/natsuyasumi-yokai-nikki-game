extends Node


func _ready() -> void:
	GameClock.day_ended.connect(_on_day_ended)


func _on_day_ended() -> void:
	GameState.advance_day()

