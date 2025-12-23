# Create new Node.js App Service for Nightscout
param(
    [string]$newAppName = "carmensugar-nodejs",
    [string]$resourceGroup = "carmensugar",
    [string]$location = "westeurope"
)

Write-Host "=== Create New Node.js App Service ===" -ForegroundColor Green
Write-Host ""

# Get credentials
$username = Read-Host "Enter Azure deployment username"
$password = Read-Host "Enter Azure deployment password" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Get current settings from old app
Write-Host "Fetching current settings from carmensugar..." -ForegroundColor Yellow
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${passwordPlain}"))
$headers = @{ Authorization = "Basic $base64Auth" }

try {
    $currentSettings = Invoke-RestMethod -Uri "https://carmensugar.scm.azurewebsites.net/api/settings" -Method Get -Headers $headers
    Write-Host "✓ Settings retrieved" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to get settings: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Go to Azure Portal (portal.azure.com)"
Write-Host "2. Click '+ Create a resource'"
Write-Host "3. Search for 'Web App' and click Create"
Write-Host "4. Fill in:"
Write-Host "   - Resource Group: $resourceGroup"
Write-Host "   - Name: $newAppName"
Write-Host "   - Publish: CODE (not Docker Container!)"
Write-Host "   - Runtime stack: Node 18 LTS"
Write-Host "   - Region: West Europe (or same as current)"
Write-Host "   - Pricing: Free F1 or same as current"
Write-Host "5. Click 'Review + Create', then 'Create'"
Write-Host ""
Write-Host "Once created, run this script again with '-configure' flag"
Write-Host ""
Write-Host "Settings to copy:" -ForegroundColor Yellow
$currentSettings | Select-Object API_SECRET, MONGODB_URI, BRIDGE_USER_NAME, BRIDGE_PASSWORD, BRIDGE_SERVER, ENABLE, DISPLAY_UNITS | Format-List
