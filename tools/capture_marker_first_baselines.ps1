param(
    [Parameter(Mandatory = $true)]
    [string]$GodotPath,
    [string]$OutputDirectory = "docs/art-reference/03_gameplay/marker_first_geometry"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$resolvedGodot = (Resolve-Path -LiteralPath $GodotPath).Path
$absoluteOutput = Join-Path $projectRoot $OutputDirectory
$resourceOutput = "res://" + $OutputDirectory.Replace("\", "/")
New-Item -ItemType Directory -Path $absoluteOutput -Force | Out-Null
$logDirectory = Join-Path $projectRoot ".tmp/marker-first-capture"
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null

$cases = [ordered]@{
    "bedroom" = "res://scenes/maps/bedroom/bedroom.tscn"
    "grandma_house" = "res://scenes/maps/grandma_house/grandma_house.tscn"
    "engawa_yard" = "res://scenes/maps/village/engawa_yard.tscn"
    "paddy_road" = "res://scenes/maps/village/paddy_road.tscn"
    "irrigation_shade" = "res://scenes/maps/village/irrigation_shade.tscn"
    "river_entrance" = "res://scenes/maps/river/river_entrance.tscn"
    "river" = "res://scenes/maps/river/river.tscn"
    "home_outdoor" = "res://scenes/maps/village/home_outdoor.tscn"
}

foreach ($entry in $cases.GetEnumerator()) {
    $logPath = Join-Path $logDirectory "$($entry.Key).log"
    $geometryPath = "$resourceOutput/$($entry.Key)_geometry.png"
    $markersPath = "$resourceOutput/$($entry.Key)_markers.png"

    & $resolvedGodot --path $projectRoot --audio-driver Dummy --log-file $logPath `
        --script res://tools/capture_2d_geometry.gd -- $entry.Value $geometryPath 320 180
    if ($LASTEXITCODE -ne 0) {
        throw "Geometry capture failed: $($entry.Value)"
    }

    & $resolvedGodot --path $projectRoot --audio-driver Dummy --log-file $logPath `
        --script res://tools/capture_2d_geometry.gd -- $entry.Value $markersPath 320 180 clean 0.15
    if ($LASTEXITCODE -ne 0) {
        throw "Marker capture failed: $($entry.Value)"
    }
}

Write-Host "Marker-first visual baselines saved to $absoluteOutput"
