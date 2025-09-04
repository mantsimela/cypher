# Manual deployment script to pull from S3 CYPHER-DEPLOYMENT folder
# Run this on the Windows Server to manually deploy from S3

param(
    [string]$Version = "latest",
    [switch]$SkipBackup = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploying RAS Dashboard from S3 CYPHER-DEPLOYMENT folder..."
Write-Host "Version: $Version"

try {
    # Set deployment paths
    $AppPath = "C:\inetpub\wwwroot\ras-dashboard"
    $BackupPath = "C:\deployments\backups\$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $TempPath = "C:\deployments\temp"
    $S3Bucket = "rasdash-deployments"
    $S3Folder = "CYPHER-DEPLOYMENT"
    
    # Create directories if they don't exist
    New-Item -ItemType Directory -Force -Path $AppPath, $BackupPath, $TempPath | Out-Null
    
    Write-Host "📁 Using deployment paths:"
    Write-Host "  App: $AppPath"
    Write-Host "  Backup: $BackupPath"
    Write-Host "  Temp: $TempPath"
    Write-Host "  S3: s3://$S3Bucket/$S3Folder"
    
    # Stop PM2 processes
    Write-Host "⏹️ Stopping PM2 processes..."
    try {
        pm2 stop ras-dashboard-api
    } catch {
        Write-Host "PM2 process 'ras-dashboard-api' not running"
    }
    
    # Backup current deployment
    if (-not $SkipBackup -and (Test-Path $AppPath) -and (Get-ChildItem $AppPath -ErrorAction SilentlyContinue)) {
        Write-Host "💾 Creating backup..."
        Copy-Item -Path "$AppPath\*" -Destination $BackupPath -Recurse -Force
        Write-Host "Backup created at $BackupPath"
    }
    
    # Download from S3
    Write-Host "⬇️ Downloading from S3..."
    if ($Version -eq "latest") {
        $S3Key = "$S3Folder/latest/ras-dashboard-latest.zip"
    } else {
        $S3Key = "$S3Folder/releases/ras-dashboard-$Version.zip"
    }
    
    $ZipFile = "$TempPath\ras-dashboard-deployment.zip"
    aws s3 cp "s3://$S3Bucket/$S3Key" $ZipFile
    
    if (-not (Test-Path $ZipFile)) {
        throw "Failed to download deployment from S3"
    }
    
    Write-Host "✅ Downloaded: $ZipFile"
    
    # Stop IIS
    Write-Host "⏹️ Stopping IIS..."
    iisreset /stop
    
    # Extract deployment
    Write-Host "📦 Extracting deployment..."
    $ExtractPath = "$TempPath\extracted"
    if (Test-Path $ExtractPath) {
        Remove-Item -Path $ExtractPath -Recurse -Force
    }
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractPath -Force
    
    # Remove old files
    Write-Host "🗑️ Removing old files..."
    if (Test-Path "$AppPath\*") {
        Remove-Item -Path "$AppPath\*" -Recurse -Force
    }
    
    # Copy new files
    Write-Host "📂 Copying new files..."
    Copy-Item -Path "$ExtractPath\*" -Destination $AppPath -Recurse -Force
    
    # Install/update dependencies
    Write-Host "📦 Installing dependencies..."
    Set-Location "$AppPath\api"
    npm install --production --silent
    
    # Start PM2 processes
    Write-Host "▶️ Starting PM2 processes..."
    Set-Location $AppPath
    pm2 start ecosystem.config.js
    
    # Start IIS
    Write-Host "▶️ Starting IIS..."
    iisreset /start
    
    # Cleanup temp files
    Write-Host "🧹 Cleaning up..."
    Remove-Item -Path $TempPath -Recurse -Force
    New-Item -ItemType Directory -Force -Path $TempPath | Out-Null
    
    # Health check
    Write-Host "🔍 Performing health check..."
    Start-Sleep -Seconds 10
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost/health" -TimeoutSec 15 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Health check passed!"
        } else {
            Write-Host "⚠️ Health check returned status: $($response.StatusCode)"
        }
    } catch {
        Write-Host "⚠️ Health check failed: $_"
        Write-Host "Check PM2 status with: pm2 status"
    }
    
    Write-Host ""
    Write-Host "🎉 Deployment completed successfully!"
    Write-Host "🌐 Application available at: http://18.233.35.219"
    Write-Host "📊 Check PM2 status: pm2 status"
    Write-Host "📋 View PM2 logs: pm2 logs ras-dashboard-api"
    
} catch {
    Write-Error "❌ Deployment failed: $_"
    Write-Host ""
    Write-Host "🔄 To rollback, restore from backup:"
    Write-Host "Copy-Item -Path '$BackupPath\*' -Destination '$AppPath' -Recurse -Force"
    Write-Host "pm2 restart ras-dashboard-api"
    Write-Host "iisreset"
}