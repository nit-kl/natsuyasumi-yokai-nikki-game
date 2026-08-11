class_name DialogueInteractable
extends Interactable

@export var dialogue: DialogueSequence


func can_interact(interactor: Node) -> bool:
	return super.can_interact(interactor) and dialogue != null and not DialogueManager.is_active


func interact(interactor: Node) -> void:
	if not can_interact(interactor):
		return
	super.interact(interactor)
	DialogueManager.start_dialogue(dialogue)

