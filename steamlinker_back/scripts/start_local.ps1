# Arranca el API en desarrollo local (PostgreSQL + .env en la raíz del back)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Creado .env desde .env.example — edita DB_PASSWORD y STEAM_API_KEY si hace falta."
}

$env:NODE_ENV = "development"
Write-Host "NODE_ENV=development"
Write-Host "Health: http://localhost:3000/health"
Write-Host ""

npm run dev
