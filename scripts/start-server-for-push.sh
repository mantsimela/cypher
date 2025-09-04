#!/bin/bash

# Quick script to start EC2 server before pushing code
# This ensures your server is ready for deployment

INSTANCE_ID="i-0403b69b66141f5aa"
REGION="us-east-1"
STATIC_IP="18.233.35.219"

echo "🚀 Preparing server for code deployment..."

# Check current state
CURRENT_STATE=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

echo "Current server state: $CURRENT_STATE"

if [ "$CURRENT_STATE" = "stopped" ]; then
    echo "▶️ Starting EC2 instance..."
    aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION > /dev/null
    
    echo "⏳ Waiting for server to start..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    
    echo "✅ Server started! Waiting for services to initialize..."
    
    # Show progress bar
    for i in {30..1}; do
        printf "\r⏳ Initializing services... %2d seconds remaining" $i
        sleep 1
    done
    echo ""
    
    echo "🎯 Server is ready for deployment!"
    echo "💡 You can now push your code to GitHub"
    
elif [ "$CURRENT_STATE" = "running" ]; then
    echo "✅ Server is already running and ready!"
    echo "💡 You can push your code to GitHub immediately"
    
elif [ "$CURRENT_STATE" = "pending" ]; then
    echo "⏳ Server is already starting up..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    echo "✅ Server is now ready!"
    
else
    echo "⚠️ Server is in unexpected state: $CURRENT_STATE"
    echo "Please check AWS console or contact support"
    exit 1
fi

echo ""
echo "📋 Quick Commands:"
echo "git add ."
echo "git commit -m 'Deploy to production'"
echo "git push origin main"
echo ""
echo "🌐 After deployment, your app will be at: http://$STATIC_IP"