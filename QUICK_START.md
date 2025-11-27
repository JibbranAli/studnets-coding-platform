# ⚡ Quick Start Guide

Get the platform running in 2 minutes!

## Installation

### One Command

```bash
git clone https://github.com/JibbranAli/studnets-coding-platform.git
cd studnets-coding-platform
chmod +x install.sh
./install.sh
```

### What It Does

The install script will:
1. ✅ Install system dependencies
2. ✅ Setup Python virtual environment
3. ✅ Install Python packages
4. ✅ Configure environment
5. ✅ Setup admin account (you'll be prompted)
6. ✅ Initialize database
7. ✅ Create auto-start service
8. ✅ Configure firewall

### During Installation

You'll be asked:
- **Admin username** - Press Enter for default `admin`
- **Admin password** - Enter a secure password (min 8 characters)
- **Start now?** - Type `y` to start immediately

## Access

**URL:** `http://YOUR_SERVER_IP:8501`

### Find Your IP

```bash
# AWS EC2
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Other Linux
hostname -I | awk '{print $1}'
```

## First Login

### Admin
1. Go to **Admin Login** tab
2. Enter your admin credentials
3. Start creating tests!

### Student
1. Go to **Student Registration** tab
2. Fill in details and register
3. Login and complete tests

## Management

### Start/Stop

```bash
sudo systemctl start student-platform   # Start
sudo systemctl stop student-platform    # Stop
sudo systemctl status student-platform  # Check status
```

### View Logs

```bash
tail -f logs/app.log                    # Application logs
sudo journalctl -u student-platform -f  # Service logs
```

## AWS Users

### Security Group

Allow inbound traffic on port **8501**:

1. Go to EC2 Console
2. Select your instance
3. Security → Security Groups
4. Edit inbound rules
5. Add rule: Custom TCP, Port 8501, Source 0.0.0.0/0

## Troubleshooting

### Port already in use

```bash
# Kill process on port 8501
sudo lsof -i :8501
sudo kill -9 <PID>
```

### Service won't start

```bash
# Check logs
sudo journalctl -u student-platform -xe

# Restart
sudo systemctl restart student-platform
```

### Permission denied

```bash
chmod +x install.sh
chmod 755 data logs backups
```

## Manual Start

If you prefer not to use the service:

```bash
source venv/bin/activate
streamlit run app.py
```

## Next Steps

1. ✅ Create your first test (Admin)
2. ✅ Assign test to students (Admin)
3. ✅ Students register and complete tests
4. ✅ View results and export reports (Admin)

## Need Help?

- 📖 Full guide: [USER_GUIDE.md](USER_GUIDE.md)
- 📋 Detailed docs: [README.md](README.md)
- 🚀 Deployment: [DEPLOYMENT.md](DEPLOYMENT.md)
- 📝 Logs: `tail -f logs/app.log`

---

**That's it! You're ready to go! 🚀**
