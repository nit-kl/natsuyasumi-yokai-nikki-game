extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var result_label: Label = %ResultLabel
@onready var hide_timer: Timer = %HideTimer

var _panel_tween: Tween


func _ready() -> void:
	panel.visible = false
	BugCatchingManager.insect_caught.connect(_on_insect_caught)
	hide_timer.timeout.connect(_on_hide_timer_timeout)


func _on_insect_caught(insect: InsectData, total_for_species: int) -> void:
	if _panel_tween != null:
		_panel_tween.kill()
	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	panel.pivot_offset = panel.size * 0.5
	result_label.text = "%s　×%d" % [insect.display_name, total_for_species]
	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.tween_property(panel, "modulate:a", 1.0, 0.16)
	_panel_tween.tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	if _panel_tween != null:
		_panel_tween.kill()
	_panel_tween = create_tween()
	_panel_tween.tween_property(panel, "modulate:a", 0.0, 0.22)
	_panel_tween.tween_callback(panel.hide)
