extends Node

const DAY_FLOW_UI_SCENE := preload("res://scenes/ui/day_flow_ui.tscn")


func _ready() -> void:
	GameState.start_new_game()
	var ui := DAY_FLOW_UI_SCENE.instantiate()
	add_child(ui)
	await get_tree().process_frame

	var objective_panel := ui.get_node("ObjectivePanel") as PanelContainer
	var step_label := ui.get_node("ObjectivePanel/MarginContainer/VBoxContainer/ObjectiveStepLabel") as Label
	var objective_label := ui.get_node("ObjectivePanel/MarginContainer/VBoxContainer/ObjectiveLabel") as Label
	var memory_hint := ui.get_node("ObjectivePanel/MarginContainer/VBoxContainer/MemoryHintLabel") as Label
	assert(objective_panel.visible)
	assert(objective_panel.theme != null)
	assert(objective_panel.get_theme_stylebox("panel") != null)
	assert(step_label.text == "今日の気がかり")
	assert(objective_label.text == "おばあちゃんに、今日の予定を聞こう")
	assert(not memory_hint.visible)

	GameState.set_progress_phase(GameState.ProgressPhase.FREE_ROAM)
	assert(objective_panel.visible)
	assert(step_label.text == "おばあちゃんの言葉")
	assert(objective_label.text == "田んぼ道を抜けて、川を見に行こう")

	GameState.set_progress_phase(GameState.ProgressPhase.RETURN_HOME)
	assert(step_label.text == "忘れたくないこと")
	assert(objective_label.text == "河童のような影を見た。家へ帰ろう")
	assert(memory_hint.visible)

	GameState.set_progress_phase(GameState.ProgressPhase.DAY_SUMMARY)
	assert(not objective_panel.visible)

	print("Day flow UI smoke test passed.")
	get_tree().quit(0)
