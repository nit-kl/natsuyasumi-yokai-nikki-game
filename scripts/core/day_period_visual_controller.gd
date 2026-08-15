class_name DayPeriodVisualController
extends CanvasModulate

@export var palette: DayPeriodPalette
@export_range(0.0, 10.0, 0.1) var transition_seconds: float = 3.0

var _transition_tween: Tween


func _ready() -> void:
	GameClock.period_changed.connect(apply_period)
	apply_period(GameClock.get_period(), true)


func apply_period(period: StringName, immediate: bool = false) -> void:
	if palette == null:
		return
	var target_color := palette.get_color(period)
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = null
	if immediate or is_zero_approx(transition_seconds):
		color = target_color
		return
	if color.is_equal_approx(target_color):
		return
	_transition_tween = create_tween()
	_transition_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_transition_tween.tween_property(self, "color", target_color, transition_seconds)
	_transition_tween.finished.connect(_on_transition_finished)


func _on_transition_finished() -> void:
	_transition_tween = null
