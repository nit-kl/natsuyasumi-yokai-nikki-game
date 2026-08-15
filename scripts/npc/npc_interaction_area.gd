class_name NPCInteractionArea
extends DialogueInteractable

@export var npc: NPC


func _ready() -> void:
	if npc == null:
		npc = get_parent() as NPC


func get_interaction_text(_actor: Node) -> String:
	if npc == null or npc.get_display_name().is_empty():
		return super.get_interaction_text(_actor)
	return "%sと話す" % npc.get_display_name()


func interact(actor: Node) -> void:
	if npc != null and actor is Node2D:
		npc.stop_movement()
		npc.face_toward(actor.global_position)
	super.interact(actor)
