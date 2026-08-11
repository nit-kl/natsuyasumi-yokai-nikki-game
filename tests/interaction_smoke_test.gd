extends Node

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func _ready() -> void:
	var player := PLAYER_SCENE.instantiate() as ThirdPersonController
	add_child(player)

	var target := Interactable.new()
	target.interaction_text = "Test interaction"
	target.collision_layer = 2
	target.collision_mask = 0
	target.position = Vector3(0, 1, -1)

	var target_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.5
	target_shape.shape = sphere
	target.add_child(target_shape)
	add_child(target)

	for _frame in range(4):
		await get_tree().physics_frame

	var interactor := player.get_node("InteractionDetector") as PlayerInteractor
	assert(interactor.current_interactable == target)

	var interaction_count := [0]
	target.interacted.connect(func(_source: Node) -> void: interaction_count[0] += 1)
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	interactor._unhandled_input(event)
	assert(interaction_count[0] == 1)

	print("Interaction smoke test passed.")
	get_tree().quit(0)
