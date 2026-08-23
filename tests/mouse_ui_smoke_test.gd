extends Node


func _ready() -> void:
	var monitor := MouseUIMonitor.new()
	SceneTransitionManager.add_child(monitor)
	monitor.run.call_deferred()


class MouseUIMonitor extends Node:
	const HOUSE_SCENE := "res://scenes/maps/grandma_house/grandma_house.tscn"


	func run() -> void:
		_reset_state()
		var error := await SceneTransitionManager.change_scene(HOUSE_SCENE, &"bedroom")
		if error != OK:
			_fail("Could not open the house for mouse UI testing.")
			return
		await get_tree().process_frame
		await get_tree().process_frame
		var house := get_tree().current_scene
		var player := GameState.player
		var hud := house.get_node("LocationRuntime/GameplayHUD") as GameplayHUD
		var diary := house.get_node("LocationRuntime/DiaryUI") as DiaryUI
		var diary_button := hud.get_node("DiaryButton") as Button
		diary_button.pressed.emit()
		if not diary.is_open() or not diary.is_showing_cover() or not player.movement_locked:
			_fail("The HUD diary button should open the cover and lock movement.")
			return
		diary.cover_hint.pressed.emit()
		if not diary.page_turn_audio.playing:
			_fail("The diary page button should start the existing page-turn feedback.")
			return
		await get_tree().create_timer(0.3).timeout
		if diary.is_showing_cover() or diary._is_transitioning:
			_fail("The diary page button should finish on the daily page.")
			return
		diary.close_button.pressed.emit()
		if diary.is_open() or player.movement_locked or not diary.cancel_audio.playing:
			_fail("The diary close button should close the UI, unlock movement, and play cancel feedback.")
			return
		diary.page_turn_audio.stop()
		diary.cancel_audio.stop()
		var inventory := house.get_node("LocationRuntime/InventoryUI") as InventoryUI
		var inventory_button := hud.get_node("InventoryButton") as Button
		inventory_button.pressed.emit()
		if not inventory.is_open() or not player.movement_locked:
			_fail("The HUD inventory button should open the bag and lock movement.")
			return
		if inventory.money_label.text != InventoryUI.format_money(InventoryManager.get_money()):
			_fail("The inventory panel should display current pocket money.")
			return
		inventory.close_button.pressed.emit()
		if inventory.is_open() or player.movement_locked or not inventory.cancel_audio.playing:
			_fail("The inventory close button should close the UI, unlock movement, and play cancel feedback.")
			return
		inventory.cancel_audio.stop()
		var grandma := house.get_node("NPCs/Grandma") as NPC
		var grandma_interaction := grandma.get_node("InteractionArea") as NPCInteractionArea
		var dialogue := house.get_node("LocationRuntime/DialogueController") as DialogueController
		grandma_interaction.interact(player)
		if not dialogue.is_active():
			_fail("Grandma dialogue should start before testing panel clicks.")
			return
		var left_click := InputEventMouseButton.new()
		left_click.button_index = MOUSE_BUTTON_LEFT
		left_click.pressed = true
		dialogue._on_panel_gui_input(left_click)
		if dialogue.current_line_index != 1 or not dialogue.confirm_audio.playing:
			_fail("Left-clicking the dialogue panel should advance one line with confirmation feedback.")
			return
		dialogue._on_panel_gui_input(left_click)
		dialogue._on_panel_gui_input(left_click)
		if dialogue.is_active() or player.movement_locked:
			_fail("Dialogue panel clicks should finish dialogue and restore movement.")
			return
		await get_tree().create_timer(0.5).timeout
		dialogue.confirm_audio.stop()
		_quit_cleanly(0)


	func _reset_state() -> void:
		CalendarManager.debug_set_day(1)
		GameClock.debug_set_time(7, 0)
		GameClock.set_clock_paused(false)
		GameState.set_paused(false)
		WorldState.reset_state()
		YokaiManager.reset_state()
		EventManager.reset_runtime()
		DiaryManager.reset_state()
		InventoryManager.reset_state()


	func _fail(message: String) -> void:
		push_error(message)
		_quit_cleanly(1)


	func _quit_cleanly(exit_code: int) -> void:
		var scene := get_tree().current_scene
		var audio := scene.get_node_or_null("LocationRuntime/EnvironmentAudio") as EnvironmentAudioController if scene != null else null
		if audio != null:
			audio.shutdown()
			audio.free()
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().quit(exit_code)
