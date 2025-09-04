#!/bin/bash

# Script to start the EC2 instance and wait for it to be ready
# Useful for manual deployments or demos

INSTANCE_ID="i-0403b69b66141f5aa"
REGION="us-east-1"
STATIC_IP="18.233.35.219"

echo "🚀 Starting EC2 instance for RAS Dashboard..."
echo "Instance ID: $INSTANCE_ID"
echo "Static IP: $STATIC_IP"

# Check current state
CURRENT_STATE=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

echo "Current state: $CURRENT_STATE"

if [ "$CURRENT_STATE" = "stopped" ]; then
    echo "▶️ Starting instance..."
    aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION
    
    echo "⏳ Waiting for instance to be running..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    
    echo "✅ Instance is now running!"
    echo "⏳ Waiting additional 60 seconds for PM2 auto-start to initialize..."
    
    # Show countdown
    for i in {60..1}; do
        echo -ne "\r⏳ Waiting $i seconds for services to start..."
        sleep 1
    done
    echo ""
    
elif [ "$CURRENT_STATE" = "running" ]; then
    echo "✅ Instance is already running!"
    
elif [ "$CURRENT_STATE" = "pending" ]; then
    echo "⏳ Instance is starting up..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    echo "✅ Instance is now running!"
    
else
    echo "⚠️ Instance is in state: $CURRENT_STATE"
fi

# Health check
echo ""
echo "🔍 Performing health check..."
sleep 5

for attempt in {1..6}; do
    echo "Attempt $attempt/6..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "http://$STATIC_IP/health" --connect-timeout 10 || echo "000")
    
    if [ "$response" = "200" ]; then
        echo "✅ Health check passed! Application is ready."
        echo "🌐 RAS Dashboard available at: http://$STATIC_IP"
        break
    elif [ "$attempt" = "6" ]; then
        echo "⚠️ Health check failed after 6 attempts"
        echo "💡 The application may still be starting up. Check manually:"
        echo "   curl http://$STATIC_IP/health"
        echo "   http://$STATIC_IP"
    else
        echo "⏳ Not ready yet (status: $response), waiting 10 seconds..."
        sleep 10
    fi
done

echo ""
echo "📋 Instance Information:"
echo "- Instance ID: $INSTANCE_ID"
echo "- Static IP: $STATIC_IP"
echo "- Status: $(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].State.Name' --output text)"
echo ""
echo "🎯 Ready for deployment or demo!"