class_name Interactable
extends Area2D

signal interacted(actor: Node)

@export var interaction_text: String = "調べる"
@export var interaction_priority: int = 0
@export var interaction_enabled: bool = true


func can_interact(_actor: Node) -> bool:
	return interaction_enabled


func get_interaction_text(_actor: Node) -> String:
	return interaction_text


func interact(actor: Node) -> void:
	if can_interact(actor):
		interacted.emit(actor)
