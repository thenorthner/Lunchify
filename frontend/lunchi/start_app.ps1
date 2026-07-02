$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Lunchify Auto-IP Flutter Launcher" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Find the active IPv4 address (prioritizing Wi-Fi, then Ethernet)
$ip = $null
try {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress -First 1)
    if ([string]::IsNullOrWhiteSpace($ip)) {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress -First 1)
    }
} catch {
    # Ignore errors
}

if ([string]::IsNullOrWhiteSpace($ip)) {
    Write-Host "Could not detect Wi-Fi or Ethernet IP. Defaulting to localhost." -ForegroundColor Yellow
    $ip = "localhost"
} else {
    Write-Host "Detected PC IP Address: $ip" -ForegroundColor Green
}

$apiUrl = "http://${ip}:3001"
Write-Host "Backend API URL will be: $apiUrl" -ForegroundColor Green
Write-Host "Starting Flutter app on connected device..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Run flutter with the injected API URL
flutter run --dart-define=API_BASE_URL=$apiUrl
