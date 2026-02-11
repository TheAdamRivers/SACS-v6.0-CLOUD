#!/data/data/com.termux/files/usr/bin/bash
# SACS Edge - Cloud Configuration Script

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         SACS CLOUD CONFIGURATION                              ║"
echo "║         Connect Your Edge to Cloud Backend                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Get cloud URL from user
echo "Enter your Render cloud URL:"
echo "(Example: https://sacs-cloud-backend-abc123.onrender.com)"
echo ""
read -p "Cloud URL: " CLOUD_URL

# Validate URL
if [[ ! "$CLOUD_URL" =~ ^https:// ]]; then
    echo "❌ URL must start with https://"
    exit 1
fi

# Test connection
echo ""
echo "Testing connection to $CLOUD_URL..."
if curl -s --max-time 10 "$CLOUD_URL/health" > /dev/null; then
    echo "✅ Cloud backend is reachable"
else
    echo "⚠️ Could not reach backend (it may be sleeping on free tier)"
    echo "   First request takes 10-30s to wake it up"
fi

echo ""
echo "Creating cloud configuration..."

# Create config
cat > ~/.sacs/cloud_config.json << EOF
{
  "cloud_url": "$CLOUD_URL",
  "features": {
    "telemetry_upload": true,
    "cloud_analysis": true,
    "threat_intelligence": true,
    "forensic_reports": false
  }
}
EOF

echo "✅ Configuration saved to ~/.sacs/cloud_config.json"
echo ""

# Ask about restart
echo "SACS needs to restart to connect to cloud."
read -p "Restart SACS now? (y/n): " RESTART

if [[ "$RESTART" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Restarting SACS..."
    
    pkill -9 -f sacs_v6_complete
    sleep 2
    
    cd ~/SACS-Deployment
    python3 sacs_v6_complete.py &
    
    sleep 5
    
    if pgrep -f sacs_v6_complete >/dev/null; then
        echo "✅ SACS restarted (PID: $(pgrep -f sacs_v6_complete))"
    else
        echo "⚠️ SACS starting..."
    fi
    
    echo ""
    echo "Checking cloud connection..."
    sleep 5
    
    # Check if cloud is connected
    if tail -30 ~/.sacs/logs/sacs.log 2>/dev/null | grep -q "Cloud ML online"; then
        echo "✅ Cloud ML connected!"
    elif tail -30 ~/.sacs/logs/sacs.log 2>/dev/null | grep -q "Cloud offline"; then
        echo "⚠️ Cloud shows offline - backend may be sleeping"
        echo "   Wait 30 seconds and check again"
    else
        echo "⚠️ Check logs: tail ~/.sacs/logs/sacs.log"
    fi
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         CONFIGURATION COMPLETE                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Your SACS edge will now:"
echo "  • Upload telemetry to cloud (every 10 minutes)"
echo "  • Request heavy ML analysis (every hour)"
echo "  • Download threat intelligence updates"
echo ""
echo "To verify connection:"
echo "  tail -f ~/.sacs/logs/sacs.log | grep -i cloud"
echo ""
echo "To test cloud analysis:"
echo "  python ~/SACS-Deployment/test_cloud.py"
echo ""
