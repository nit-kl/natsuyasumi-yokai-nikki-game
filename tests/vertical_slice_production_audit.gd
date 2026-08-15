extends Node

const REQUIRED_TEXTURES := {
	"res://assets/maps/bedroom/map_bedroom.png": Vector2(640, 360),
	"res://assets/maps/engawa_yard/map_engawa_yard.png": Vector2(640, 360),
	"res://assets/maps/paddy_road/map_paddy_road.png": Vector2(640, 360),
	"res://assets/maps/irrigation_shade/map_irrigation_shade.png": Vector2(640, 360),
	"res://assets/maps/river_entrance/map_river_entrance.png": Vector2(640, 360),
	"res://assets/maps/grandma_house/map_grandma_house.png": Vector2(640, 360),
	"res://assets/maps/home_outdoor/map_home_outdoor.png": Vector2(640, 360),
	"res://assets/maps/river/map_river.png": Vector2(640, 360),
	"res://assets/sprites/characters/protagonist/chr_protagonist_walk_4dir.png": Vector2(256, 256),
	"res://assets/sprites/characters/grandma/chr_grandma_walk_4dir.png": Vector2(256, 256),
	"res://assets/sprites/yokai/kappa/yokai_kappa_surface.png": Vector2(256, 64),
	"res://assets/sprites/insects/aburazemi/insect_aburazemi.png": Vector2(24, 24),
	"res://assets/sprites/props/bug_net/prop_bug_net.png": Vector2(32, 48),
	"res://assets/vfx/water/vfx_water_ripple.png": Vector2(256, 64),
	"res://assets/ui/hud/ui_hud_status_panel.png": Vector2(208, 72),
	"res://assets/ui/hud/ui_hud_tool_panel.png": Vector2(128, 44),
	"res://assets/ui/hud/ui_hud_prompt_panel.png": Vector2(300, 48),
	"res://assets/ui/dialogue/ui_dialogue_panel.png": Vector2(560, 132),
	"res://assets/ui/dialogue/ui_dialogue_choice.png": Vector2(240, 42),
	"res://assets/ui/diary/ui_diary_cover.png": Vector2(224, 280),
	"res://assets/ui/diary/ui_diary_daily_page.png": Vector2(512, 320),
}

const REQUIRED_FILES := [
	"res://assets/ui/diary/icon_weather_sunny.png",
	"res://assets/ui/diary/stamp_kappa.png",
	"res://assets/ui/diary/stamp_aburazemi.png",
	"res://assets/audio/ambience/amb_grandma_house_interior.ogg",
	"res://assets/audio/ambience/amb_home_outdoor_daytime.ogg",
	"res://assets/audio/ambience/amb_home_outdoor_evening.ogg",
	"res://assets/audio/ambience/amb_river_flow.ogg",
	"res://assets/audio/sfx/sfx_bug_net_swing.ogg",
	"res://assets/audio/sfx/sfx_bug_catch_success.ogg",
	"res://assets/audio/sfx/sfx_water_ripple.ogg",
	"res://assets/audio/sfx/sfx_kappa_subtle_cue.ogg",
	"res://assets/audio/sfx/sfx_page_turn.ogg",
	"res://assets/audio/sfx/sfx_ui_confirm.ogg",
	"res://assets/audio/sfx/sfx_ui_cancel.ogg",
]

const PRODUCTION_RESOURCES := [
	"res://resources/characters/protagonist_4dir_sprite_frames.tres",
	"res://resources/characters/grandma_4dir_sprite_frames.tres",
	"res://resources/characters/kappa_surface_sprite_frames.tres",
	"res://resources/vfx/water_ripple_sprite_frames.tres",
	"res://scenes/maps/grandma_house/grandma_house.tscn",
	"res://scenes/maps/bedroom/bedroom.tscn",
	"res://scenes/maps/village/engawa_yard.tscn",
	"res://scenes/maps/village/paddy_road.tscn",
	"res://scenes/maps/village/irrigation_shade.tscn",
	"res://scenes/maps/river/river_entrance.tscn",
	"res://scenes/maps/village/home_outdoor.tscn",
	"res://scenes/maps/river/river.tscn",
	"res://scenes/player/player.tscn",
	"res://scenes/npc/grandma.tscn",
	"res://scenes/minigames/insect.tscn",
	"res://scenes/yokai/kappa_glimpse.tscn",
	"res://scenes/ui/gameplay_hud.tscn",
	"res://scenes/ui/dialogue_ui.tscn",
	"res://scenes/ui/diary_ui.tscn",
]

const MAP_SCENES := [
	"res://scenes/maps/bedroom/bedroom.tscn",
	"res://scenes/maps/grandma_house/grandma_house.tscn",
	"res://scenes/maps/village/engawa_yard.tscn",
	"res://scenes/maps/village/paddy_road.tscn",
	"res://scenes/maps/village/irrigation_shade.tscn",
	"res://scenes/maps/river/river_entrance.tscn",
	"res://scenes/maps/village/home_outdoor.tscn",
	"res://scenes/maps/river/river.tscn",
]

const FORBIDDEN_PRODUCTION_REFERENCES := [
	"res://docs/art-reference/",
	"_source.png",
	"_candidate.png",
]

var _failures: Array[String] = []


func _ready() -> void:
	_audit_project_pixel_settings()
	_audit_required_assets()
	_audit_production_references()
	_audit_map_fallback_visibility()
	if _failures.is_empty():
		print("Vertical Slice production asset audit passed.")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)


func _audit_project_pixel_settings() -> void:
	_expect(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "Base viewport width should remain 640.")
	_expect(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "Base viewport height should remain 360.")
	_expect(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Window scaling should remain integer.")
	_expect(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Default texture filtering should remain Nearest.")


func _audit_required_assets() -> void:
	for path in REQUIRED_TEXTURES:
		var texture := load(path) as Texture2D
		_expect(texture != null, "Required Production texture is missing: %s" % path)
		if texture != null:
			_expect(texture.get_size() == REQUIRED_TEXTURES[path], "Production texture has an unexpected size: %s" % path)
	for path in REQUIRED_FILES:
		_expect(FileAccess.file_exists(path), "Required Production asset is missing: %s" % path)


func _audit_production_references() -> void:
	for path in PRODUCTION_RESOURCES:
		_expect(ResourceLoader.exists(path), "Production resource is missing: %s" % path)
		var source := FileAccess.get_file_as_string(path)
		_expect(not source.is_empty(), "Production resource could not be read: %s" % path)
		for forbidden in FORBIDDEN_PRODUCTION_REFERENCES:
			_expect(not source.contains(forbidden), "Production resource references a source/reference asset: %s -> %s" % [path, forbidden])


func _audit_map_fallback_visibility() -> void:
	for path in MAP_SCENES:
		var packed_scene := load(path) as PackedScene
		if packed_scene == null:
			_expect(false, "Production map could not be loaded: %s" % path)
			continue
		var map := packed_scene.instantiate()
		var background := map.get_node_or_null("ProductionBackground") as Sprite2D
		var greybox := map.get_node_or_null("GreyboxVisual") as CanvasItem
		var navigation_region := map.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
		_expect(background != null and background.texture != null, "Production map background is missing: %s" % path)
		_expect(background == null or background.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Production map should use Nearest filtering: %s" % path)
		_expect(greybox == null or not greybox.visible, "Greybox fallback should remain hidden: %s" % path)
		_expect(navigation_region != null and navigation_region.navigation_polygon != null, "Production map should provide click-navigation data: %s" % path)
		map.free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
