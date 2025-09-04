<powershell>
# Windows Server 2019 Setup Script for RAS Dashboard
# This script configures IIS, Node.js, PM2, and necessary tools for deployment

$ErrorActionPreference = "Stop"

# Create log directory
New-Item -ItemType Directory -Force -Path "C:\logs\setup"
Start-Transcript -Path "C:\logs\setup\setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

Write-Host "🚀 Starting RAS Dashboard Windows Server setup..."

try {
    # Install Chocolatey
    Write-Host "📦 Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Install required software
    Write-Host "🛠️ Installing Node.js, Git, and AWS CLI..."
    choco install nodejs.install git awscli -y
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Install PM2 globally
    Write-Host "⚙️ Installing PM2..."
    npm install -g pm2
    npm install -g pm2-windows-service
    
    # Install PM2 as Windows service
    pm2-service-install -n "PM2"
    
    # Install IIS and required features
    Write-Host "🌐 Installing IIS and features..."
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter -All
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
    
    # Install URL Rewrite Module
    Write-Host "🔄 Installing IIS URL Rewrite Module..."
    $urlRewriteUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
    $tempFile = "$env:TEMP\rewrite_amd64_en-US.msi"
    Invoke-WebRequest -Uri $urlRewriteUrl -OutFile $tempFile
    Start-Process msiexec.exe -Wait -ArgumentList "/i $tempFile /quiet"
    Remove-Item $tempFile
    
    # Create application directories
    Write-Host "📁 Creating application directories..."
    $AppPath = "C:\inetpub\wwwroot\ras-dashboard"
    $LogPath = "C:\logs\pm2"
    $DeployPath = "C:\deployments"
    $BackupPath = "C:\deployments\backups"
    $TempPath = "C:\deployments\temp"
    
    New-Item -ItemType Directory -Force -Path $AppPath, $LogPath, $DeployPath, $BackupPath, $TempPath
    
    # Set permissions
    Write-Host "🔐 Setting permissions..."
    $acl = Get-Acl $AppPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule)
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IUSR","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl $AppPath $acl
    
    # Configure IIS
    Write-Host "⚙️ Configuring IIS..."
    Import-Module WebAdministration
    
    # Remove default website
    Remove-Website -Name "Default Web Site" -ErrorAction SilentlyContinue
    
    # Create new website for RAS Dashboard
    New-Website -Name "RAS-Dashboard" -Port 80 -PhysicalPath "$AppPath\client" -ErrorAction SilentlyContinue
    
    # Create virtual directory for API
    New-WebVirtualDirectory -Site "RAS-Dashboard" -Name "api" -PhysicalPath "$AppPath\api" -ErrorAction SilentlyContinue
    
    # Create web.config for URL rewriting
    $webConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="API Proxy" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://localhost:8080/api/v1/{R:1}" />
                </rule>
                <rule name="React Router" stopProcessing="true">
                    <match url=".*" />
                    <conditions logicalGrouping="MatchAll">
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="/index.html" />
                </rule>
            </rules>
        </rewrite>
        <defaultDocument>
            <files>
                <clear />
                <add value="index.html" />
            </files>
        </defaultDocument>
        <staticContent>
            <mimeMap fileExtension=".js" mimeType="application/javascript" />
            <mimeMap fileExtension=".css" mimeType="text/css" />
            <mimeMap fileExtension=".json" mimeType="application/json" />
        </staticContent>
    </system.webServer>
</configuration>
"@
    
    $webConfig | Out-File -FilePath "$AppPath\web.config" -Encoding UTF8
    
    # Configure Windows Firewall
    Write-Host "🔥 Configuring Windows Firewall..."
    New-NetFirewallRule -DisplayName "HTTP-In" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
    New-NetFirewallRule -DisplayName "HTTPS-In" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
    New-NetFirewallRule -DisplayName "API-In" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
    New-NetFirewallRule -DisplayName "RDP-In" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
    
    # Start IIS
    Write-Host "▶️ Starting IIS..."
    Start-Service W3SVC
    
    # Create a sample index.html
    $indexHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>RAS Dashboard - Setup Complete</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .container { max-width: 600px; margin: 0 auto; text-align: center; }
        .status { color: green; font-size: 24px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 RAS Dashboard Server</h1>
        <p class="status">✅ Setup Complete</p>
        <p>Server is ready for deployment.</p>
        <p>Server Time: $(Get-Date)</p>
    </div>
</body>
</html>
"@
    
    $indexHtml | Out-File -FilePath "$AppPath\client\index.html" -Encoding UTF8
    
    Write-Host "✅ Setup completed successfully!"
    Write-Host "🌐 Server is accessible at: http://18.233.35.219"
    Write-Host "📁 Application path: $AppPath"
    Write-Host "📋 Logs path: $LogPath"
    
} catch {
    Write-Error "❌ Setup failed: $_"
    throw
} finally {
    Stop-Transcript
}
</powershell>