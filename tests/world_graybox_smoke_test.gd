extends Node

const WORLD_SCENE := preload("res://scenes/world/vertical_slice_graybox.tscn")


func _ready() -> void:
	var world := WORLD_SCENE.instantiate()
	add_child(world)

	assert(world.has_node("GrandmaHouse"))
	assert(world.has_node("GrandmaHouse/GrandmaExterior"))
	var grandma_exterior := world.get_node("GrandmaHouse/GrandmaExterior") as Node3D
	assert(grandma_exterior.find_child("FrontGable", true, false) != null)
	assert(grandma_exterior.find_child("NorenLeft", true, false) != null)
	assert(world.has_node("GrandmaHouse/YardProps"))
	var yard_props := world.get_node("GrandmaHouse/YardProps") as Node3D
	assert(yard_props.find_child("EntryStone1", true, false) != null)
	assert(yard_props.find_child("GardenSoil1", true, false) != null)
	assert(yard_props.find_child("HydrangeaBloom1", true, false) != null)
	assert(world.has_node("GrandmaHouse/GrandmaInterior"))
	assert(world.has_node("Terrain/VillageRoad"))
	assert(world.has_node("Terrain/VillageRoadBend"))
	assert(world.has_node("Terrain/VillageRoadRiverApproach"))
	assert(world.has_node("Terrain/RiceFieldLeftLower"))
	assert(world.has_node("Terrain/RiceFieldRightLower"))
	assert(world.has_node("Terrain/IrrigationChannelLeftLower"))
	assert(world.has_node("Terrain/CrossFieldFootpathLeft"))
	assert(world.has_node("Terrain/CountryRoadDetails"))
	var road_south := world.get_node("Terrain/VillageRoad") as CSGBox3D
	var road_bend := world.get_node("Terrain/VillageRoadBend") as CSGBox3D
	var road_river := world.get_node("Terrain/VillageRoadRiverApproach") as CSGBox3D
	assert(absf(road_south.rotation.y) > 0.01)
	assert(road_south.rotation.y * road_bend.rotation.y < 0.0)
	assert(road_bend.rotation.y * road_river.rotation.y < 0.0)
	var upper_field := world.get_node("Terrain/RiceFieldLeft") as CSGBox3D
	var lower_field := world.get_node("Terrain/RiceFieldLeftLower") as CSGBox3D
	assert(lower_field.position.z < upper_field.position.z)
	assert(world.has_node("River/Bridge"))
	assert(world.has_node("River/BridgeVisual"))
	assert(world.has_node("River/RiverbankProps"))
	assert(world.has_node("River/WaterWest"))
	assert(world.has_node("River/WaterEast"))
	assert(world.has_node("River/KappaShallowCove"))
	assert(world.has_node("River/KappaSandbar"))
	assert(world.has_node("River/LookoutStoneNear"))
	assert(world.has_node("Player"))
	assert(world.has_node("GrandmaHouse/Grandma"))
	assert(world.has_node("GrandmaHouse/Grandma/GrandmaVisual/GrandmaModel"))
	assert(world.has_node("River/ObservationPoint"))
	assert(world.has_node("Insects/HouseRoadCicada"))
	assert(world.has_node("Insects/RiceFieldCicada"))
	assert(world.has_node("Insects/RiverRoadCicada"))
	assert(world.has_node("River/KappaEventTrigger"))
	assert(world.has_node("River/KappaGlimpse/VisualRoot"))
	assert(world.has_node("River/KappaGlimpse/VisualRoot/KappaModel"))
	assert(world.has_node("River/KappaGlimpse/VisualRoot/Ripple"))
	assert(world.has_node("River/KappaGlimpse/DiveSplash"))
	assert(world.has_node("EveningMotes"))
	assert(world.has_node("GrandmaHouse/ReturnHomePoint"))
	assert(world.has_node("Landmarks/UtilityPoleVisualNearHouse"))
	assert(world.has_node("Landmarks/UtilityPoleVisualMidway"))
	assert(world.has_node("Landmarks/UtilityPoleVisualNearRiver"))
	assert(world.has_node("Landmarks/UtilityWireRun"))
	assert(world.has_node("Vegetation/HouseTreeVariant"))
	assert(world.has_node("Vegetation/HouseBamboo"))
	assert(world.has_node("Vegetation/HouseShrubs"))
	assert(world.has_node("Vegetation/HouseWildGrass"))
	var vegetation := world.get_node("Vegetation") as VegetationBreeze
	var rice_left := world.get_node("Terrain/RicePlantsLeft") as VegetationBreeze
	var rice_right := world.get_node("Terrain/RicePlantsRight") as VegetationBreeze
	assert(vegetation.target_count >= 18)
	assert(rice_left.target_count == 20)
	assert(rice_right.target_count == 20)

	var house_floor := world.get_node("GrandmaHouse/Floor") as Node3D
	var river_water := world.get_node("River/Water") as Node3D
	var water_west := world.get_node("River/WaterWest") as CSGBox3D
	var water_east := world.get_node("River/WaterEast") as CSGBox3D
	var player := world.get_node("Player") as ThirdPersonController
	assert(player != null)
	var route_length := house_floor.global_position.distance_to(river_water.global_position)
	assert(route_length > 30.0 and route_length < 50.0)
	assert(water_west.position.z > water_east.position.z)

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
	assert(grandma.get_interaction_text() == "おばあちゃんと話す")
	assert(grandma is DialogueInteractable)
	assert((grandma as DialogueInteractable).dialogue.is_valid())
	assert(river_observation.get_interaction_text() == "川をよく見る")
	assert(world.get_node("Insects").get_child_count() == 3)
	var grandma_visual := world.get_node("GrandmaHouse/Grandma/GrandmaVisual") as GrandmaVisual
	assert(grandma_visual.find_child("Head", true, false) != null)
	assert(grandma_visual.find_child("HairBun", true, false) != null)
	assert(grandma_visual.find_child("WaistSash", true, false) != null)
	assert(DialogueManager.start_dialogue((grandma as DialogueInteractable).dialogue))
	assert(grandma_visual.is_talking)
	DialogueManager.finish_dialogue()
	assert(not grandma_visual.is_talking)

	var event_trigger := world.get_node("River/KappaEventTrigger") as EventTrigger
	var kappa_glimpse := world.get_node("River/KappaGlimpse") as KappaGlimpse
	kappa_glimpse.visible_duration = 0.15
	EventManager.reset_history()
	assert(event_trigger.event_definition.event_id == &"kappa_first_glimpse")
	assert(not kappa_glimpse.visual_root.visible)
	assert(not kappa_glimpse.green_reflection.visible)
	assert(EventManager.try_trigger(event_trigger.event_definition, &"river", 7 * 60))
	assert(kappa_glimpse.visual_root.visible)
	assert(kappa_glimpse.ripple.scale.is_equal_approx(Vector3(0.25, 0.25, 0.25)))
	assert(kappa_glimpse.visual_root.position.y < -0.7)
	var return_home_point := world.get_node("GrandmaHouse/ReturnHomePoint") as ReturnHomePoint
	assert(return_home_point.visible)
	assert(GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME)
	await get_tree().create_timer(0.3).timeout
	assert(not kappa_glimpse.visual_root.visible)
	assert(not kappa_glimpse.is_showing)

	print("World graybox smoke test passed.")
	get_tree().quit(0)
