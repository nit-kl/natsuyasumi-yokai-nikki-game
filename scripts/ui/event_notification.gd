extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var title_label: Label = %TitleLabel
@onready var hint_label: Label = %HintLabel
@onready var hide_timer: Timer = %HideTimer


func _ready() -> void:
	panel.visible = false
	EventManager.event_triggered.connect(_on_event_triggered)
	hide_timer.timeout.connect(_on_hide_timer_timeout)


func _on_event_triggered(event: EventDefinition) -> void:
	panel.visible = true
	title_label.text = event.display_name
	hint_label.text = event.hint_text
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	panel.visible = false

