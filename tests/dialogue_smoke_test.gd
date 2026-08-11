extends Node

const GRANDMA_DIALOGUE: DialogueSequence = preload("res://resources/dialogue/grandma_morning.tres")


func _ready() -> void:
	assert(GRANDMA_DIALOGUE.is_valid())
	assert(GRANDMA_DIALOGUE.lines.size() == 3)
	assert(GRANDMA_DIALOGUE.lines[0].speaker == "おばあちゃん")

	GameClock.set_paused(false)
	assert(DialogueManager.start_dialogue(GRANDMA_DIALOGUE))
	assert(DialogueManager.is_active)
	assert(GameClock.clock_paused)
	assert(DialogueManager.get_current_line() == GRANDMA_DIALOGUE.lines[0])

	DialogueManager.advance()
	assert(DialogueManager.current_line_index == 1)
	DialogueManager.advance()
	assert(DialogueManager.current_line_index == 2)
	DialogueManager.advance()
	assert(not DialogueManager.is_active)
	assert(not GameClock.clock_paused)

	GameClock.set_paused(true)
	assert(DialogueManager.start_dialogue(GRANDMA_DIALOGUE))
	DialogueManager.finish_dialogue()
	assert(GameClock.clock_paused)

	print("Dialogue smoke test passed.")
	get_tree().quit(0)

