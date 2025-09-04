#!/bin/bash

# Script to verify and configure security groups for the existing Windows EC2 instance

INSTANCE_ID="i-0403b69b66141f5aa"
REGION="us-east-1"

echo "🔍 Checking security groups for instance $INSTANCE_ID..."

# Get current security groups
SECURITY_GROUPS=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' \
  --output text)

echo "Current security groups: $SECURITY_GROUPS"

for SG_ID in $SECURITY_GROUPS; do
  echo ""
  echo "🔒 Checking security group: $SG_ID"
  
  # Get security group rules
  aws ec2 describe-security-groups \
    --group-ids $SG_ID \
    --region $REGION \
    --query 'SecurityGroups[0].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[0].CidrIp]' \
    --output table
  
  echo ""
  echo "📋 Required ports for RAS Dashboard:"
  echo "- Port 80 (HTTP) - for web access"
  echo "- Port 443 (HTTPS) - for secure web access"
  echo "- Port 8080 (API) - for backend API"
  echo "- Port 3389 (RDP) - for remote desktop access"
  echo "- Port 22 (SSH) - for secure shell access (if needed)"
  echo "- Port 5986 (WinRM HTTPS) - for PowerShell remoting"
  
  echo ""
  echo "🛠️ To add missing rules, run:"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3389 --cidr 0.0.0.0/0"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0"
  echo "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 5986 --cidr 0.0.0.0/0"
done

echo ""
echo "✅ Security group verification complete!"