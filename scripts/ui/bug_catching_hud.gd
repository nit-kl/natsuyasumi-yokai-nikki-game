extends CanvasLayer

@onready var panel: PanelContainer = %Panel
@onready var result_label: Label = %ResultLabel
@onready var hide_timer: Timer = %HideTimer


func _ready() -> void:
	panel.visible = false
	BugCatchingManager.insect_caught.connect(_on_insect_caught)
	hide_timer.timeout.connect(_on_hide_timer_timeout)


func _on_insect_caught(insect: InsectData, total_for_species: int) -> void:
	panel.visible = true
	result_label.text = "Caught %s!  ×%d" % [insect.display_name, total_for_species]
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	panel.visible = false

