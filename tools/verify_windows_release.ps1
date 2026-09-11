[CmdletBinding()]
param(
    [string]$PackagePath = "",
    [int]$RuntimeTimeoutSeconds = 15
)

$ErrorActionPreference = "Stop"
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($PackagePath)) {
    $PackagePath = Join-Path $projectPath "dist\TSL2027-windows-x64.zip"
}
$PackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) {
    throw "Windows paketi bulunamadı: $PackagePath"
}

$runId = Get-Date -Format "yyyyMMddHHmmssfff"
$extractPath = Join-Path ([System.IO.Path]::GetTempPath()) ("TSL2027-release-smoke-" + [guid]::NewGuid().ToString("N"))
$stdoutPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-release-$runId.stdout.log"
$stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) "TSL2027-release-$runId.stderr.log"
$runtimeProcess = $null
try {
    New-Item -ItemType Directory -Force -Path $extractPath | Out-Null
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $extractPath -Force

    $exePath = Join-Path $extractPath "TSL2027.exe"
    foreach ($requiredPath in @(
        $exePath,
        (Join-Path $extractPath "README.md"),
        (Join-Path $extractPath "LICENSE"),
        (Join-Path $extractPath "docs\DATA_AND_LICENSING.md")
    )) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Paket eksik dosya içeriyor: $requiredPath"
        }
    }

    $runtimeProcess = Start-Process -FilePath $exePath -ArgumentList @("--headless", "--quit-after", "3") -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
    $deadline = (Get-Date).AddSeconds($RuntimeTimeoutSeconds)
    while (-not $runtimeProcess.HasExited -and (Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 1
        $runtimeProcess.Refresh()
    }
    if (-not $runtimeProcess.HasExited) {
        Stop-Process -Id $runtimeProcess.Id -Force -ErrorAction SilentlyContinue
        throw "Temiz klasörden çalıştırılan paket smoke testte zaman aşımına uğradı. Loglar: $stdoutPath / $stderrPath"
    }
    $stdout = if (Test-Path -LiteralPath $stdoutPath) { Get-Content -LiteralPath $stdoutPath -Raw } else { "" }
    $stderr = if (Test-Path -LiteralPath $stderrPath) { Get-Content -LiteralPath $stderrPath -Raw } else { "" }
    $runtimeExitCode = $runtimeProcess.ExitCode
    if (($null -ne $runtimeExitCode -and $runtimeExitCode -ne 0) -or $stderr -match "ERROR:|SCRIPT ERROR") {
        throw "Temiz klasörden çalıştırılan paket başarısız oldu (exit $runtimeExitCode).`n$stdout`n$stderr"
    }
    $runtimeProcess.Close()
    $runtimeProcess.Dispose()
    $runtimeProcess = $null

    $archive = Get-Item -LiteralPath $PackagePath
    Write-Output "Clean-directory package smoke OK: $($archive.FullName)"
    Write-Output "Runtime smoke: exit 0"
    Write-Output "Extracted to: $extractPath"
}
finally {
    if ($null -ne $runtimeProcess) {
        $runtimeProcess.Dispose()
    }
    if (Test-Path -LiteralPath $extractPath) {
        $removed = $false
        for ($attempt = 1; $attempt -le 10; $attempt++) {
            try {
                Remove-Item -LiteralPath $extractPath -Recurse -Force -ErrorAction Stop
                $removed = $true
                break
            }
            catch {
                Start-Sleep -Milliseconds 500
            }
        }
        if (-not $removed -and (Test-Path -LiteralPath $extractPath)) {
            Write-Warning "Geçici extraction klasörü otomatik temizlenemedi; dosya kilidi kalkınca silinebilir: $extractPath"
        }
    }
}
