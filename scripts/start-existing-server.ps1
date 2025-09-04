# PowerShell script to start the existing Windows EC2 instance
# Run this locally to start your server before deployment

param(
    [string]$InstanceId = "i-0403b69b66141f5aa",
    [string]$Region = "us-east-1"
)

Write-Host "🚀 Starting Windows EC2 instance..."
Write-Host "Instance ID: $InstanceId"
Write-Host "Region: $Region"

try {
    # Start the instance
    aws ec2 start-instances --instance-ids $InstanceId --region $Region
    
    # Wait for it to be running
    Write-Host "⏳ Waiting for instance to start..."
    aws ec2 wait instance-running --instance-ids $InstanceId --region $Region
    
    # Get instance details
    $instanceDetails = aws ec2 describe-instances --instance-ids $InstanceId --region $Region --query 'Reservations[0].Instances[0].[State.Name,PublicIpAddress]' --output text
    $state, $publicIp = $instanceDetails -split "`t"
    
    Write-Host "✅ Instance started successfully!"
    Write-Host "State: $state"
    Write-Host "Public IP: $publicIp"
    Write-Host "🌐 Server accessible at: http://$publicIp"
    
    # Check if server responds
    Write-Host "🔍 Checking server health..."
    Start-Sleep -Seconds 30
    
    try {
        $response = Invoke-WebRequest -Uri "http://$publicIp" -TimeoutSec 10 -UseBasicParsing
        Write-Host "✅ Server is responding (Status: $($response.StatusCode))"
    } catch {
        Write-Host "⚠️ Server not responding yet, may need more time to initialize"
    }
    
} catch {
    Write-Error "❌ Failed to start instance: $_"
}