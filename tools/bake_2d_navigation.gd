extends SceneTree

const REGION_PATH := NodePath("NavigationRegion2D")
const BOUNDS_PATH := NodePath("NavigationBakeBounds")
const COLLISION_ROOT_PATH := NodePath("WorldCollision")
const WORLD_COLLISION_MASK := 2
const DEFAULT_AGENT_RADIUS := 7.0
const SOURCE_GEOMETRY_GROUP := &"navigation_bake_source"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 2:
		push_error("Usage: --script res://tools/bake_2d_navigation.gd -- <scene_path> <output_resource_path>")
		quit(1)
		return
	var scene_path := String(arguments[0])
	var output_path := String(arguments[1])
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Could not load navigation source scene: %s" % scene_path)
		quit(1)
		return
	var scene_root := packed_scene.instantiate()
	var region := scene_root.get_node_or_null(REGION_PATH) as NavigationRegion2D
	var bounds := scene_root.get_node_or_null(BOUNDS_PATH) as Polygon2D
	var collision_root := scene_root.get_node_or_null(COLLISION_ROOT_PATH) as StaticBody2D
	if region == null or bounds == null or bounds.polygon.size() < 3 or collision_root == null:
		push_error("Scene must contain NavigationRegion2D, NavigationBakeBounds, and WorldCollision.")
		quit(1)
		return
	var navigation_polygon := NavigationPolygon.new()
	navigation_polygon.agent_radius = DEFAULT_AGENT_RADIUS
	navigation_polygon.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	navigation_polygon.parsed_collision_mask = WORLD_COLLISION_MASK
	navigation_polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	navigation_polygon.source_geometry_group_name = SOURCE_GEOMETRY_GROUP
	var region_inverse := region.global_transform.affine_inverse()
	var outline := PackedVector2Array()
	for point in bounds.polygon:
		outline.append(region_inverse * bounds.to_global(point))
	navigation_polygon.add_outline(outline)
	var source_geometry := NavigationMeshSourceGeometryData2D.new()
	for collision_polygon in collision_root.find_children("*", "CollisionPolygon2D", true, false):
		if collision_polygon.get_meta("navigation_bake_exclude", false):
			continue
		var obstruction := PackedVector2Array()
		for point in collision_polygon.polygon:
			obstruction.append(region_inverse * collision_polygon.to_global(point))
		source_geometry.add_obstruction_outline(obstruction)
	for collision_shape in collision_root.find_children("*", "CollisionShape2D", true, false):
		if collision_shape.get_meta("navigation_bake_exclude", false):
			continue
		var rectangle := collision_shape.shape as RectangleShape2D
		if rectangle == null:
			continue
		var half_size := rectangle.size * 0.5
		var obstruction := PackedVector2Array([
			region_inverse * collision_shape.to_global(Vector2(-half_size.x, -half_size.y)),
			region_inverse * collision_shape.to_global(Vector2(half_size.x, -half_size.y)),
			region_inverse * collision_shape.to_global(Vector2(half_size.x, half_size.y)),
			region_inverse * collision_shape.to_global(Vector2(-half_size.x, half_size.y)),
		])
		source_geometry.add_obstruction_outline(obstruction)
	NavigationServer2D.bake_from_source_geometry_data(navigation_polygon, source_geometry)
	region.navigation_polygon = navigation_polygon
	var save_error := ResourceSaver.save(navigation_polygon, output_path)
	if save_error != OK:
		push_error("Could not save baked navigation resource: %s" % output_path)
		quit(1)
		return
	scene_root.free()
	packed_scene = null
	navigation_polygon = null
	source_geometry = null
	quit(0)
