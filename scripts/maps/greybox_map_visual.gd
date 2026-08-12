class_name GreyboxMapVisual
extends Node2D

enum Layout { GRANDMA_HOUSE, HOME_OUTDOOR, RIVER }

@export var layout := Layout.GRANDMA_HOUSE


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match layout:
		Layout.GRANDMA_HOUSE:
			_draw_house()
		Layout.HOME_OUTDOOR:
			_draw_outdoor()
		Layout.RIVER:
			_draw_river()


func _draw_house() -> void:
	draw_rect(Rect2(32, 32, 576, 296), Color("c8b47b"))
	_draw_tile_grid(Rect2(48, 48, 352, 176), Color("b7a56d"), 32)
	draw_rect(Rect2(416, 48, 176, 176), Color("96724e"))
	draw_rect(Rect2(48, 240, 544, 56), Color("704b32"))
	# Chabudai, kitchen counter, futon, and engawa are layout markers only.
	draw_circle(Vector2(224, 136), 34.0, Color("765239"))
	draw_rect(Rect2(448, 72, 112, 28), Color("5f5145"))
	draw_rect(Rect2(72, 72, 72, 112), Color("d7d0ac"))
	draw_rect(Rect2(48, 224, 544, 4), Color("e7dfbf"))
	_draw_label(Vector2(48, 24), "GRANDMA HOUSE — GREYBOX / NO PRODUCTION TILES")
	_draw_label(Vector2(184, 140), "LIVING")
	_draw_label(Vector2(456, 140), "KITCHEN")
	_draw_label(Vector2(72, 132), "BEDROOM")
	_draw_label(Vector2(272, 274), "ENGAWA / EXIT")


func _draw_outdoor() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("80aa63"))
	draw_rect(Rect2(0, 148, 640, 72), Color("bca277"))
	draw_rect(Rect2(240, 0, 160, 112), Color("74523b"))
	draw_rect(Rect2(256, 16, 128, 80), Color("b69b72"))
	draw_rect(Rect2(272, 96, 96, 28), Color("6c4b31"))
	# Rice rows and garden patches communicate the intended rural rhythm.
	for x in range(24, 224, 24):
		draw_line(Vector2(x, 240), Vector2(x, 344), Color("5f8b4e"), 5.0)
	for x in range(432, 616, 32):
		draw_circle(Vector2(x, 280), 10.0, Color("557d42"))
	_draw_label(Vector2(12, 24), "HOME OUTDOOR — GREYBOX / NO PRODUCTION TILES")
	_draw_label(Vector2(276, 60), "HOUSE")
	_draw_label(Vector2(280, 190), "COUNTRY ROAD")
	_draw_label(Vector2(468, 328), "TO RIVER (future #027)")


func _draw_river() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("789d59"))
	draw_rect(Rect2(0, 48, 640, 152), Color("397d91"))
	draw_rect(Rect2(0, 48, 640, 16), Color("807859"))
	draw_rect(Rect2(0, 184, 640, 24), Color("8c815d"))
	draw_rect(Rect2(0, 224, 640, 80), Color("b59d72"))
	for x in range(24, 640, 56):
		draw_circle(Vector2(x, 196), 8.0, Color("6b685b"))
	for x in range(32, 640, 64):
		draw_line(Vector2(x, 88), Vector2(x + 24, 88), Color("82b3bc"), 2.0)
		draw_line(Vector2(x + 12, 144), Vector2(x + 40, 144), Color("82b3bc"), 2.0)
	_draw_label(Vector2(12, 24), "RIVER — GREYBOX / NO PRODUCTION TILES")
	_draw_label(Vector2(272, 128), "WATER")
	_draw_label(Vector2(272, 272), "RIVERBANK PATH")
	_draw_label(Vector2(12, 336), "TO HOME")


func _draw_tile_grid(rect: Rect2, color: Color, tile_size: int) -> void:
	draw_rect(rect, color)
	for x in range(int(rect.position.x), int(rect.end.x) + 1, tile_size):
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color(color, 0.65), 1.0)
	for y in range(int(rect.position.y), int(rect.end.y) + 1, tile_size):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color(color, 0.65), 1.0)


func _draw_label(position: Vector2, text: String) -> void:
	draw_string(ThemeDB.fallback_font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("29251e"))
