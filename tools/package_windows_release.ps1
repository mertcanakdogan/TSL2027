[CmdletBinding()]
param(
    [string]$ArtifactPath = "",
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($ArtifactPath)) {
    $ArtifactPath = Join-Path $projectPath "build\TSL2027.exe"
}
$ArtifactPath = (Resolve-Path -LiteralPath $ArtifactPath).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $projectPath "dist\TSL2027-windows-x64.zip"
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

foreach ($requiredPath in @(
    $ArtifactPath,
    (Join-Path $projectPath "README.md"),
    (Join-Path $projectPath "LICENSE"),
    (Join-Path $projectPath "docs\DATA_AND_LICENSING.md")
)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Paket girdisi bulunamadı: $requiredPath"
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$stagingPath = Join-Path ([System.IO.Path]::GetTempPath()) ("TSL2027-package-" + [guid]::NewGuid().ToString("N"))
try {
    New-Item -ItemType Directory -Force -Path (Join-Path $stagingPath "docs") | Out-Null
    Copy-Item -LiteralPath $ArtifactPath -Destination (Join-Path $stagingPath "TSL2027.exe")
    Copy-Item -LiteralPath (Join-Path $projectPath "README.md") -Destination (Join-Path $stagingPath "README.md")
    Copy-Item -LiteralPath (Join-Path $projectPath "LICENSE") -Destination (Join-Path $stagingPath "LICENSE")
    Copy-Item -LiteralPath (Join-Path $projectPath "docs\DATA_AND_LICENSING.md") -Destination (Join-Path $stagingPath "docs\DATA_AND_LICENSING.md")

    Compress-Archive -Path (Join-Path $stagingPath "*") -DestinationPath $OutputPath -CompressionLevel Optimal -Force
    $archive = Get-Item -LiteralPath $OutputPath
    $hash = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash
    Write-Output "Windows package OK: $($archive.FullName)"
    Write-Output "Package size: $($archive.Length) bytes"
    Write-Output "SHA256: $hash"
}
finally {
    if (Test-Path -LiteralPath $stagingPath) {
        Remove-Item -LiteralPath $stagingPath -Recurse -Force
    }
}
