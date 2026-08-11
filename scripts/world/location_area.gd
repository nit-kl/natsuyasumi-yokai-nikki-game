class_name LocationArea
extends Area3D

@export var area_id: StringName


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is ThirdPersonController:
		GameState.set_current_area(area_id)

