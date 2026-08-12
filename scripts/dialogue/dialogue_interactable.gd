class_name DialogueInteractable
extends Interactable

@export var dialogue: DialogueResource


func can_interact(actor: Node) -> bool:
	return super.can_interact(actor) and dialogue != null and dialogue.is_valid_dialogue()


func interact(actor: Node) -> void:
	if not can_interact(actor):
		return
	var controller := get_tree().get_first_node_in_group("dialogue_controller")
	if controller == null or not controller.has_method("start_dialogue"):
		return
	controller.start_dialogue(dialogue, actor)
	super.interact(actor)
