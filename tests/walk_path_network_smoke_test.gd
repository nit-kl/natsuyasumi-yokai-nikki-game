extends Node

const WalkPathNetwork = preload("res://scripts/maps/walk_path_network_2d.gd")


func _ready() -> void:
	var network := WalkPathNetwork.new()
	var main := Line2D.new()
	main.points = PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(200, 0)])
	var branch := Line2D.new()
	branch.points = PackedVector2Array([Vector2(100, 0), Vector2(100, 100)])
	network.add_child(main)
	network.add_child(branch)
	add_child(network)
	await get_tree().process_frame

	if network.get_closest_point(Vector2(40, 30)) != Vector2(40, 0):
		_fail("Off-path positions should project onto the authored stroll path.")
		return
	var route := network.find_route(Vector2(10, 20), Vector2(110, 90))
	if route.size() < 3 or not route.has(Vector2(100, 0)) or route[-1] != Vector2(100, 90):
		_fail("A route should use the shared junction and finish at the projected destination.")
		return
	var constrained := network.constrain_step(Vector2(20, 0), Vector2.DOWN, 10.0)
	if constrained != Vector2(20, 0):
		_fail("Movement perpendicular to a path must not enter background scenery.")
		return
	constrained = network.constrain_step(Vector2(20, 0), Vector2.RIGHT, 10.0)
	if not constrained.is_equal_approx(Vector2(30, 0)):
		_fail("Movement along a path should advance normally.")
		return
	constrained = network.constrain_step(Vector2(100, 0), Vector2.DOWN, 10.0)
	if not constrained.is_equal_approx(Vector2(100, 10)):
		_fail("Directional input at a junction should select the matching branch.")
		return
	var nearby := Line2D.new()
	nearby.points = PackedVector2Array([Vector2(0, 12), Vector2(80, 12)])
	network.add_child(nearby)
	network._rebuild_graph()
	constrained = network.constrain_step(Vector2(20, 0), Vector2.DOWN, 10.0)
	if constrained != Vector2(20, 0):
		_fail("Perpendicular input must not jump to a nearby unconnected path.")
		return
	get_tree().quit(0)


func _fail(message: String) -> void:
	push_error(message)
	get_tree().quit(1)
