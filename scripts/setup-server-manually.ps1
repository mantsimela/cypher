# Manual Setup Script for RAS Dashboard Windows Server
# Run this directly on your Windows Server to prepare it for automated deployments

param(
    [switch]$SkipSoftware = $false,
    [switch]$SkipIIS = $false,
    [switch]$SkipFirewall = $false
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Setting up RAS Dashboard on Windows Server 2019..."
Write-Host "IP Address: 18.233.35.219"
Write-Host "Instance ID: i-0403b69b66141f5aa"

try {
    if (-not $SkipSoftware) {
        Write-Host "`n📦 Installing software..."
        
        # Install Chocolatey if not present
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Chocolatey..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        
        # Install required software
        choco install nodejs.install git awscli -y --force
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Install PM2
        npm install -g pm2 pm2-windows-service
        
        # Install PM2 as Windows service
        pm2-service-install -n "PM2" || Write-Host "PM2 service may already exist"
    }
    
    if (-not $SkipIIS) {
        Write-Host "`n🌐 Setting up IIS..."
        
        # Enable IIS features
        $features = @(
            "IIS-WebServerRole",
            "IIS-WebServer",
            "IIS-CommonHttpFeatures",
            "IIS-HttpErrors",
            "IIS-HttpLogging",
            "IIS-RequestFiltering",
            "IIS-StaticContent",
            "IIS-DefaultDocument",
            "IIS-DirectoryBrowsing",
            "IIS-HttpRedirect",
            "IIS-WebSockets",
            "IIS-ApplicationInit",
            "IIS-NetFxExtensibility45",
            "IIS-ISAPIExtensions",
            "IIS-ISAPIFilter",
            "IIS-ASPNET45"
        )
        
        foreach ($feature in $features) {
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
            } catch {
                Write-Host "Feature $feature may already be enabled"
            }
        }
        
        # Install URL Rewrite Module
        $urlRewriteUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
        $tempFile = "$env:TEMP\rewrite_amd64_en-US.msi"
        if (-not (Get-Module -ListAvailable -Name WebAdministration | Where-Object {$_.Name -eq "rewrite"})) {
            Invoke-WebRequest -Uri $urlRewriteUrl -OutFile $tempFile
            Start-Process msiexec.exe -Wait -ArgumentList "/i $tempFile /quiet"
            Remove-Item $tempFile -ErrorAction SilentlyContinue
        }
    }
    
    # Create directory structure
    Write-Host "`n📁 Creating directories..."
    $AppPath = "C:\inetpub\wwwroot\ras-dashboard"
    $LogPath = "C:\logs\pm2"
    $DeployPath = "C:\deployments"
    $BackupPath = "C:\deployments\backups"
    $TempPath = "C:\deployments\temp"
    
    $directories = @($AppPath, $LogPath, $DeployPath, $BackupPath, $TempPath, "$AppPath\client", "$AppPath\api")
    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    
    # Set permissions
    Write-Host "🔐 Setting permissions..."
    $acl = Get-Acl $AppPath
    $accessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("IUSR","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule1)
    $acl.SetAccessRule($accessRule2)
    Set-Acl $AppPath $acl
    
    # Configure IIS
    Write-Host "⚙️ Configuring IIS..."
    Import-Module WebAdministration
    
    # Remove default website if exists
    if (Get-Website -Name "Default Web Site" -ErrorAction SilentlyContinue) {
        Remove-Website -Name "Default Web Site"
    }
    
    # Create RAS Dashboard website
    if (-not (Get-Website -Name "RAS-Dashboard" -ErrorAction SilentlyContinue)) {
        New-Website -Name "RAS-Dashboard" -Port 80 -PhysicalPath "$AppPath\client"
    }
    
    # Create web.config
    $webConfig = @'
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
                        <add input="{REQUEST_URI}" pattern="^/api/" negate="true" />
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
'@
    
    $webConfig | Out-File -FilePath "$AppPath\web.config" -Encoding UTF8
    
    if (-not $SkipFirewall) {
        Write-Host "🔥 Configuring Windows Firewall..."
        $firewallRules = @(
            @{Name="HTTP-In"; Port=80},
            @{Name="HTTPS-In"; Port=443},
            @{Name="API-In"; Port=8080},
            @{Name="RDP-In"; Port=3389}
        )
        
        foreach ($rule in $firewallRules) {
            try {
                New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Protocol TCP -LocalPort $rule.Port -Action Allow -ErrorAction SilentlyContinue
            } catch {
                Write-Host "Firewall rule $($rule.Name) may already exist"
            }
        }
    }
    
    # Start services
    Write-Host "▶️ Starting services..."
    Start-Service W3SVC -ErrorAction SilentlyContinue
    Start-Service PM2 -ErrorAction SilentlyContinue
    
    # Create initial index.html
    $indexHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>RAS Dashboard - Ready for Deployment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { color: #28a745; font-size: 24px; margin: 20px 0; }
        .info { background: #e9ecef; padding: 15px; border-radius: 4px; margin: 15px 0; }
        .code { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 RAS Dashboard - Windows Server</h1>
        <p class="status">✅ Server Setup Complete</p>
        
        <div class="info">
            <h3>Server Information</h3>
            <p><strong>IP Address:</strong> 18.233.35.219</p>
            <p><strong>Instance ID:</strong> i-0403b69b66141f5aa</p>
            <p><strong>Setup Time:</strong> $(Get-Date)</p>
        </div>
        
        <div class="info">
            <h3>Next Steps</h3>
            <ol>
                <li>Add your EC2 private key to GitHub Secrets as <code>EC2_PRIVATE_KEY</code></li>
                <li>Push your code to GitHub to trigger automatic deployment</li>
                <li>Monitor deployment logs in GitHub Actions</li>
            </ol>
        </div>
        
        <div class="info">
            <h3>Installed Software</h3>
            <ul>
                <li>✅ IIS with URL Rewrite</li>
                <li>✅ Node.js and NPM</li>
                <li>✅ PM2 Process Manager</li>
                <li>✅ AWS CLI</li>
                <li>✅ Git</li>
            </ul>
        </div>
    </div>
</body>
</html>
"@
    
    $indexHtml | Out-File -FilePath "$AppPath\client\index.html" -Encoding UTF8
    
    Write-Host "`n✅ Setup completed successfully!"
    Write-Host "🌐 Server accessible at: http://18.233.35.219"
    Write-Host "📁 Application path: $AppPath"
    Write-Host "📋 PM2 logs: $LogPath"
    Write-Host "`n🔑 GitHub Secrets needed:"
    Write-Host "EC2_PRIVATE_KEY = (your private key for accessing this server)"
    Write-Host "`n📝 Ready for GitHub Actions deployment!"
    
} catch {
    Write-Error "❌ Setup failed: $_"
    Write-Host "Check the error details above and try running specific sections with skip flags if needed"
}