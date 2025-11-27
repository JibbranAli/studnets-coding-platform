# 🐍 Student Code Debugging Platform

[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-production--ready-brightgreen.svg)]()
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](docker-compose.yml)

A production-ready platform for students to practice Python debugging with secure code execution, real-time feedback, and comprehensive monitoring. Built for educational institutions to support 400+ concurrent users.

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get running in 5 minutes
- **[User Guide](USER_GUIDE.md)** - Complete guide for students and admins
- **[Deployment Guide](DEPLOYMENT.md)** - AWS EC2 production deployment
- **[GitHub Setup](GITHUB_SETUP.md)** - Push to GitHub instructions
- **[Production Checklist](PRODUCTION_CHECKLIST.md)** - Pre-deployment checklist

## ✨ Features

- 🔐 **Secure Authentication** - Bcrypt password hashing, session management, rate limiting
- 🛡️ **Sandboxed Code Execution** - RestrictedPython for safe code execution
- 📊 **Admin Dashboard** - Test creation, student management, results tracking
- 📈 **Production Monitoring** - Health checks, metrics, logging
- 🚀 **Scalable Architecture** - Docker support, PostgreSQL, Nginx reverse proxy
- 📝 **Excel Integration** - Automated report generation and sync
- ⚡ **Rate Limiting** - Protection against abuse and DoS attacks
- 📋 **Audit Logging** - Security event tracking

## 🚀 Quick Start

### Amazon Linux (AWS EC2)
```bash
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform
chmod +x setup-amazon-linux.sh
./setup-amazon-linux.sh
```

### Ubuntu/Debian
```bash
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform
chmod +x setup.sh
./setup.sh
```

### Windows
```bash
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform
setup.bat
```

### Docker (All Platforms)
```bash
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git
cd student-debug-platform
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
```

**Access:** http://localhost:8501 (or your server IP)  
**Default Admin:** Username from .env / Password from .env

📖 **Detailed instructions:** [QUICK_START.md](QUICK_START.md)

## Production Deployment

### Using Docker Compose (Recommended)

```bash
# Configure production settings
export PRODUCTION=true
export SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
export DB_PASSWORD=$(python3 -c "import secrets; print(secrets.token_urlsafe(16))")

# Deploy
chmod +x deploy.sh
./deploy.sh
```

### Using Systemd

```bash
# Run setup
./setup.sh

# Deploy with systemd
./deploy.sh
# Select option 2

# Manage service
sudo systemctl status student-platform
sudo systemctl restart student-platform
sudo journalctl -u student-platform -f
```

### AWS EC2 Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed AWS deployment guide.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | Database connection string | `sqlite:///./student_platform.db` |
| `SECRET_KEY` | Application secret key | Required in production |
| `ADMIN_USERNAME` | Admin username | `admin` |
| `ADMIN_PASSWORD` | Admin password | Required in production |
| `SESSION_TIMEOUT` | Session timeout (seconds) | `3600` |
| `MAX_LOGIN_ATTEMPTS` | Max failed login attempts | `5` |
| `CODE_EXECUTION_TIMEOUT` | Code execution timeout (seconds) | `5` |
| `RATE_LIMIT_ENABLED` | Enable rate limiting | `true` |
| `PRODUCTION` | Production mode flag | `false` |
| `LOG_LEVEL` | Logging level | `INFO` |

### Security Configuration

```bash
# Generate secure keys
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Set in .env
SECRET_KEY=<generated-key>
ADMIN_PASSWORD=<strong-password>
PRODUCTION=true
DEBUG=false
```

## Monitoring & Maintenance

### Health Check

```bash
# Manual health check
python3 healthcheck.py

# Docker health check
docker-compose ps
```

### View Logs

```bash
# Application logs
tail -f logs/app.log

# Audit logs
tail -f logs/audit.log

# Docker logs
docker-compose logs -f app
```

### Backup

```bash
# Create backup
chmod +x backup.sh
./backup.sh

# Backups stored in: backups/
```

### Metrics

Access metrics via the monitoring module:
```python
from monitoring import metrics
print(metrics.get_metrics())
```

## Security Features

### Code Execution Security
- RestrictedPython sandboxing
- Dangerous operation detection
- Execution timeout limits
- Output size limits
- Memory protection

### Authentication Security
- Bcrypt password hashing
- Session timeout
- Failed login attempt tracking
- Account lockout mechanism
- Rate limiting

### Network Security
- Nginx reverse proxy
- Rate limiting
- Request size limits
- Security headers
- HTTPS support (configure SSL)

## Performance Optimization

### For 400+ Concurrent Users

1. **Database Optimization:**
```bash
# Use PostgreSQL with connection pooling
DATABASE_URL=postgresql://user:pass@localhost/db?pool_size=20&max_overflow=40
```

2. **Resource Limits:**
```bash
# Adjust in .env
CODE_EXECUTION_TIMEOUT=3
MAX_CODE_LENGTH=5000
MAX_OUTPUT_LENGTH=2000
```

3. **Rate Limiting:**
```bash
MAX_REQUESTS_PER_MINUTE=60
MAX_CODE_RUNS_PER_MINUTE=10
```

4. **Scaling:**
```bash
# Use Docker Compose scaling
docker-compose up -d --scale app=3
```

## Troubleshooting

### Database Connection Issues
```bash
# Check database status
sudo systemctl status postgresql

# Test connection
psql -U student_user -d student_debug_platform
```

### High Memory Usage
```bash
# Check system resources
python3 healthcheck.py

# Restart service
sudo systemctl restart student-platform
```

### Code Execution Errors
```bash
# Check logs
tail -f logs/app.log | grep "code_execution"

# Verify RestrictedPython
python3 -c "from RestrictedPython import compile_restricted; print('OK')"
```

## API Documentation

### Admin Functions
- `create_test()` - Create debugging test
- `assign_test()` - Assign test to students
- `view_results()` - View submission results
- `export_excel()` - Export results to Excel

### Student Functions
- `submit_code()` - Submit code solution
- `run_code()` - Test code execution
- `view_assignments()` - View assigned tests

## Development

### Setup Development Environment
```bash
# Install dependencies
pip install -r requirements.txt

# Run in debug mode
DEBUG=true streamlit run app.py
```

### Run Tests
```bash
# Unit tests
python3 -m pytest tests/

# Code quality
flake8 .
black .
```

## License

MIT License - See LICENSE file

## Support

For issues and questions:
- GitHub Issues: <repository-url>/issues
- Documentation: [DEPLOYMENT.md](DEPLOYMENT.md)
- Email: support@example.com

## Changelog

### v1.0.0 (Production Ready)
- ✅ Secure authentication system
- ✅ Sandboxed code execution
- ✅ Production monitoring
- ✅ Docker support
- ✅ Rate limiting
- ✅ Audit logging
- ✅ Health checks
- ✅ Automated backups
