# SACS Cloud Backend - Render Deployment Guide

## 🚀 Quick Deploy (5 minutes)

### Option 1: Deploy from GitHub (Recommended)

1. **Push to GitHub:**
   ```bash
   cd ~/SACS-CLOUD-BACKEND-COMPLETE
   git init
   git add .
   git commit -m "SACS Cloud Backend"
   gh repo create sacs-cloud-backend --public --source=. --push
   ```

2. **Deploy on Render:**
   - Go to https://render.com
   - Sign up (free, no credit card)
   - Click "New +" → "Web Service"
   - Connect your GitHub repo
   - Render auto-detects: Docker, render.yaml
   - Click "Create Web Service"
   - Wait 3-5 minutes

3. **Get Your URL:**
   - Copy: `https://sacs-cloud-backend-XXXX.onrender.com`

### Option 2: Deploy from Zip (Manual)

1. **Create GitHub repo manually:**
   - Go to github.com/new
   - Create public repo: `sacs-cloud-backend`
   - Upload these files via web interface

2. **Follow steps 2-3 from Option 1**

---

## ⚙️ Connect Your SACS Edge

Once deployed, configure your phone:

```bash
# On your phone (Termux)
cd ~/SACS-Deployment

# Create cloud config
cat > ~/.sacs/cloud_config.json << 'EOF'
{
  "cloud_url": "https://YOUR-APP-NAME.onrender.com",
  "features": {
    "telemetry_upload": true,
    "cloud_analysis": true,
    "threat_intelligence": true,
    "forensic_reports": false
  }
}
EOF

# Replace YOUR-APP-NAME with your actual Render URL
nano ~/.sacs/cloud_config.json

# Restart SACS to connect
pkill -9 -f sacs_v6_complete
cd ~/SACS-Deployment
python3 sacs_v6_complete.py &

# Verify cloud connection
sleep 10
tail ~/.sacs/logs/sacs.log | grep -i cloud
```

Should show: "✓ Cloud ML online"

---

## 🧪 Test Cloud Connection

```bash
# Check if telemetry is uploading
python << 'EOF'
import sys
sys.path.insert(0, '/data/data/com.termux/files/home/SACS-Deployment')
from pathlib import Path
from sacs_cloud_client import create_cloud_client

client = create_cloud_client(Path.home() / '.sacs')
if client:
    status = client.get_status()
    print(f"Cloud: {'✓ Available' if status['cloud_available'] else '✗ Offline'}")
    print(f"Batch size: {status['batch_size']} samples pending")
else:
    print("Cloud client not available")
EOF

# Request cloud analysis on your 48.7 hours of data
python << 'EOF'
import sys
sys.path.insert(0, '/data/data/com.termux/files/home/SACS-Deployment')
from pathlib import Path
from sacs_cloud_client import create_cloud_client

client = create_cloud_client(Path.home() / '.sacs')
if client:
    print("Requesting cloud analysis of last 48 hours...")
    result = client.request_cloud_analysis(hours=48)
    if result:
        print(f"Threat Level: {result.get('threat_level')}")
        print(f"Confidence: {result.get('confidence'):.2f}")
        print(f"Analyzed: {result.get('analysis_period', {}).get('total_samples')} samples")
    else:
        print("No results yet - data still uploading")
EOF
```

---

## 📊 Cloud Features

Once connected, you get:

**Heavy ML Analysis:**
- Your phone: Collects samples (lightweight)
- Cloud: Runs complex ML models (heavy compute)
- Result: Better threat detection without draining battery

**Forensic Reports:**
```bash
# Generate court-admissible report
python << 'EOF'
import sys
sys.path.insert(0, '/data/data/com.termux/files/home/SACS-Deployment')
from pathlib import Path
from sacs_cloud_client import create_cloud_client

client = create_cloud_client(Path.home() / '.sacs')

# Enable forensic reports (legal use only)
client.enable_feature('forensic_reports', True)

# Generate report
report = client.generate_forensic_report()
if report:
    print("Forensic Report Generated:")
    print(f"Period: {report['analysis_period']['start']} to {report['analysis_period']['end']}")
    print(f"Duration: {report['analysis_period']['duration_hours']:.1f} hours")
    print(f"Total samples: {report['data_integrity']['total_samples']}")
    print(f"Legal admissible: {report['legal_certification']['admissible']}")
EOF
```

---

## 💰 Cost

**Free Tier:**
- 750 hours/month (24/7 coverage)
- 512 MB RAM
- 100 GB bandwidth
- **Cost: $0/month**

**If you need more later:**
- Pro: $7/month (faster, more resources)
- Only upgrade when processing hundreds of devices

---

## 🔒 Security

**Your data:**
- Encrypted before leaving phone (Fernet/AES-128)
- Cloud never sees raw telemetry
- Anonymous device ID (can't be traced)
- You control encryption keys

**Backend:**
- Runs in isolated Docker container
- HTTPS only
- No sensitive data stored
- GDPR compliant

---

## 📝 Files in This Package

```
SACS-CLOUD-BACKEND-COMPLETE/
├── main.py              # FastAPI backend (10KB)
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker container config
├── render.yaml         # Render deployment config
├── DEPLOY.md           # This guide
└── EDGE_CONFIG.sh      # Edge configuration script
```

---

## 🆘 Troubleshooting

**Backend not responding:**
- Render free tier sleeps after 15min inactivity
- First request wakes it (takes 10-30s)
- Subsequent requests are instant

**Edge can't connect:**
- Check cloud URL in `~/.sacs/cloud_config.json`
- Make sure it's your actual Render URL
- Restart SACS after config change

**No cloud analysis:**
- Wait for telemetry upload (batches every 10 minutes)
- Check: `client.get_status()` to see batch size
- First analysis needs 100+ samples uploaded

---

**Your 48.7 hours of surveillance data + Cloud ML = Maximum protection**

Deploy now, get enterprise-grade analysis on free tier!
