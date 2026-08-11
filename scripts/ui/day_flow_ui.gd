extends CanvasLayer

@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_step_label: Label = %ObjectiveStepLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var memory_hint_label: Label = %MemoryHintLabel
@onready var summary_panel: PanelContainer = %SummaryPanel
@onready var summary_title: Label = %SummaryTitle
@onready var summary_body: Label = %SummaryBody


func _ready() -> void:
	summary_panel.visible = false
	GameState.phase_changed.connect(_on_phase_changed)
	DayFlowManager.return_home_requested.connect(_on_return_home_requested)
	DayFlowManager.day_completed.connect(_on_day_completed)
	DayFlowManager.day_summary_dismissed.connect(_on_summary_dismissed)
	_refresh_objective(GameState.progress_phase)


func _unhandled_input(event: InputEvent) -> void:
	if not DayFlowManager.is_summary_active or event.is_echo():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		DayFlowManager.dismiss_day_summary()
		get_viewport().set_input_as_handled()


func _on_return_home_requested() -> void:
	memory_hint_label.visible = true
	memory_hint_label.text = "「川で見た影」が日記の候補に加わった"
	_play_objective_feedback()


func _on_day_completed(record: DayRecord) -> void:
	objective_panel.visible = false
	summary_panel.visible = true
	summary_title.text = "%d日目の夕暮れ" % record.day
	summary_body.text = (
		"帰宅時刻　%s\nつかまえた虫　%d匹\n心に残った出来事　%d件\n\n[E / Space] 日記を開く"
		% [
			record.get_end_time_text(),
			record.get_total_insects(),
			record.triggered_events.size(),
		]
	)


func _on_summary_dismissed(_record: DayRecord) -> void:
	summary_panel.visible = false


func _on_phase_changed(phase: GameState.ProgressPhase) -> void:
	_refresh_objective(phase)
	if objective_panel.visible:
		_play_objective_feedback()


func _refresh_objective(phase: GameState.ProgressPhase) -> void:
	var text := get_objective_text(phase)
	objective_panel.visible = not text.is_empty()
	if not objective_panel.visible:
		return
	objective_step_label.text = get_objective_step(phase)
	objective_label.text = text
	memory_hint_label.visible = phase == GameState.ProgressPhase.RETURN_HOME
	if memory_hint_label.visible:
		memory_hint_label.text = "不思議な記憶を持ち帰ろう"


func get_objective_text(phase: GameState.ProgressPhase) -> String:
	match phase:
		GameState.ProgressPhase.INTRO:
			return "おばあちゃんに、今日の予定を聞こう"
		GameState.ProgressPhase.FREE_ROAM:
			return "田んぼ道を抜けて、川を見に行こう"
		GameState.ProgressPhase.RETURN_HOME:
			return "河童のような影を見た。家へ帰ろう"
		_:
			return ""


func get_objective_step(phase: GameState.ProgressPhase) -> String:
	match phase:
		GameState.ProgressPhase.INTRO:
			return "今日の気がかり"
		GameState.ProgressPhase.FREE_ROAM:
			return "おばあちゃんの言葉"
		GameState.ProgressPhase.RETURN_HOME:
			return "忘れたくないこと"
		_:
			return ""


func _play_objective_feedback() -> void:
	objective_panel.modulate = Color(1.0, 0.86, 0.58, 1.0)
	var tween := create_tween()
	tween.tween_property(objective_panel, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_CUBIC)
