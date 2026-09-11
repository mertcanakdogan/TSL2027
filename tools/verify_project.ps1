[CmdletBinding()]
param(
    [string]$GodotPath = "godot",
    [switch]$SkipWindowsRelease
)

$ErrorActionPreference = "Stop"
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ($GodotPath -eq "godot") {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -ne $godotCommand) {
        $GodotPath = $godotCommand.Source
    }
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable bulunamadı: $GodotPath"
}

$tests = @(
    "squad_state_test.gd",
    "competition_rules_test.gd",
    "tactics_state_test.gd",
    "match_engine_test.gd",
    "league_views_test.gd",
    "economy_state_test.gd",
    "transfer_market_test.gd",
    "save_game_test.gd",
    "player_role_rules_test.gd",
    "main_scene_smoke_test.gd"
)
foreach ($test in $tests) {
    $process = Start-Process -FilePath $GodotPath -ArgumentList @(
        "--headless",
        "--path",
        $projectPath,
        "--script",
        "res://tests/$test",
        "--quit-after",
        "2"
    ) -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        throw "Godot testi başarısız oldu: $test (exit $($process.ExitCode))"
    }
}

$editorProcess = Start-Process -FilePath $GodotPath -ArgumentList @(
    "--headless",
    "--editor",
    "--path",
    $projectPath,
    "--quit"
) -Wait -PassThru -NoNewWindow
if ($editorProcess.ExitCode -ne 0) {
    throw "Godot editor parse/import kontrolü başarısız oldu (exit $($editorProcess.ExitCode))"
}

Push-Location $projectPath
try {
    & python tools/validate_data_pack.py
    if ($LASTEXITCODE -ne 0) {
        throw "Python veri paketi doğrulaması başarısız oldu (exit $LASTEXITCODE)"
    }
    & python tools/test_data_pack.py
    if ($LASTEXITCODE -ne 0) {
        throw "Python veri paketi testleri başarısız oldu (exit $LASTEXITCODE)"
    }

    if (-not $SkipWindowsRelease) {
        & .\tools\verify_windows_export.ps1 -GodotPath $GodotPath
        & .\tools\package_windows_release.ps1
        & .\tools\verify_windows_release.ps1
    }
}
finally {
    Pop-Location
}

Write-Output "Project verification OK: $($tests.Count) Godot tests, editor parse, Python data checks"
if (-not $SkipWindowsRelease) {
    Write-Output "Windows release verification OK: export, portable package, fresh-directory runtime smoke"
}
