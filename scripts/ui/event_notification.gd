extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var title_label: Label = %TitleLabel
@onready var hint_label: Label = %HintLabel
@onready var hide_timer: Timer = %HideTimer

var _notification_tween: Tween


func _ready() -> void:
	panel.visible = false
	EventManager.event_triggered.connect(_on_event_triggered)
	hide_timer.timeout.connect(_on_hide_timer_timeout)


func _on_event_triggered(event: EventDefinition) -> void:
	if _notification_tween != null:
		_notification_tween.kill()
	panel.visible = true
	panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	panel.scale = Vector2(0.96, 0.96)
	panel.pivot_offset = panel.size * 0.5
	title_label.text = event.display_name
	hint_label.text = event.hint_text
	_notification_tween = create_tween().set_parallel(true)
	_notification_tween.tween_property(panel, "modulate:a", 1.0, 0.22)
	_notification_tween.tween_property(panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	if _notification_tween != null:
		_notification_tween.kill()
	_notification_tween = create_tween()
	_notification_tween.tween_property(panel, "modulate:a", 0.0, 0.28)
	_notification_tween.tween_callback(panel.hide)
