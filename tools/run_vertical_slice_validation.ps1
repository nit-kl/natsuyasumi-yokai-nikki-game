param(
    [string]$GodotPath = "C:\Users\kojil\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$env:APPDATA = Join-Path $projectRoot ".godot-appdata"
$env:LOCALAPPDATA = Join-Path $projectRoot ".godot-localappdata"

$testScenes = @(
    "tests/foundation_validation.tscn",
    "tests/map_transition_smoke_test.tscn",
    "tests/return_home_flow_smoke_test.tscn",
    "tests/vertical_slice_day_flow_smoke_test.tscn",
    "tests/vertical_slice_production_audit.tscn",
    "tests/click_move_smoke_test.tscn",
    "tests/click_action_smoke_test.tscn",
    "tests/click_target_hover_smoke_test.tscn",
    "tests/mouse_ui_smoke_test.tscn",
    "tests/grandma_house_geometry_smoke_test.tscn",
    "tests/home_outdoor_geometry_smoke_test.tscn",
    "tests/river_geometry_smoke_test.tscn",
    "tests/foreground_occlusion_smoke_test.tscn",
    "tests/grandma_indoor_routine_smoke_test.tscn",
    "tests/save_location_restore_smoke_test.tscn",
    "tests/area_subdivision_smoke_test.tscn"
)

foreach ($testScene in $testScenes) {
    & $GodotPath --headless --path $projectRoot $testScene
    if ($LASTEXITCODE -ne 0) {
        throw "Validation failed: $testScene (exit $LASTEXITCODE)"
    }
}

Write-Host "Vertical Slice validation passed ($($testScenes.Count) scenes)."
