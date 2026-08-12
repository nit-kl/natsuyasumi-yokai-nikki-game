class_name MapDoorway
extends Interactable

@export_file("*.tscn") var destination_scene: String
@export var destination_spawn_id: StringName = &"default"


func can_interact(actor: Node) -> bool:
	return super.can_interact(actor) \
		and actor is CharacterBody2D \
		and not destination_scene.is_empty() \
		and ResourceLoader.exists(destination_scene, "PackedScene")


func interact(actor: Node) -> void:
	if not can_interact(actor):
		return
	super.interact(actor)
	interaction_enabled = false
	# Scene replacement must happen after the input callback has returned.
	SceneTransitionManager.call_deferred("change_scene", destination_scene, destination_spawn_id)
