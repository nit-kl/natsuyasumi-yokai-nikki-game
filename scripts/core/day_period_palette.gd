class_name DayPeriodPalette
extends Resource

@export var morning := Color("fff0d2")
@export var daytime := Color("fffaf2")
@export var evening := Color("f2ae7d")
@export var night := Color("7888ad")


func get_color(period: StringName) -> Color:
	match period:
		&"morning":
			return morning
		&"evening":
			return evening
		&"night":
			return night
		_:
			return daytime
