# Flutter en debug contra el backend local
# Uso emulador (por defecto): .\scripts\run_dev.ps1
# Uso móvil físico:         .\scripts\run_dev.ps1 -ApiUrl "http://192.168.1.10:3000"

param(
    [string]$ApiUrl = ""
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
if (Test-Path $adb) {
    & $adb reverse tcp:3000 tcp:3000 2>$null
    Write-Host "adb reverse activo (localhost del emulador -> PC:3000)"
}

if ($ApiUrl -eq "") {
    Write-Host "API: http://10.0.2.2:3000 (emulador). Para móvil físico: -ApiUrl http://TU_IP:3000"
    flutter run
} else {
    $ApiUrl = $ApiUrl.TrimEnd("/")
    Write-Host "API: $ApiUrl"
    flutter run --dart-define=API_BASE_URL=$ApiUrl
}
