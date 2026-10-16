
param(
    [string]$Region = "eu-north-1",
    [string]$AlarmName = "production-ec2-system-recovery",
    [string]$PublicIp = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($PublicIp)) {
    $PublicIp = Read-Host "Enter the EC2 public IP address"
}

Write-Host "`nChecking HTTP endpoint: http://$PublicIp"

try {
    $response = Invoke-WebRequest `
        -Uri "http://$PublicIp" `
        -Method Head `
        -TimeoutSec 10 `
        -UseBasicParsing

    Write-Host "HTTP status: $([int]$response.StatusCode)"
}
catch {
    Write-Warning "HTTP check failed: $($_.Exception.Message)"
}

Write-Host "`nChecking CloudWatch alarm: $AlarmName"

aws cloudwatch describe-alarms `
    --region $Region `
    --alarm-names $AlarmName `
    --query "MetricAlarms[0].{Name:AlarmName,State:StateValue,Metric:MetricName,Actions:AlarmActions}" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "AWS CLI alarm query failed. Check AWS credentials and permissions."
}
