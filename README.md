# 🐍 Student Code Debugging Platform

A production-ready platform for students to practice Python debugging with secure code execution and real-time feedback. Built for educational institutions supporting 400+ concurrent users.

## ✨ Features

- 🔐 **Secure Authentication** - Bcrypt password hashing, session management
- 🛡️ **Safe Code Execution** - Sandboxed Python environment with RestrictedPython
- 👨‍💼 **Admin Dashboard** - Create tests, assign to students, view results
- 🎓 **Student Portal** - Complete assigned tests, practice coding
- 📊 **Excel Reports** - Export results and student data
- ⚡ **Rate Limiting** - Protection against abuse
- 📝 **Audit Logging** - Track all security events
- 📈 **Monitoring** - Health checks and metrics

## 🚀 Quick Install

### One Command Installation

```bash
git clone https://github.com/JibbranAli/studnets-coding-platform.git
cd studnets-coding-platform
chmod +x install.sh
./install.sh
```

That's it! The script will:
- ✅ Install all dependencies
- ✅ Setup Python environment
- ✅ Configure database (SQLite)
- ✅ Create admin account
- ✅ Setup auto-start service
- ✅ Configure firewall

### Access Your Platform

**URL:** `http://YOUR_SERVER_IP:8501`

**Admin Login:**
- Username: (as configured during install)
- Password: (as configured during install)

## 📋 Requirements

- Linux (Ubuntu, Debian, Amazon Linux, CentOS, RHEL)
- Python 3.7+
- 2GB RAM minimum
- 10GB disk space

## 🎯 Usage

### For Administrators

1. **Login** - Use admin credentials
2. **Create Tests** - Write buggy Python code for students to fix
3. **Assign Tests** - Select students and assign tests
4. **View Results** - Monitor submissions and scores
5. **Export Reports** - Download Excel reports

### For Students

1. **Register** - Create account with email
2. **Login** - Access student dashboard
3. **View Tests** - See assigned debugging challenges
4. **Fix Code** - Debug and fix the buggy code
5. **Submit** - Get instant feedback and scores

## 🔧 Management

### Start/Stop Service

```bash
# Start
sudo systemctl start student-platform

# Stop
sudo systemctl stop student-platform

# Restart
sudo systemctl restart student-platform

# Status
sudo systemctl status student-platform
```

### View Logs

```bash
# Application logs
tail -f logs/app.log

# Service logs
sudo journalctl -u student-platform -f

# Audit logs
tail -f logs/audit.log
```

### Manual Start

```bash
source venv/bin/activate
streamlit run app.py
```

## 🔒 Security Features

- **Password Hashing** - Bcrypt encryption
- **Session Management** - Automatic timeout
- **Rate Limiting** - Prevent abuse
- **Code Sandboxing** - RestrictedPython
- **Input Validation** - Sanitized inputs
- **Audit Logging** - Track all actions
- **Failed Login Protection** - Account lockout

## 📊 Configuration

Edit `.env` file to customize:

```bash
# Database
DATABASE_URL=sqlite:///./student_platform.db

# Admin
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

# Security
SECRET_KEY=auto_generated
SESSION_TIMEOUT=3600
MAX_LOGIN_ATTEMPTS=5

# Rate Limiting
RATE_LIMIT_ENABLED=true
MAX_REQUESTS_PER_MINUTE=60
MAX_CODE_RUNS_PER_MINUTE=10

# Logging
LOG_LEVEL=INFO
```

## 🌐 AWS Deployment

### EC2 Setup

1. Launch EC2 instance (t2.medium or larger)
2. Configure Security Group:
   - Allow port 8501 (application)
   - Allow port 22 (SSH)
3. SSH into instance
4. Run installation script

```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
git clone https://github.com/JibbranAli/studnets-coding-platform.git
cd studnets-coding-platform
chmod +x install.sh
./install.sh
```

### Security Group Rules

| Type | Port | Source |
|------|------|--------|
| SSH | 22 | Your IP |
| Custom TCP | 8501 | 0.0.0.0/0 |

## 📖 Documentation

- **[USER_GUIDE.md](USER_GUIDE.md)** - Complete guide for students and admins
- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Detailed deployment guide
- **[PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)** - Pre-deployment checklist

## 🛠️ Troubleshooting

### Application won't start

```bash
# Check logs
sudo journalctl -u student-platform -xe

# Check if port is in use
sudo lsof -i :8501

# Restart service
sudo systemctl restart student-platform
```

### Database errors

```bash
# Reinitialize database
source venv/bin/activate
python3 -c "from database import init_db; init_db()"
```

### Permission errors

```bash
# Fix permissions
chmod 755 data logs backups
chown -R $USER:$USER .
```

## 🔄 Updates

```bash
# Pull latest changes
git pull origin main

# Reinstall dependencies
source venv/bin/activate
pip install -r requirements.txt

# Restart service
sudo systemctl restart student-platform
```

## 📦 Project Structure

```
studnets-coding-platform/
├── app.py                 # Main application
├── auth.py                # Authentication
├── code_runner.py         # Code execution engine
├── database.py            # Database models
├── excel_sync.py          # Excel export
├── config.py              # Configuration
├── logger.py              # Logging system
├── monitoring.py          # Health checks
├── security.py            # Security features
├── rate_limiter.py        # Rate limiting
├── healthcheck.py         # Health endpoint
├── install.sh             # Installation script
├── requirements.txt       # Python dependencies
├── .env.example           # Environment template
└── README.md              # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📄 License

MIT License - See LICENSE file for details

## 💬 Support

- **Issues:** [GitHub Issues](https://github.com/JibbranAli/studnets-coding-platform/issues)
- **Documentation:** Check the docs folder
- **Logs:** `tail -f logs/app.log`

## 🎓 Use Cases

- **Universities** - Programming courses and assignments
- **Coding Bootcamps** - Practice debugging skills
- **Online Education** - Remote learning platforms
- **Corporate Training** - Employee skill development

## 📈 Performance

- Supports 400+ concurrent users
- SQLite for simplicity (PostgreSQL supported)
- Efficient code execution with timeouts
- Rate limiting prevents overload
- Automatic session cleanup

## 🔐 Production Ready

- ✅ Security hardening
- ✅ Error handling
- ✅ Logging and monitoring
- ✅ Auto-restart on failure
- ✅ Rate limiting
- ✅ Input validation
- ✅ Session management

---

**Made with ❤️ for education**

**Repository:** https://github.com/JibbranAli/studnets-coding-platform
