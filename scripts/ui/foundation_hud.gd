extends CanvasLayer

@onready var day_label: Label = %DayLabel
@onready var time_label: Label = %TimeLabel


func _ready() -> void:
	CalendarManager.day_changed.connect(_refresh)
	GameClock.minute_changed.connect(_refresh)
	GameClock.period_changed.connect(_refresh)
	_refresh()


func _refresh(_unused: Variant = null) -> void:
	day_label.text = "Day %d / 30" % CalendarManager.day_index
	time_label.text = "%s  %s" % [GameClock.get_time_text(), GameClock.get_period()]
