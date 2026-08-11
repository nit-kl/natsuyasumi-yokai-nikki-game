extends Node

const WORLD_SCENE := preload("res://scenes/world/vertical_slice_graybox.tscn")


func _ready() -> void:
	var world := WORLD_SCENE.instantiate()
	add_child(world)

	assert(world.has_node("GrandmaHouse"))
	assert(world.has_node("Terrain/VillageRoad"))
	assert(world.has_node("River/Bridge"))
	assert(world.has_node("Player"))
	assert(world.has_node("GrandmaHouse/Grandma"))
	assert(world.has_node("River/ObservationPoint"))
	assert(world.has_node("Insects/HouseRoadCicada"))
	assert(world.has_node("Insects/RiceFieldCicada"))
	assert(world.has_node("Insects/RiverRoadCicada"))
	assert(world.has_node("River/KappaEventTrigger"))
	assert(world.has_node("River/KappaGlimpse/VisualRoot"))
	assert(world.has_node("GrandmaHouse/ReturnHomePoint"))

	var house_floor := world.get_node("GrandmaHouse/Floor") as Node3D
	var river_water := world.get_node("River/Water") as Node3D
	var player := world.get_node("Player") as ThirdPersonController
	assert(player != null)
	var route_length := house_floor.global_position.distance_to(river_water.global_position)
	assert(route_length > 30.0 and route_length < 50.0)

	var locations := [
		world.get_node("LocationAreas/GrandmaHouseArea") as LocationArea,
		world.get_node("LocationAreas/VillageRoadArea") as LocationArea,
		world.get_node("LocationAreas/RiverArea") as LocationArea,
	]
	assert(locations[0].area_id == &"grandma_house")
	assert(locations[1].area_id == &"village_road")
	assert(locations[2].area_id == &"river")

	var grandma := world.get_node("GrandmaHouse/Grandma") as Interactable
	var river_observation := world.get_node("River/ObservationPoint") as Interactable
	assert(grandma.get_interaction_text().contains("Grandma"))
	assert(grandma is DialogueInteractable)
	assert((grandma as DialogueInteractable).dialogue.is_valid())
	assert(river_observation.get_interaction_text() == "Look at the river")
	assert(world.get_node("Insects").get_child_count() == 3)

	var event_trigger := world.get_node("River/KappaEventTrigger") as EventTrigger
	var kappa_glimpse := world.get_node("River/KappaGlimpse") as KappaGlimpse
	EventManager.reset_history()
	assert(event_trigger.event_definition.event_id == &"kappa_first_glimpse")
	assert(not kappa_glimpse.visual_root.visible)
	assert(EventManager.try_trigger(event_trigger.event_definition, &"river", 7 * 60))
	assert(kappa_glimpse.visual_root.visible)
	var return_home_point := world.get_node("GrandmaHouse/ReturnHomePoint") as ReturnHomePoint
	assert(return_home_point.visible)
	assert(GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME)

	print("World graybox smoke test passed.")
	get_tree().quit(0)
