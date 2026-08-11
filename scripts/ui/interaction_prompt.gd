extends CanvasLayer

@export var interactor_path: NodePath = ^"../InteractionDetector"

@onready var panel: PanelContainer = %Panel
@onready var prompt_label: Label = %PromptLabel
@onready var feedback_timer: Timer = %FeedbackTimer

var _interactor: PlayerInteractor
var _showing_feedback := false


func _ready() -> void:
	_interactor = get_node(interactor_path) as PlayerInteractor
	_interactor.focus_changed.connect(_on_focus_changed)
	_interactor.interaction_performed.connect(_on_interaction_performed)
	feedback_timer.timeout.connect(_on_feedback_timeout)
	_refresh_prompt(_interactor.current_interactable)


func _on_focus_changed(interactable: Interactable) -> void:
	if not _showing_feedback:
		_refresh_prompt(interactable)


func _on_interaction_performed(interactable: Interactable) -> void:
	_showing_feedback = true
	panel.visible = true
	prompt_label.text = "✓ %s" % interactable.get_interaction_text()
	feedback_timer.start()


func _on_feedback_timeout() -> void:
	_showing_feedback = false
	_refresh_prompt(_interactor.current_interactable)


func _refresh_prompt(interactable: Interactable) -> void:
	panel.visible = is_instance_valid(interactable)
	if panel.visible:
		prompt_label.text = "[E] %s" % interactable.get_interaction_text()

