# Quick script to add sensor start to Nightscout
# Run this every time Carmen gets a new sensor

$apiSecret = "carmenkennaway4181"
$nightscoutUrl = "https://carmensugar.azurewebsites.net"

Write-Host "=== Add Sensor Start to Nightscout ===" -ForegroundColor Cyan
Write-Host ""

$date = Read-Host "When was the sensor inserted? (Format: YYYY-MM-DD HH:mm, e.g., 2025-12-20 09:00)"

try {
    $parsedDate = [DateTime]::ParseExact($date, "yyyy-MM-dd HH:mm", $null)
    $isoDate = $parsedDate.ToString("yyyy-MM-ddTHH:mm:ss")
    
    Write-Host "Adding sensor start at: $isoDate" -ForegroundColor Yellow
    
    $body = @{
        eventType = "Sensor Start"
        created_at = $isoDate
        enteredBy = "PowerShell Script"
        notes = "Dexcom G7"
    } | ConvertTo-Json
    
    $hash = [System.Security.Cryptography.SHA1]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($apiSecret))
    $token = [System.BitConverter]::ToString($hash).Replace("-","").ToLower()
    
    $result = Invoke-RestMethod -Uri "$nightscoutUrl/api/v1/treatments.json" -Method Post -Body $body -ContentType "application/json" -Headers @{"api-secret"=$token}
    
    Write-Host ""
    Write-Host "SUCCESS! Sensor start added." -ForegroundColor Green
    Write-Host "Sensor will expire around: $($parsedDate.AddHours(252).ToString("yyyy-MM-dd HH:mm"))" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Sugarmate will show the sensor age now!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
