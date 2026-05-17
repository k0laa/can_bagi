# Mevcut WiFi IP'sini otomatik al
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notmatch '^127\.' -and
    $_.IPAddress -notmatch '^169\.254\.' -and
    $_.PrefixOrigin -ne 'WellKnown'
} | Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "IP bulunamadi!" -ForegroundColor Red
    exit 1
}

Write-Host "Yeni IP: $ip" -ForegroundColor Green

# 1. web_yedek/.env
$webEnv = "C:\Users\pc\Desktop\web_yedek\.env"
"VITE_API_URL=http://${ip}:8000`nVITE_WS_URL=ws://${ip}:8000/ws/dashboard" | Set-Content $webEnv -Encoding utf8
Write-Host "web_yedek/.env guncellendi" -ForegroundColor Cyan

# 2. frontend/web/.env (repo)
$repoEnv = "C:\Users\pc\Desktop\Hackathon-Frontend\frontend\web\.env"
"VITE_API_URL=http://${ip}:8000`nVITE_WS_URL=ws://${ip}:8000/ws/dashboard" | Set-Content $repoEnv -Encoding utf8
Write-Host "frontend/web/.env guncellendi" -ForegroundColor Cyan

# 3. mobile_yedek/app_constants.dart
$dart = "C:\Users\pc\Desktop\mobile_yedek\lib\core\constants\app_constants.dart"
$content = Get-Content $dart -Raw
$content = $content -replace "defaultValue: 'http://\d+\.\d+\.\d+\.\d+:8000'", "defaultValue: 'http://${ip}:8000'"
$content = $content -replace "defaultValue: 'ws://\d+\.\d+\.\d+\.\d+:8000/ws/mobile'", "defaultValue: 'ws://${ip}:8000/ws/mobile'"
$content | Set-Content $dart -Encoding utf8
Write-Host "app_constants.dart guncellendi" -ForegroundColor Cyan

Write-Host "`nTamamlandi! Simdi:" -ForegroundColor Yellow
Write-Host "  - Web'i yeniden baslat (npm run dev)" -ForegroundColor White
Write-Host "  - Mobil build al (flutter build apk --release)" -ForegroundColor White
