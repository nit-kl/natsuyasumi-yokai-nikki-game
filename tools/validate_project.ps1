param(
    [string]$GodotPath = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $candidates = @(
        "godot",
        "godot4",
        "C:\Users\kojil\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe"
    )
    foreach ($candidate in $candidates) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            $GodotPath = $candidate
            break
        }
        if (Test-Path -LiteralPath $candidate) {
            $GodotPath = $candidate
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    throw "Godot 4 executable was not found. Pass -GodotPath explicitly."
}

& $GodotPath --headless --path $repoRoot --editor --quit
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& $GodotPath --headless --path $repoRoot res://tests/foundation_validation.tscn
exit $LASTEXITCODE
