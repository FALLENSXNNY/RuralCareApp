# android_sha.ps1 — Print the SHA-1 / SHA-256 fingerprints of an Android signing keystore
#
# WHY: Firebase Phone Authentication on Android will NOT send an SMS OTP until the
# SHA-1 and SHA-256 fingerprints of the signing keystore are registered in the
# Firebase console (Project settings → Your apps → the com.ruralcare.ruralcare app).
# The default debug build is signed with ~/.android/debug.keystore.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools/android_sha.ps1
#   powershell -ExecutionPolicy Bypass -File tools/android_sha.ps1 -Keystore path\to\keystore -Alias mykey
#
# Copy the SHA1 and SHA256 values into the Firebase console, then rebuild & re-run.

param(
    [string]$Keystore = "$env:USERPROFILE\.android\debug.keystore",
    [string]$Alias = "androiddebugkey",
    [string]$StorePass = "android"
)

# Locate keytool (bundled with Android Studio, or JAVA_HOME, or on PATH).
$candidates = @(
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio1\jbr\bin\keytool.exe",
    "$env:JAVA_HOME\bin\keytool.exe",
    (Get-Command keytool -ErrorAction SilentlyContinue).Source
)

$keytool = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $keytool) {
    Write-Host "ERROR: keytool not found. Install Android Studio (bundles a JDK) or set JAVA_HOME." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Keystore)) {
    Write-Host "ERROR: keystore not found at '$Keystore'." -ForegroundColor Red
    Write-Host "Run 'flutter build apk --debug' once to generate it, or pass -Keystore <path>."
    exit 1
}

Write-Host "Using keytool : $keytool" -ForegroundColor Cyan
Write-Host "Using keystore: $Keystore (alias: $Alias)" -ForegroundColor Cyan
Write-Host ""

$raw = & $keytool -list -v -keystore $Keystore -alias $Alias -storepass $StorePass 2>&1 | Out-String

$sha1 = [regex]::Match($raw, "SHA1:\s*([0-9A-Fa-f:]{10,})").Groups[1].Value.Trim()
$sha256 = [regex]::Match($raw, "SHA256:\s*([0-9A-Fa-f:]{10,})").Groups[1].Value.Trim()

if (-not $sha1 -and -not $sha256) {
    Write-Host "No fingerprints found. Check the keystore path/alias, or run with -StorePass." -ForegroundColor Red
    Write-Host $raw
    exit 1
}

Write-Host "================ FIREBASE CONSOLE (paste these) ================" -ForegroundColor Green
Write-Host ""
if ($sha1)   { Write-Host "SHA1 fingerprint (with colons)  : $sha1" -ForegroundColor Green; Write-Host "SHA1 fingerprint (no colons)     : $($sha1 -replace ':','')" }
if ($sha256) { Write-Host "SHA256 fingerprint (with colons): $sha256" -ForegroundColor Green; Write-Host "SHA256 fingerprint (no colons)    : $($sha256 -replace ':','')" }
Write-Host ""
Write-Host "Add BOTH fingerprints at: https://console.firebase.google.com" -ForegroundColor Yellow
Write-Host "  -> Project settings -> Your apps -> com.ruralcare.ruralcare" -ForegroundColor Yellow
Write-Host "Then re-run the app (uninstall + fresh install recommended)." -ForegroundColor Yellow
