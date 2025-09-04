# Setup PM2 to auto-start when Windows Server boots
# Run this once on your Windows Server to configure automatic PM2 startup

param(
    [switch]$Uninstall = $false
)

$ErrorActionPreference = "Stop"

try {
    if ($Uninstall) {
        Write-Host "🗑️ Removing PM2 auto-start service..."
        
        # Stop and remove PM2 service
        try {
            pm2 kill
            pm2-service-uninstall
            Write-Host "✅ PM2 service removed successfully"
        } catch {
            Write-Host "⚠️ PM2 service may not be installed: $_"
        }
        
        # Remove startup script
        $StartupScript = "C:\deployments\startup\pm2-startup.ps1"
        if (Test-Path $StartupScript) {
            Remove-Item $StartupScript -Force
            Write-Host "✅ Startup script removed"
        }
        
        return
    }
    
    Write-Host "🚀 Setting up PM2 auto-start for Windows Server..."
    Write-Host "This will ensure PM2 starts automatically when the EC2 instance boots"
    
    # Create startup directory
    $StartupDir = "C:\deployments\startup"
    New-Item -ItemType Directory -Force -Path $StartupDir | Out-Null
    
    # Install PM2 as Windows service if not already installed
    Write-Host "📦 Installing PM2 as Windows service..."
    try {
        # Stop any running PM2 processes first
        pm2 kill
        
        # Install PM2 service
        pm2-service-install -n "PM2"
        Write-Host "✅ PM2 service installed"
    } catch {
        Write-Host "⚠️ PM2 service may already be installed: $_"
    }
    
    # Create startup script
    $StartupScript = @'
# PM2 Startup Script for RAS Dashboard
# This script runs when Windows starts and ensures PM2 is running with the correct processes

$ErrorActionPreference = "Continue"
$LogFile = "C:\logs\pm2\startup-$(Get-Date -Format 'yyyyMMdd').log"

function Write-StartupLog {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

Write-StartupLog "🚀 PM2 Startup Script Started"

try {
    # Wait for system to fully boot
    Write-StartupLog "⏳ Waiting 30 seconds for system to stabilize..."
    Start-Sleep -Seconds 30
    
    # Ensure PM2 service is running
    Write-StartupLog "🔍 Checking PM2 service status..."
    $pm2Service = Get-Service -Name "PM2" -ErrorAction SilentlyContinue
    
    if ($pm2Service) {
        if ($pm2Service.Status -ne "Running") {
            Write-StartupLog "▶️ Starting PM2 service..."
            Start-Service -Name "PM2"
            Start-Sleep -Seconds 10
        } else {
            Write-StartupLog "✅ PM2 service is already running"
        }
    } else {
        Write-StartupLog "❌ PM2 service not found - may need to reinstall"
        exit 1
    }
    
    # Set working directory
    $AppPath = "C:\inetpub\wwwroot\ras-dashboard"
    if (Test-Path $AppPath) {
        Set-Location $AppPath
        Write-StartupLog "📁 Set working directory to: $AppPath"
    } else {
        Write-StartupLog "⚠️ Application path not found: $AppPath"
    }
    
    # Check if ecosystem file exists
    if (Test-Path "$AppPath\ecosystem.config.js") {
        Write-StartupLog "📋 Found ecosystem config file"
        
        # Start PM2 processes
        Write-StartupLog "🚀 Starting PM2 processes..."
        pm2 start ecosystem.config.js
        
        # Wait and check status
        Start-Sleep -Seconds 15
        $processes = pm2 jlist | ConvertFrom-Json
        
        if ($processes -and $processes.Length -gt 0) {
            foreach ($process in $processes) {
                $status = if ($process.pm2_env.status -eq "online") { "✅" } else { "❌" }
                Write-StartupLog "$status Process: $($process.name) - Status: $($process.pm2_env.status)"
            }
        } else {
            Write-StartupLog "⚠️ No PM2 processes found after startup"
        }
        
    } else {
        Write-StartupLog "⚠️ Ecosystem config not found - application may not be deployed yet"
    }
    
    # Ensure IIS is running
    Write-StartupLog "🌐 Ensuring IIS is running..."
    try {
        $iisService = Get-Service -Name "W3SVC" -ErrorAction SilentlyContinue
        if ($iisService -and $iisService.Status -ne "Running") {
            Start-Service -Name "W3SVC"
            Write-StartupLog "✅ IIS started"
        } else {
            Write-StartupLog "✅ IIS is already running"
        }
    } catch {
        Write-StartupLog "⚠️ Error with IIS: $_"
    }
    
    Write-StartupLog "🎉 PM2 startup completed successfully"
    
} catch {
    Write-StartupLog "❌ PM2 startup failed: $_"
}
'@
    
    $StartupScriptPath = "$StartupDir\pm2-startup.ps1"
    $StartupScript | Out-File -FilePath $StartupScriptPath -Encoding UTF8
    Write-Host "✅ Created startup script: $StartupScriptPath"
    
    # Create Windows scheduled task to run at startup
    Write-Host "📅 Creating Windows scheduled task..."
    
    $TaskName = "PM2-RAS-Dashboard-Startup"
    $TaskDescription = "Auto-start PM2 for RAS Dashboard when Windows boots"
    
    # Remove existing task if it exists
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        # Task doesn't exist, which is fine
    }
    
    # Create new scheduled task
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$StartupScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description $TaskDescription
    Write-Host "✅ Scheduled task created: $TaskName"
    
    # Test the startup script
    Write-Host "🧪 Testing startup script..."
    & $StartupScriptPath
    
    Write-Host ""
    Write-Host "🎉 PM2 auto-start setup completed!"
    Write-Host ""
    Write-Host "📋 What happens now:"
    Write-Host "- ✅ PM2 will start automatically when the EC2 instance boots"
    Write-Host "- ✅ Your RAS Dashboard API will start automatically"
    Write-Host "- ✅ IIS will be ensured to be running"
    Write-Host "- ✅ Startup logs saved to: C:\logs\pm2\startup-YYYYMMDD.log"
    Write-Host ""
    Write-Host "🔍 To check status after reboot:"
    Write-Host "pm2 status"
    Write-Host "pm2 logs"
    Write-Host ""
    Write-Host "🗑️ To remove auto-start:"
    Write-Host ".\setup-pm2-autostart.ps1 -Uninstall"
    
} catch {
    Write-Error "❌ Setup failed: $_"
}