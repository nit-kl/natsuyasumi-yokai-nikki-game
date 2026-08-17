#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${1:-docs/art-reference/03_gameplay/marker_first_geometry}"
ABSOLUTE_OUTPUT="$PROJECT_ROOT/$OUTPUT_DIR"
RESOURCE_OUTPUT="res://${OUTPUT_DIR}"
LOG_DIR="$PROJECT_ROOT/.tmp/marker-first-capture"
GODOT_BIN="${GODOT_BIN:-godot}"

mkdir -p "$ABSOLUTE_OUTPUT" "$LOG_DIR"

declare -A CASES=(
	[bedroom]="res://scenes/maps/bedroom/bedroom.tscn"
	[grandma_house]="res://scenes/maps/grandma_house/grandma_house.tscn"
	[engawa_yard]="res://scenes/maps/village/engawa_yard.tscn"
	[paddy_road]="res://scenes/maps/village/paddy_road.tscn"
	[irrigation_shade]="res://scenes/maps/village/irrigation_shade.tscn"
	[river_entrance]="res://scenes/maps/river/river_entrance.tscn"
	[river]="res://scenes/maps/river/river.tscn"
	[home_outdoor]="res://scenes/maps/village/home_outdoor.tscn"
)

for area in bedroom grandma_house engawa_yard paddy_road irrigation_shade river_entrance river home_outdoor; do
	scene="${CASES[$area]}"
	log_path="$LOG_DIR/${area}.log"
	geometry_path="$RESOURCE_OUTPUT/${area}_geometry.png"
	markers_path="$RESOURCE_OUTPUT/${area}_markers.png"

	"$GODOT_BIN" --path "$PROJECT_ROOT" --audio-driver Dummy --log-file "$log_path" \
		--script res://tools/capture_2d_geometry.gd -- "$scene" "$geometry_path" 320 180
	"$GODOT_BIN" --path "$PROJECT_ROOT" --audio-driver Dummy --log-file "$log_path" \
		--script res://tools/capture_2d_geometry.gd -- "$scene" "$markers_path" 320 180 clean 0.15
done

echo "Marker-first visual baselines saved to $ABSOLUTE_OUTPUT"
