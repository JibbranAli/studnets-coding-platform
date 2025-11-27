#!/bin/bash

# ============================================
# Student Code Debugging Platform
# Fully Automated Installation
# ============================================

set -e

clear
echo "============================================"
echo "  Student Code Debugging Platform"
echo "  Automated Installation"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${BLUE}➜ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; exit 1; }

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print_error "Cannot detect OS"
fi

print_info "Detected OS: $OS"
echo ""

# ============================================
# STEP 1: Install System Dependencies
# ============================================
print_info "Installing system dependencies..."

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq > /dev/null 2>&1
    sudo apt-get install -y python3 python3-pip python3-venv gcc python3-dev curl > /dev/null 2>&1
elif [ "$OS" = "amzn" ]; then
    sudo yum install -y python3 python3-pip gcc python3-devel curl -q > /dev/null 2>&1
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    sudo yum install -y python3 python3-pip gcc python3-devel curl -q > /dev/null 2>&1
else
    print_error "Unsupported OS: $OS"
fi

print_success "System dependencies installed"

# ============================================
# STEP 2: Setup Python Environment
# ============================================
print_info "Setting up Python environment..."

python3 -m venv venv > /dev/null 2>&1
source venv/bin/activate
pip install --upgrade pip -q > /dev/null 2>&1
pip install -r requirements.txt -q > /dev/null 2>&1

print_success "Python environment ready"

# ============================================
# STEP 3: Auto-Configure Application
# ============================================
print_info "Configuring application..."

# Generate secure credentials
ADMIN_USER="admin"
ADMIN_PASS=$(python3 -c "import secrets; print(secrets.token_urlsafe(12))")
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")

# Create .env file
cat > .env << EOF
# Database Configuration
DATABASE_URL=sqlite:///./student_platform.db

# Admin Credentials
ADMIN_USERNAME=$ADMIN_USER
ADMIN_PASSWORD=$ADMIN_PASS

# Security
SECRET_KEY=$SECRET_KEY
SESSION_TIMEOUT=3600
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=900

# Code Execution Limits
CODE_EXECUTION_TIMEOUT=5
MAX_CODE_LENGTH=10000
MAX_OUTPUT_LENGTH=5000

# Rate Limiting
RATE_LIMIT_ENABLED=true
MAX_REQUESTS_PER_MINUTE=60
MAX_CODE_RUNS_PER_MINUTE=10

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
LOG_MAX_BYTES=10485760
LOG_BACKUP_COUNT=5

# Excel Storage
EXCEL_FILE_PATH=data/student_results.xlsx
AUTO_SYNC_EXCEL=true

# Server Configuration
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0

# Production Flags
PRODUCTION=true
DEBUG=false

# Monitoring
ENABLE_METRICS=true
METRICS_PORT=9090
EOF

print_success "Application configured"

# ============================================
# STEP 4: Initialize Database
# ============================================
print_info "Initializing database..."

mkdir -p data logs backups
chmod 755 data logs backups

python3 << 'PYEOF' > /dev/null 2>&1
from database import init_db
init_db()
PYEOF

print_success "Database initialized"

# ============================================
# STEP 5: Setup Auto-Start Service
# ============================================
print_info "Setting up auto-start service..."

CURRENT_USER=$(whoami)
CURRENT_PATH=$(pwd)

sudo tee /etc/systemd/system/student-platform.service > /dev/null << EOF
[Unit]
Description=Student Code Debugging Platform
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_PATH
Environment="PATH=$CURRENT_PATH/venv/bin"
ExecStart=$CURRENT_PATH/venv/bin/streamlit run $CURRENT_PATH/app.py --server.port=8501 --server.address=0.0.0.0 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=append:$CURRENT_PATH/logs/service.log
StandardError=append:$CURRENT_PATH/logs/service.log

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl enable student-platform.service > /dev/null 2>&1

print_success "Auto-start service configured"

# ============================================
# STEP 6: Configure Firewall
# ============================================
print_info "Configuring firewall..."

if command -v ufw > /dev/null 2>&1; then
    sudo ufw allow 8501/tcp > /dev/null 2>&1 || true
elif command -v firewall-cmd > /dev/null 2>&1; then
    sudo firewall-cmd --permanent --add-port=8501/tcp > /dev/null 2>&1 || true
    sudo firewall-cmd --reload > /dev/null 2>&1 || true
fi

print_success "Firewall configured"

# ============================================
# STEP 7: Start Application
# ============================================
print_info "Starting application..."

sudo systemctl start student-platform.service
sleep 3

if sudo systemctl is-active --quiet student-platform.service; then
    print_success "Application started successfully"
else
    print_error "Failed to start application"
fi

# ============================================
# Get Access URL
# ============================================
if [ "$OS" = "amzn" ]; then
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")
else
    PUBLIC_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
fi

DASHBOARD_URL="http://$PUBLIC_IP:8501"

# ============================================
# Installation Complete
# ============================================
clear
echo ""
echo "============================================"
echo "  ✓ Installation Complete!"
echo "============================================"
echo ""
echo -e "${GREEN}Dashboard URL:${NC}"
echo -e "  ${BLUE}$DASHBOARD_URL${NC}"
echo ""
echo -e "${GREEN}Admin Credentials:${NC}"
echo "  Username: $ADMIN_USER"
echo "  Password: $ADMIN_PASS"
echo ""
echo -e "${YELLOW}⚠ IMPORTANT: Save these credentials!${NC}"
echo ""
echo "============================================"
echo ""
echo -e "${GREEN}Service Management:${NC}"
echo "  Status:  sudo systemctl status student-platform"
echo "  Stop:    sudo systemctl stop student-platform"
echo "  Restart: sudo systemctl restart student-platform"
echo "  Logs:    sudo journalctl -u student-platform -f"
echo ""
echo -e "${GREEN}Application Logs:${NC}"
echo "  tail -f logs/app.log"
echo "  tail -f logs/audit.log"
echo ""

if [ "$OS" = "amzn" ]; then
    echo -e "${YELLOW}AWS Users:${NC}"
    echo "  Ensure Security Group allows port 8501"
    echo ""
fi

echo "============================================"
echo ""
echo -e "${GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3

# Try to open browser (if available)
if command -v xdg-open > /dev/null 2>&1; then
    xdg-open "$DASHBOARD_URL" > /dev/null 2>&1 &
elif command -v open > /dev/null 2>&1; then
    open "$DASHBOARD_URL" > /dev/null 2>&1 &
fi

echo ""
echo -e "${BLUE}Access your dashboard at: $DASHBOARD_URL${NC}"
echo ""
