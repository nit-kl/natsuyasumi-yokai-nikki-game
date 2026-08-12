extends CanvasLayer

@onready var day_label: Label = %DayLabel
@onready var time_label: Label = %TimeLabel
@onready var interaction_label: Label = %InteractionLabel


func _ready() -> void:
	CalendarManager.day_changed.connect(_refresh)
	GameClock.minute_changed.connect(_refresh)
	GameClock.period_changed.connect(_refresh)
	if is_instance_valid(GameState.player):
		GameState.player.interaction_candidate_changed.connect(_on_interaction_candidate_changed)
		GameState.player.interaction_performed.connect(_on_interaction_performed)
		GameState.player.bug_catch_succeeded.connect(_on_bug_catch_succeeded)
		GameState.player.bug_catch_missed.connect(_on_bug_catch_missed)
	_refresh()


func _refresh(_unused: Variant = null) -> void:
	day_label.text = "Day %d / 30" % CalendarManager.day_index
	time_label.text = "%s  %s" % [GameClock.get_time_text(), GameClock.get_period()]


func _on_interaction_candidate_changed(target: Node, prompt_text: String) -> void:
	interaction_label.visible = is_instance_valid(target) and not prompt_text.is_empty()
	interaction_label.text = "E / Z: %s" % prompt_text


func _on_interaction_performed(target: Node) -> void:
	interaction_label.visible = false


func _on_bug_catch_succeeded(insect_id: StringName) -> void:
	interaction_label.visible = true
	interaction_label.text = "つかまえた: %s" % insect_id


func _on_bug_catch_missed() -> void:
	interaction_label.visible = true
	interaction_label.text = "虫取り網は空振りだった"
