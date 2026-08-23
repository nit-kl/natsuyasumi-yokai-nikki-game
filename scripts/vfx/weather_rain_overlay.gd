class_name WeatherRainOverlay
extends CanvasLayer

const WET_WEATHERS: Array[StringName] = [&"rain", &"thunderstorm"]

@export var rain_drop_count: int = 26
@export var thunderstorm_drop_count: int = 40
@export var rain_speed := Vector2(-18.0, 96.0)
@export var thunderstorm_speed := Vector2(-24.0, 128.0)

var _drops: Array[Dictionary] = []
var _drop_count: int = 0
var _speed := Vector2(-18.0, 96.0)
var _draw_node: Node2D


func _ready() -> void:
	layer = 3
	follow_viewport_enabled = false
	_draw_node = Node2D.new()
	_draw_node.z_as_relative = false
	add_child(_draw_node)
	_draw_node.draw.connect(_on_draw)
	if not WeatherManager.weather_changed.is_connected(_on_weather_changed):
		WeatherManager.weather_changed.connect(_on_weather_changed)
	if not GameState.area_changed.is_connected(_on_area_changed):
		GameState.area_changed.connect(_on_area_changed)
	refresh()


func _process(delta: float) -> void:
	if not visible or _drops.is_empty():
		return
	var viewport_size := get_viewport().get_visible_rect().size
	for drop in _drops:
		var position: Vector2 = drop.position + _speed * float(drop.scale) * delta
		if position.y > viewport_size.y + 8.0 or position.x < -12.0:
			position = Vector2(randf() * (viewport_size.x + 24.0), -randf() * 16.0)
		drop.position = position
	_draw_node.queue_redraw()


func refresh() -> void:
	var weather := WeatherManager.get_weather()
	var should_show := LocationCatalog.is_outdoor(GameState.current_area_id) and WET_WEATHERS.has(weather)
	visible = should_show
	set_process(should_show)
	if not should_show:
		_drops.clear()
		if _draw_node != null:
			_draw_node.queue_redraw()
		return
	_drop_count = thunderstorm_drop_count if weather == &"thunderstorm" else rain_drop_count
	_speed = thunderstorm_speed if weather == &"thunderstorm" else rain_speed
	_rebuild_drops()


func _rebuild_drops() -> void:
	var viewport_size := Vector2(640, 360)
	if is_inside_tree():
		viewport_size = get_viewport().get_visible_rect().size
	_drops.clear()
	for _index in _drop_count:
		_drops.append({
			"position": Vector2(randf() * viewport_size.x, randf() * viewport_size.y),
			"length": randf_range(5.0, 9.0),
			"scale": randf_range(0.75, 1.2),
		})
	if _draw_node != null:
		_draw_node.queue_redraw()


func _on_draw() -> void:
	if not visible:
		return
	var color := Color(0.82, 0.90, 0.97, 0.42)
	if WeatherManager.get_weather() == &"thunderstorm":
		color = Color(0.78, 0.86, 0.96, 0.5)
	for drop in _drops:
		var start: Vector2 = drop.position
		var stop := start + _speed.normalized() * float(drop.length)
		_draw_node.draw_line(start.round(), stop.round(), color, 1.0)


func _on_weather_changed(_weather: StringName) -> void:
	refresh()


func _on_area_changed(_area_id: StringName) -> void:
	refresh()
