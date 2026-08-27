<#
  build_release_apk.ps1

  Background: the project root contains Chinese characters
  (D:\health-ios-project-mvp-20260819), and Flutter's release AOT build fails
  to write app.dill under a non-ASCII path. Release APKs can only be built
  from a pure-ASCII path.

  This script mirrors the source tree into an ASCII-path temp build dir,
  builds the release APK there, then copies the result back into this
  project's release/ folder.

  IMPORTANT: run this manually from your own PowerShell window. Do not run
  it via Claude Code's tool calls -- spawning Gradle that way is known to
  fail on this machine with "Unable to establish loopback connection".

  Usage:
    cd <project root>
    .\scripts\build_release_apk.ps1
    .\scripts\build_release_apk.ps1 -DartDefine "REPORT_API_BASE=https://your-domain.com"
    .\scripts\build_release_apk.ps1 -BuildDir "D:\health_archive_build"
#>
param(
    [string]$BuildDir = "D:\health_archive_build",
    [string]$DartDefine = ""
)

$ErrorActionPreference = "Stop"
$SourceDir = Split-Path -Parent $PSScriptRoot

Write-Host "Source dir (kept read-only, only synced from): $SourceDir"
Write-Host "Build dir (ASCII path)                       : $BuildDir"

# 1. Mirror source into the ASCII-path build dir.
#    Exclude: git metadata, build caches/outputs, release apks, Claude/Reasonix
#    session data, backend secrets and local db.
#    /MIR keeps BuildDir in sync with SourceDir (including deleting stale files).
$excludeDirs = @(
    ".git", ".dart_tool", "build", "release", ".idea", ".vscode",
    ".claude", ".reasonix",
    "android\.gradle", "android\app\build", "android\build",
    "backend\.venv", "backend\__pycache__", "backend\.pytest_cache", "backend\tests\__pycache__"
)
$excludeFiles = @("*.apk", ".env")

robocopy $SourceDir $BuildDir /MIR /XD $excludeDirs /XF $excludeFiles /NFL /NDL /NJH /NJS /NP
if ($LASTEXITCODE -ge 8) {
    throw "robocopy sync failed with exit code $LASTEXITCODE (0-7 are normal, see robocopy docs)"
}

# 2. Only patch gradle.properties in the temp build dir (cross-drive Kotlin
#    incremental cache is known to fail there). Do NOT modify the source repo.
$gradleProps = Join-Path $BuildDir "android\gradle.properties"
$kotlinFixLines = @(
    "kotlin.incremental=false",
    "kotlin.incremental.useClasspathSnapshot=false"
)
$existing = Get-Content $gradleProps -Raw
foreach ($line in $kotlinFixLines) {
    if ($existing -notmatch [regex]::Escape($line)) {
        Add-Content -Path $gradleProps -Value $line
    }
}

# 3. Build the release APK in the temp dir.
Push-Location $BuildDir
try {
    flutter pub get
    if ($DartDefine) {
        flutter build apk --release --dart-define=$DartDefine
    } else {
        Write-Host "Warning: no -DartDefine REPORT_API_BASE=... given; this APK will not point at a real recognition backend." -ForegroundColor Yellow
        flutter build apk --release
    }
} finally {
    Pop-Location
}

# 4. Copy the built APK back into this project's release/ folder, named with the pubspec version.
$builtApk = Join-Path $BuildDir "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $builtApk)) {
    throw "Build output not found: $builtApk"
}

$versionLine = Select-String -Path (Join-Path $SourceDir "pubspec.yaml") -Pattern '^version:\s*(.+)$'
$version = $versionLine.Matches[0].Groups[1].Value.Trim()

$destDir = Join-Path $SourceDir "release"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$destApk = Join-Path $destDir "health-archive-v$version.apk"
Copy-Item $builtApk $destApk -Force

Write-Host "Build complete: $destApk" -ForegroundColor Green
