extends Node

const INSECT_SCENE := preload("res://scenes/minigames/insect_entity.tscn")
const BUG_CATCHING_HUD_SCENE := preload("res://scenes/ui/bug_catching_hud.tscn")
const ABURA_ZEMI: InsectData = preload("res://resources/insects/abura_zemi.tres")


func _ready() -> void:
	BugCatchingManager.reset_collection()
	assert(ABURA_ZEMI.is_valid())
	assert(ABURA_ZEMI.display_name == "アブラゼミ")

	var hud := BUG_CATCHING_HUD_SCENE.instantiate()
	add_child(hud)

	var insect := INSECT_SCENE.instantiate() as InsectEntity
	add_child(insect)
	assert(insect.insect_data == ABURA_ZEMI)
	assert(insect.can_interact(self))
	assert(insect.left_wing != null)
	assert(insect.right_wing != null)

	var caught_count := [0]
	insect.caught.connect(func(_data: InsectData) -> void: caught_count[0] += 1)
	insect.interact(self)
	assert(insect.is_caught)
	assert(insect.visible)
	assert(not insect.visual_root.visible)
	assert(insect.catch_burst.emitting)
	assert(not insect.interaction_enabled)
	assert(caught_count[0] == 1)
	assert(hud.panel.visible)
	assert(hud.result_label.text == "アブラゼミ　×1")
	assert(BugCatchingManager.get_caught_count(&"abura_zemi") == 1)
	assert(BugCatchingManager.get_total_caught() == 1)
	assert(AudioManager.last_sfx_cue == &"bug_catch")

	var save_data := BugCatchingManager.to_save_data()
	BugCatchingManager.reset_collection()
	assert(BugCatchingManager.get_total_caught() == 0)
	BugCatchingManager.restore_from_save_data(save_data)
	assert(BugCatchingManager.get_caught_count(&"abura_zemi") == 1)

	print("Bug catching smoke test passed.")
	get_tree().quit(0)
