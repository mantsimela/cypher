#!/bin/bash

# AWS Infrastructure Setup Script for Windows EC2 Deployment
# This script creates the necessary AWS resources for your RAS Dashboard deployment

set -e

echo "🚀 Setting up AWS infrastructure for RAS Dashboard deployment..."

# Variables
VPC_NAME="ras-dashboard-vpc"
SUBNET_NAME="ras-dashboard-public-subnet"
IGW_NAME="ras-dashboard-igw"
ROUTE_TABLE_NAME="ras-dashboard-route-table"
SECURITY_GROUP_NAME="ras-dashboard-sg"
KEY_PAIR_NAME="ras-dashboard-key"
INSTANCE_NAME="ras-dashboard-windows-server"
REGION=${AWS_DEFAULT_REGION:-us-east-1}

# Create VPC
echo "📡 Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
  --query 'Vpc.VpcId' \
  --output text)
echo "VPC created: $VPC_ID"

# Create Internet Gateway
echo "🌐 Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$IGW_NAME}]" \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID
echo "Internet Gateway created and attached: $IGW_ID"

# Create Public Subnet
echo "🏗️ Creating public subnet..."
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone "${REGION}a" \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$SUBNET_NAME}]" \
  --query 'Subnet.SubnetId' \
  --output text)
echo "Subnet created: $SUBNET_ID"

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_ID \
  --map-public-ip-on-launch

# Create Route Table
echo "🛣️ Creating route table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$ROUTE_TABLE_NAME}]" \
  --query 'RouteTable.RouteTableId' \
  --output text)

# Add route to Internet Gateway
aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

# Associate route table with subnet
aws ec2 associate-route-table \
  --route-table-id $ROUTE_TABLE_ID \
  --subnet-id $SUBNET_ID
echo "Route table created and configured: $ROUTE_TABLE_ID"

# Create Security Group
echo "🔒 Creating security group..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
  --group-name $SECURITY_GROUP_NAME \
  --description "Security group for RAS Dashboard Windows Server" \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$SECURITY_GROUP_NAME}]" \
  --query 'GroupId' \
  --output text)

# Add security group rules
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 3389 \
  --cidr 0.0.0.0/0 \
  --description "RDP access"

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --description "HTTP access"

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0 \
  --description "HTTPS access"

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0 \
  --description "API access"

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --description "SSH access"

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 5986 \
  --cidr 0.0.0.0/0 \
  --description "WinRM HTTPS"

echo "Security group created: $SECURITY_GROUP_ID"

# Create Key Pair
echo "🔑 Creating key pair..."
aws ec2 create-key-pair \
  --key-name $KEY_PAIR_NAME \
  --query 'KeyMaterial' \
  --output text > ${KEY_PAIR_NAME}.pem
chmod 600 ${KEY_PAIR_NAME}.pem
echo "Key pair created: ${KEY_PAIR_NAME}.pem"

# Get latest Windows Server 2019 AMI
echo "🖥️ Finding latest Windows Server 2019 AMI..."
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=Windows_Server-2019-English-Full-Base-*" "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)
echo "Using AMI: $AMI_ID"

# Create EC2 instance
echo "🚀 Creating EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.medium \
  --key-name $KEY_PAIR_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --subnet-id $SUBNET_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --user-data file://scripts/windows-userdata.ps1 \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance created: $INSTANCE_ID"

# Allocate Elastic IP
echo "📍 Allocating Elastic IP..."
ALLOCATION_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=${INSTANCE_NAME}-eip}]" \
  --query 'AllocationId' \
  --output text)

# Wait for instance to be running
echo "⏳ Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Associate Elastic IP
aws ec2 associate-address \
  --instance-id $INSTANCE_ID \
  --allocation-id $ALLOCATION_ID

# Get the Elastic IP address
ELASTIC_IP=$(aws ec2 describe-addresses \
  --allocation-ids $ALLOCATION_ID \
  --query 'Addresses[0].PublicIp' \
  --output text)

echo "✅ Infrastructure setup complete!"
echo ""
echo "📋 Summary:"
echo "- VPC ID: $VPC_ID"
echo "- Subnet ID: $SUBNET_ID"
echo "- Security Group ID: $SECURITY_GROUP_ID"
echo "- Instance ID: $INSTANCE_ID"
echo "- Elastic IP: $ELASTIC_IP"
echo "- Key Pair: ${KEY_PAIR_NAME}.pem"
echo ""
echo "🔐 GitHub Secrets to add:"
echo "EC2_INSTANCE_ID=$INSTANCE_ID"
echo "EC2_HOST=$ELASTIC_IP"
echo "EC2_USERNAME=Administrator"
echo "EC2_PRIVATE_KEY=(contents of ${KEY_PAIR_NAME}.pem)"
echo ""
echo "⏳ Please wait 5-10 minutes for the instance to fully initialize before attempting deployment."