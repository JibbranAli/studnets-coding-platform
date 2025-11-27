# 🐍 Student Code Debugging Platform

Production-ready platform for students to practice Python debugging with secure code execution. Supports 400+ concurrent users.

## ⚡ One-Command Installation

```bash
curl -sSL https://raw.githubusercontent.com/JibbranAli/studnets-coding-platform/main/install.sh | bash
```

Or clone and install:

```bash
git clone https://github.com/JibbranAli/studnets-coding-platform.git
cd studnets-coding-platform
chmod +x install.sh
./install.sh
```

**That's it!** The script automatically:
- ✅ Detects your OS (Ubuntu, Debian, Amazon Linux, CentOS, RHEL)
- ✅ Installs all dependencies
- ✅ Sets up Python environment
- ✅ Configures database (SQLite)
- ✅ Generates secure admin credentials
- ✅ Creates auto-start service
- ✅ Configures firewall
- ✅ Starts the application
- ✅ Shows you the dashboard URL

## 🎯 Features

- 🔐 **Secure Authentication** - Bcrypt, session management, rate limiting
- 🛡️ **Safe Code Execution** - Sandboxed Python with RestrictedPython
- 👨‍💼 **Admin Dashboard** - Create tests, assign to students, view results
- 🎓 **Student Portal** - Complete tests, practice coding, instant feedback
- 📊 **Excel Reports** - Export student data and results
- 📝 **Audit Logging** - Track all security events
- 📈 **Monitoring** - Health checks, metrics, system monitoring
- ⚡ **Rate Limiting** - DDoS protection

## 📋 Requirements

- Linux (Ubuntu, Debian, Amazon Linux, CentOS, RHEL)
- Python 3.7+
- 2GB RAM minimum
- Root/sudo access

## 🚀 Usage

### After Installation

The script will display:
```
Dashboard URL: http://YOUR_IP:8501
Admin Username: admin
Admin Password: [auto-generated]
```

**Save these credentials!**

### Access Dashboard

Open the URL in your browser and login with admin credentials.

### For Administrators

1. **Create Tests** - Write buggy Python code
2. **Assign Tests** - Select students and assign
3. **View Results** - Monitor submissions and scores
4. **Export Reports** - Download Excel reports

### For Students

1. **Register** - Create account
2. **Login** - Access dashboard
3. **Complete Tests** - Fix buggy code
4. **Submit** - Get instant feedback

## 🔧 Management

### Service Commands

```bash
# Check status
sudo systemctl status student-platform

# Stop service
sudo systemctl stop student-platform

# Start service
sudo systemctl start student-platform

# Restart service
sudo systemctl restart student-platform

# View logs
sudo journalctl -u student-platform -f
```

### Application Logs

```bash
# Application logs
tail -f logs/app.log

# Audit logs
tail -f logs/audit.log

# Service logs
tail -f logs/service.log
```

## 🌐 AWS Deployment

### EC2 Setup

1. Launch EC2 instance (t2.medium or larger)
2. Configure Security Group - Allow port 8501
3. SSH into instance
4. Run installation command

```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
curl -sSL https://raw.githubusercontent.com/JibbranAli/studnets-coding-platform/main/install.sh | bash
```

### Security Group

| Type | Port | Source |
|------|------|--------|
| SSH | 22 | Your IP |
| Custom TCP | 8501 | 0.0.0.0/0 |

## 🔒 Security

- **Password Hashing** - Bcrypt encryption
- **Session Management** - Auto timeout
- **Rate Limiting** - Prevent abuse
- **Code Sandboxing** - RestrictedPython
- **Input Validation** - Sanitized inputs
- **Audit Logging** - Track all actions
- **Account Lockout** - Failed login protection

## ⚙️ Configuration

Edit `.env` file to customize settings:

```bash
nano .env
```

Key settings:
- `ADMIN_USERNAME` - Admin username
- `ADMIN_PASSWORD` - Admin password
- `SESSION_TIMEOUT` - Session timeout (seconds)
- `MAX_LOGIN_ATTEMPTS` - Max failed logins
- `RATE_LIMIT_ENABLED` - Enable rate limiting
- `LOG_LEVEL` - Logging level (INFO, DEBUG, ERROR)

After changes, restart:
```bash
sudo systemctl restart student-platform
```

## 🛠️ Troubleshooting

### Service won't start

```bash
# Check logs
sudo journalctl -u student-platform -xe

# Check if port is in use
sudo lsof -i :8501

# Restart
sudo systemctl restart student-platform
```

### Can't access dashboard

1. Check service is running: `sudo systemctl status student-platform`
2. Check firewall allows port 8501
3. For AWS: Check Security Group allows port 8501
4. Check logs: `tail -f logs/app.log`

### Database errors

```bash
# Reinitialize database
source venv/bin/activate
python3 -c "from database import init_db; init_db()"
sudo systemctl restart student-platform
```

## 📦 Project Structure

```
studnets-coding-platform/
├── app.py              # Main application
├── auth.py             # Authentication
├── code_runner.py      # Code execution
├── database.py         # Database models
├── config.py           # Configuration
├── logger.py           # Logging
├── monitoring.py       # Health checks
├── security.py         # Security features
├── rate_limiter.py     # Rate limiting
├── excel_sync.py       # Excel export
├── install.sh          # Installation script
├── requirements.txt    # Dependencies
└── README.md           # This file
```

## 🔄 Updates

```bash
cd studnets-coding-platform
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart student-platform
```

## 📊 Performance

- Supports 400+ concurrent users
- SQLite for simplicity
- Efficient code execution with timeouts
- Rate limiting prevents overload
- Automatic session cleanup
- Resource monitoring

## 📖 Documentation

- **[USER_GUIDE.md](USER_GUIDE.md)** - Complete guide for students and admins

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📄 License

MIT License

## 💬 Support

- **Issues:** [GitHub Issues](https://github.com/JibbranAli/studnets-coding-platform/issues)
- **Logs:** `tail -f logs/app.log`

## 🎓 Use Cases

- Universities - Programming courses
- Coding Bootcamps - Debugging practice
- Online Education - Remote learning
- Corporate Training - Skill development

---

**Made with ❤️ for education**

**Repository:** https://github.com/JibbranAli/studnets-coding-platform

**One command. Zero configuration. Production ready.** 🚀
