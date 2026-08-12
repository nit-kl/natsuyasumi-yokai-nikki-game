class_name DayPeriodPalette
extends Resource

@export var morning := Color("f8e5c0")
@export var daytime := Color.WHITE
@export var evening := Color("efa474")
@export var night := Color("7181ad")


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
