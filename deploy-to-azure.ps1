# Deploy to Azure
# Run this script after making the changes to deploy to your Azure Web App

Write-Host "=" -ForegroundColor Cyan
Write-Host "Nightscout - Deploy to Azure" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git from https://git-scm.com/" -ForegroundColor Yellow
    exit 1
}

# Check if we're in a git repository
$isGitRepo = Test-Path ".git"
if (-not $isGitRepo) {
    Write-Host "ERROR: Not in a Git repository" -ForegroundColor Red
    Write-Host "Please run this script from the cgm-remote-monitor directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "Current changes:" -ForegroundColor Yellow
git status --short

Write-Host ""
Write-Host "This will:" -ForegroundColor Cyan
Write-Host "1. Commit your changes locally" -ForegroundColor White
Write-Host "2. Push to your Azure remote (if configured)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Do you want to continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

# Add changes
Write-Host ""
Write-Host "Adding changes..." -ForegroundColor Cyan
git add lib/server/pebble.js
git add SENSOR_AGE_SUGARMATE_SETUP.md

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Cyan
$commitMessage = "Add sensor age/expiry to Pebble API for Sugarmate"
git commit -m $commitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Commit failed" -ForegroundColor Red
    exit 1
}

Write-Host "Changes committed successfully!" -ForegroundColor Green
Write-Host ""

# Check for Azure remote
$azureRemote = git remote -v | Select-String "azurewebsites.net"
if ($azureRemote) {
    Write-Host "Azure remote found!" -ForegroundColor Green
    Write-Host ""
    $pushToAzure = Read-Host "Push to Azure now? (yes/no)"
    
    if ($pushToAzure -eq "yes") {
        Write-Host "Pushing to Azure..." -ForegroundColor Cyan
        
        # Try to determine the remote name
        $remoteName = (git remote -v | Select-String "azurewebsites.net" | Select-Object -First 1).ToString().Split()[0]
        
        Write-Host "Using remote: $remoteName" -ForegroundColor Yellow
        git push $remoteName master
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "SUCCESS! Deployed to Azure" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Cyan
            Write-Host "1. Go to Azure Portal" -ForegroundColor White
            Write-Host "2. Add 'sage' to your ENABLE environment variable" -ForegroundColor White
            Write-Host "3. Restart your App Service" -ForegroundColor White
            Write-Host "4. Log a sensor start event in Nightscout" -ForegroundColor White
            Write-Host "5. Check https://carmensugar.azurewebsites.net/pebble" -ForegroundColor White
            Write-Host ""
            Write-Host "See SENSOR_AGE_SUGARMATE_SETUP.md for detailed instructions" -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: Push to Azure failed" -ForegroundColor Red
            Write-Host "You may need to configure Azure deployment credentials" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No Azure remote configured" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To deploy to Azure, you need to:" -ForegroundColor Cyan
    Write-Host "1. Get your Azure Git URL from the Azure Portal" -ForegroundColor White
    Write-Host "2. Run: git remote add azure <your-git-url>" -ForegroundColor White
    Write-Host "3. Run: git push azure master" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use the Azure deployment center in the portal" -ForegroundColor White
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
