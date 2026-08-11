extends CanvasLayer

@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_label: Label = %ObjectiveLabel
@onready var summary_panel: PanelContainer = %SummaryPanel
@onready var summary_title: Label = %SummaryTitle
@onready var summary_body: Label = %SummaryBody


func _ready() -> void:
	objective_panel.visible = GameState.progress_phase == GameState.ProgressPhase.RETURN_HOME
	summary_panel.visible = false
	DayFlowManager.return_home_requested.connect(_on_return_home_requested)
	DayFlowManager.day_completed.connect(_on_day_completed)
	DayFlowManager.day_summary_dismissed.connect(_on_summary_dismissed)


func _unhandled_input(event: InputEvent) -> void:
	if not DayFlowManager.is_summary_active or event.is_echo():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		DayFlowManager.dismiss_day_summary()
		get_viewport().set_input_as_handled()


func _on_return_home_requested() -> void:
	objective_panel.visible = true
	objective_label.text = "It's getting late. Return to Grandma's house."


func _on_day_completed(record: DayRecord) -> void:
	objective_panel.visible = false
	summary_panel.visible = true
	summary_title.text = "Day %d Complete" % record.day
	summary_body.text = (
		"Returned at %s\nInsects caught: %d\nEvents remembered: %d\n\n[E / Space] Continue"
		% [
			record.get_end_time_text(),
			record.get_total_insects(),
			record.triggered_events.size(),
		]
	)


func _on_summary_dismissed(_record: DayRecord) -> void:
	summary_panel.visible = false
