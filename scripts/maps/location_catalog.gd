class_name LocationCatalog
extends RefCounted

const SCENE_PATHS := {
	&"bedroom": "res://scenes/maps/bedroom/bedroom.tscn",
	&"grandma_house": "res://scenes/maps/grandma_house/grandma_house.tscn",
	&"home_outdoor": "res://scenes/maps/village/home_outdoor.tscn",
	&"engawa_yard": "res://scenes/maps/village/engawa_yard.tscn",
	&"paddy_road": "res://scenes/maps/village/paddy_road.tscn",
	&"irrigation_shade": "res://scenes/maps/village/irrigation_shade.tscn",
	&"river_entrance": "res://scenes/maps/river/river_entrance.tscn",
	&"river": "res://scenes/maps/river/river.tscn",
	&"foundation_test": "res://scenes/bootstrap/bootstrap.tscn",
}


static func get_scene_path(area_id: StringName) -> String:
	return String(SCENE_PATHS.get(area_id, ""))


static func has_area(area_id: StringName) -> bool:
	return SCENE_PATHS.has(area_id)
