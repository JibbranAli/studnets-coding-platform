# Quick Start Guide

Get the platform running in 5 minutes!

## For AWS EC2 (Amazon Linux)

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform

# 2. Run setup script
chmod +x setup-amazon-linux.sh
./setup-amazon-linux.sh

# 3. Configure AWS Security Group
# Allow inbound traffic on ports: 8501, 80, 443

# 4. Access the platform
# http://YOUR_EC2_PUBLIC_IP:8501
```

## For Ubuntu/Debian

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform

# 2. Run setup script
chmod +x setup.sh
./setup.sh

# 3. Access the platform
# http://localhost:8501
```

## For Windows

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform

# 2. Run setup script
setup.bat

# 3. Access the platform
# http://localhost:8501
```

## Using Docker (All Platforms)

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform

# 2. Configure environment
cp .env.example .env
# Edit .env with your settings

# 3. Start with Docker Compose
docker-compose up -d

# 4. Access the platform
# http://localhost:8501
```

## First Login

### Admin Access
- URL: http://YOUR_IP:8501
- Tab: "Admin Login"
- Username: `admin` (or as configured)
- Password: (set during installation)

### Student Access
- Tab: "Student Registration"
- Register with your details
- Then login via "Student Login"

## Next Steps

1. **Admin:** Create your first test
2. **Admin:** Assign test to students
3. **Students:** Complete assigned tests
4. **Admin:** View results and export reports

## Need Help?

- 📖 Full Documentation: [README.md](README.md)
- 👥 User Guide: [USER_GUIDE.md](USER_GUIDE.md)
- 🚀 Deployment Guide: [DEPLOYMENT.md](DEPLOYMENT.md)
- ✅ Production Checklist: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

## Common Issues

**Port already in use:**
```bash
# Change port in .env
STREAMLIT_SERVER_PORT=8502
```

**Database connection error:**
```bash
# Use SQLite instead
DATABASE_URL=sqlite:///./student_platform.db
```

**Permission denied:**
```bash
# Fix permissions
chmod +x *.sh
```

## Support

- GitHub Issues: Report bugs and request features
- Documentation: Check all .md files
- Logs: `tail -f logs/app.log`
