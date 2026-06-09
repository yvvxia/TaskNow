<#
.SYNOPSIS
  Reproducible release builds for Liveline (Windows + Android) on Windows.

.DESCRIPTION
  Wraps `flutter build` with the environment this project needs:
    * SQLITE3_LOCAL_LIBS  - directory holding the prebuilt sqlite3 native libs
                            (Android .so files + sqlite3.x64.windows.dll). The
                            sqlite3 build hook reads this to avoid downloading
                            them at build time (useful behind a flaky network).
    * Flutter on PATH     - prepended from -FlutterBin if not already resolvable.

  See tool/build.md for how to populate the sqlite3 libs directory and the
  one-time Android SDK setup.

.PARAMETER Target
  windows | android | all   (default: all)

.PARAMETER Mode
  release | debug           (default: release)

.PARAMETER Sqlite3Libs
  Path to the local sqlite3 native libs. Defaults to $env:SQLITE3_LOCAL_LIBS,
  then to C:\Android\sqlite3libs.

.PARAMETER FlutterBin
  Flutter bin directory to prepend to PATH when `flutter` is not on PATH.
  Defaults to $env:FLUTTER_BIN, then to %LOCALAPPDATA%\flutter\bin.

.EXAMPLE
  pwsh tool/build.ps1                      # release Windows + Android
  pwsh tool/build.ps1 -Target windows      # release Windows only
  pwsh tool/build.ps1 -Target android -Mode debug
#>
[CmdletBinding()]
param(
    [ValidateSet('windows', 'android', 'all')]
    [string]$Target = 'all',

    [ValidateSet('release', 'debug')]
    [string]$Mode = 'release',

    [string]$Sqlite3Libs = $(if ($env:SQLITE3_LOCAL_LIBS) { $env:SQLITE3_LOCAL_LIBS } else { 'C:\Android\sqlite3libs' }),

    [string]$FlutterBin = $(if ($env:FLUTTER_BIN) { $env:FLUTTER_BIN } else { Join-Path $env:LOCALAPPDATA 'flutter\bin' })
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Write-Step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Warn([string]$msg) { Write-Host "[warn] $msg" -ForegroundColor Yellow }

# --- Resolve flutter -------------------------------------------------------
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $FlutterBin 'flutter.bat')) {
        Write-Step "Adding Flutter to PATH: $FlutterBin"
        $env:Path = "$FlutterBin;$env:Path"
    }
    else {
        throw "flutter not found on PATH and not at '$FlutterBin'. Pass -FlutterBin <dir>."
    }
}

# --- sqlite3 local libs ----------------------------------------------------
if (Test-Path $Sqlite3Libs) {
    $env:SQLITE3_LOCAL_LIBS = $Sqlite3Libs
    Write-Step "Using SQLITE3_LOCAL_LIBS=$Sqlite3Libs"
}
else {
    Write-Warn "sqlite3 libs dir not found at '$Sqlite3Libs'. The build may try to download them (see tool/build.md). Set -Sqlite3Libs to override."
}

Push-Location $repoRoot
try {
    $modeFlag = "--$Mode"
    $built = @()

    if ($Target -eq 'android' -or $Target -eq 'all') {
        Write-Step "Building Android APK ($Mode)"
        flutter build apk $modeFlag
        if ($LASTEXITCODE -ne 0) { throw "Android build failed (exit $LASTEXITCODE)." }
        $apk = if ($Mode -eq 'release') { 'build\app\outputs\flutter-apk\app-release.apk' } else { 'build\app\outputs\flutter-apk\app-debug.apk' }
        $built += $apk
    }

    if ($Target -eq 'windows' -or $Target -eq 'all') {
        Write-Step "Building Windows ($Mode)"
        flutter build windows $modeFlag
        if ($LASTEXITCODE -ne 0) { throw "Windows build failed (exit $LASTEXITCODE)." }
        $cap = (Get-Culture).TextInfo.ToTitleCase($Mode)
        $built += "build\windows\x64\runner\$cap\liveline.exe"
    }

    Write-Host ''
    Write-Step 'Build succeeded. Artifacts:'
    foreach ($a in $built) {
        $full = Join-Path $repoRoot $a
        if (Test-Path $full) {
            $mb = [math]::Round((Get-Item $full).Length / 1MB, 1)
            Write-Host ("  {0}  ({1} MB)" -f $full, $mb) -ForegroundColor Green
        }
        else {
            Write-Warn "expected artifact missing: $full"
        }
    }
}
finally {
    Pop-Location
}
