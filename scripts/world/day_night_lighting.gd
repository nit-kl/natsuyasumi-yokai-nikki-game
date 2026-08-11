class_name DayNightLighting
extends Node

const NIGHT_PALETTE := {
	"sun_color": Color(0.38, 0.5, 0.82),
	"sun_energy": 0.06,
	"ambient_color": Color(0.12, 0.18, 0.34),
	"ambient_energy": 0.22,
	"sky_top": Color(0.01, 0.025, 0.09),
	"sky_horizon": Color(0.05, 0.08, 0.16),
}
const DAWN_PALETTE := {
	"sun_color": Color(1.0, 0.56, 0.3),
	"sun_energy": 0.55,
	"ambient_color": Color(0.52, 0.42, 0.52),
	"ambient_energy": 0.42,
	"sky_top": Color(0.17, 0.31, 0.55),
	"sky_horizon": Color(0.96, 0.53, 0.3),
}
const DAY_PALETTE := {
	"sun_color": Color(1.0, 0.92, 0.74),
	"sun_energy": 1.2,
	"ambient_color": Color(0.72, 0.82, 0.86),
	"ambient_energy": 0.55,
	"sky_top": Color(0.12, 0.42, 0.78),
	"sky_horizon": Color(0.7, 0.86, 0.94),
}
const SUNSET_PALETTE := {
	"sun_color": Color(1.0, 0.37, 0.14),
	"sun_energy": 0.65,
	"ambient_color": Color(0.52, 0.3, 0.36),
	"ambient_energy": 0.4,
	"sky_top": Color(0.16, 0.25, 0.5),
	"sky_horizon": Color(1.0, 0.32, 0.12),
}

@export_range(1, 180, 1) var dawn_transition_duration_minutes := 60
@export_range(0, 1439, 1) var sunset_transition_start_minutes := 15 * 60

@onready var sun: DirectionalLight3D = %Sun
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var evening_motes: GPUParticles3D = %EveningMotes

var current_period: GameClock.DayPeriod
var evening_vfx_active := false


func _ready() -> void:
	GameClock.time_changed.connect(_on_time_changed)
	GameClock.period_changed.connect(_on_period_changed)
	update_lighting(GameClock.current_minutes)


func update_lighting(minutes: int) -> void:
	var from_palette := NIGHT_PALETTE
	var to_palette := NIGHT_PALETTE
	var blend := 0.0
	current_period = GameClock.get_period()

	match current_period:
		GameClock.DayPeriod.MORNING:
			from_palette = DAWN_PALETTE
			to_palette = DAY_PALETTE
			blend = _range_ratio(minutes, GameClock.morning_start_minutes, GameClock.day_start_minutes)
		GameClock.DayPeriod.DAY:
			if minutes >= sunset_transition_start_minutes:
				from_palette = DAY_PALETTE
				to_palette = SUNSET_PALETTE
				blend = _range_ratio(minutes, sunset_transition_start_minutes, GameClock.evening_start_minutes)
			else:
				from_palette = DAY_PALETTE
				to_palette = DAY_PALETTE
		GameClock.DayPeriod.EVENING:
			from_palette = SUNSET_PALETTE
			to_palette = NIGHT_PALETTE
			blend = _range_ratio(minutes, GameClock.evening_start_minutes, GameClock.night_start_minutes)
		GameClock.DayPeriod.NIGHT:
			var dawn_transition_start := GameClock.morning_start_minutes - dawn_transition_duration_minutes
			if minutes >= dawn_transition_start and minutes < GameClock.morning_start_minutes:
				from_palette = NIGHT_PALETTE
				to_palette = DAWN_PALETTE
				blend = _range_ratio(minutes, dawn_transition_start, GameClock.morning_start_minutes)

	_apply_palette(from_palette, to_palette, smoothstep(0.0, 1.0, blend))
	_update_sun_rotation(minutes)
	_update_evening_vfx(minutes)


func _apply_palette(from_palette: Dictionary, to_palette: Dictionary, blend: float) -> void:
	sun.light_color = (from_palette["sun_color"] as Color).lerp(to_palette["sun_color"], blend)
	sun.light_energy = lerpf(from_palette["sun_energy"], to_palette["sun_energy"], blend)

	var environment := world_environment.environment
	environment.ambient_light_color = (from_palette["ambient_color"] as Color).lerp(
		to_palette["ambient_color"], blend
	)
	environment.ambient_light_energy = lerpf(
		from_palette["ambient_energy"], to_palette["ambient_energy"], blend
	)

	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	sky_material.sky_top_color = (from_palette["sky_top"] as Color).lerp(
		to_palette["sky_top"], blend
	)
	sky_material.sky_horizon_color = (from_palette["sky_horizon"] as Color).lerp(
		to_palette["sky_horizon"], blend
	)


func _update_sun_rotation(minutes: int) -> void:
	var daylight_progress := _range_ratio(
		minutes,
		GameClock.morning_start_minutes,
		GameClock.night_start_minutes
	)
	sun.rotation_degrees.x = lerpf(-12.0, -168.0, daylight_progress)


func _update_evening_vfx(minutes: int) -> void:
	evening_vfx_active = (
		minutes >= sunset_transition_start_minutes
		and minutes < GameClock.night_start_minutes
	)
	evening_motes.emitting = evening_vfx_active


func _range_ratio(value: int, from_value: int, to_value: int) -> float:
	if from_value == to_value:
		return 0.0
	return clampf(float(value - from_value) / float(to_value - from_value), 0.0, 1.0)


func _on_time_changed(hour: int, minute: int) -> void:
	update_lighting(hour * 60 + minute)


func _on_period_changed(period: GameClock.DayPeriod) -> void:
	current_period = period
