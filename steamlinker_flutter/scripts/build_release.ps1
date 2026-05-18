# Build de producción Android con URL del API
# Uso: .\scripts\build_release.ps1 -ApiUrl "https://api.tudominio.com"

param(
    [Parameter(Mandatory = $true)]
    [string]$ApiUrl
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Building APK with API_BASE_URL=$ApiUrl"
flutter build apk --release --dart-define=API_BASE_URL=$ApiUrl

Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk"
