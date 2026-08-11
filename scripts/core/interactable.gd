class_name Interactable
extends Area3D

signal interacted(interactor: Node)

@export_multiline var interaction_text := "Interact"
@export var interaction_enabled := true


func get_interaction_text() -> String:
	return interaction_text


func can_interact(_interactor: Node) -> bool:
	return interaction_enabled and is_visible_in_tree()


func interact(interactor: Node) -> void:
	if can_interact(interactor):
		interacted.emit(interactor)

