[CmdletBinding()]
param(
    [string]$GodotPath = "godot",
    [string]$ProjectPath = "",
    [string]$OutputPath = "",
    [int]$ExportTimeoutSeconds = 180,
    [int]$RuntimeTimeoutSeconds = 15
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = (Join-Path $PSScriptRoot "..")
}
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $ProjectPath "build\TSL2027.exe"
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

if ($GodotPath -eq "godot") {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -ne $godotCommand) {
        $GodotPath = $godotCommand.Source
    }
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable bulunamadı: $GodotPath"
}

$presetPath = Join-Path $ProjectPath "export_presets.cfg"
if (-not (Test-Path -LiteralPath $presetPath -PathType Leaf)) {
    throw "Windows export preset bulunamadı: $presetPath"
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

$runId = Get-Date -Format "yyyyMMddHHmmssfff"
$stdoutPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-export-$runId.stdout.log"
$stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-export-$runId.stderr.log"
$exportArguments = @(
    "--headless",
    "--path",
    $ProjectPath,
    "--export-release",
    '"Windows Desktop"',
    $OutputPath
)

$exportProcess = Start-Process -FilePath $GodotPath -ArgumentList $exportArguments -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
$exportDeadline = (Get-Date).AddSeconds($ExportTimeoutSeconds)
while (-not $exportProcess.HasExited -and (Get-Date) -lt $exportDeadline) {
    Start-Sleep -Seconds 1
    $exportProcess.Refresh()
}
if (-not $exportProcess.HasExited) {
    Stop-Process -Id $exportProcess.Id -Force -ErrorAction SilentlyContinue
    throw "Windows export zaman aşımına uğradı. Loglar: $stdoutPath / $stderrPath"
}

$exportStdout = if (Test-Path -LiteralPath $stdoutPath) { Get-Content -LiteralPath $stdoutPath -Raw } else { "" }
$exportStderr = if (Test-Path -LiteralPath $stderrPath) { Get-Content -LiteralPath $stderrPath -Raw } else { "" }
if ($exportProcess.ExitCode -ne 0) {
    throw "Windows export başarısız oldu (exit $($exportProcess.ExitCode)).`n$exportStdout`n$exportStderr"
}
if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
    throw "Export başarılı görünüyor fakat çıktı yok: $OutputPath"
}

$runtimeStdoutPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-runtime-$runId.stdout.log"
$runtimeStderrPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-runtime-$runId.stderr.log"
$runtimeProcess = Start-Process -FilePath $OutputPath -ArgumentList @("--headless", "--quit-after", "3") -RedirectStandardOutput $runtimeStdoutPath -RedirectStandardError $runtimeStderrPath -PassThru
$runtimeDeadline = (Get-Date).AddSeconds($RuntimeTimeoutSeconds)
while (-not $runtimeProcess.HasExited -and (Get-Date) -lt $runtimeDeadline) {
    Start-Sleep -Seconds 1
    $runtimeProcess.Refresh()
}
if (-not $runtimeProcess.HasExited) {
    Stop-Process -Id $runtimeProcess.Id -Force -ErrorAction SilentlyContinue
    throw "Export edilen uygulama başlatıldı fakat kapanış smoke testi zaman aşımına uğradı. Loglar: $runtimeStdoutPath / $runtimeStderrPath"
}
if ($runtimeProcess.ExitCode -ne 0) {
    $runtimeStdout = if (Test-Path -LiteralPath $runtimeStdoutPath) { Get-Content -LiteralPath $runtimeStdoutPath -Raw } else { "" }
    $runtimeStderr = if (Test-Path -LiteralPath $runtimeStderrPath) { Get-Content -LiteralPath $runtimeStderrPath -Raw } else { "" }
    throw "Export edilen uygulama smoke testte başarısız oldu (exit $($runtimeProcess.ExitCode)).`n$runtimeStdout`n$runtimeStderr"
}

$artifact = Get-Item -LiteralPath $OutputPath
Write-Output "Windows export OK: $($artifact.FullName)"
Write-Output "Artifact size: $($artifact.Length) bytes"
Write-Output "Runtime smoke OK: exit 0"
Write-Output "Export logs: $stdoutPath / $stderrPath"
Write-Output "Runtime logs: $runtimeStdoutPath / $runtimeStderrPath"
