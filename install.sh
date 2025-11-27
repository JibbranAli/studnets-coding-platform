#!/bin/bash

# ============================================
# Student Code Debugging Platform - One-Click Install
# ============================================

set -e

echo "============================================"
echo "Student Code Debugging Platform"
echo "One-Click Installation"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}➜ $1${NC}"; }
print_header() { echo -e "${BLUE}▶ $1${NC}"; }

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print_error "Cannot detect OS"
    exit 1
fi

print_info "Detected OS: $OS"
echo ""

# ============================================
# STEP 1: System Update & Dependencies
# ============================================
print_header "Step 1: Installing system dependencies..."

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt update -qq
    sudo apt install -y python3 python3-pip python3-venv gcc python3-dev > /dev/null 2>&1
elif [ "$OS" = "amzn" ]; then
    sudo yum install -y python3 python3-pip gcc python3-devel -q > /dev/null 2>&1
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    sudo yum install -y python3 python3-pip gcc python3-devel -q > /dev/null 2>&1
else
    print_error "Unsupported OS: $OS"
    exit 1
fi

print_success "System dependencies installed"
echo ""

# ============================================
# STEP 2: Python Virtual Environment
# ============================================
print_header "Step 2: Setting up Python environment..."

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q

print_success "Python environment ready"
echo ""

# ============================================
# STEP 3: Environment Configuration
# ============================================
print_header "Step 3: Configuring application..."

if [ ! -f .env ]; then
    cp .env.example .env
    
    # Generate secure secret key
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    
    # Update .env
    if [ "$OS" = "darwin" ]; then
        sed -i '' "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
        sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|" .env
    else
        sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|" .env
    fi
fi

print_success "Configuration created"
echo ""

# ============================================
# STEP 4: Admin Credentials
# ============================================
print_header "Step 4: Setting up admin account..."

echo ""
read -p "Admin username [admin]: " admin_user
admin_user=${admin_user:-admin}

while true; do
    read -sp "Admin password (min 8 chars): " admin_pass
    echo ""
    if [ ${#admin_pass} -ge 8 ]; then
        break
    else
        print_error "Password must be at least 8 characters"
    fi
done

if [ "$OS" = "darwin" ]; then
    sed -i '' "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
    sed -i '' "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
else
    sed -i "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
    sed -i "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
fi

print_success "Admin account configured"
echo ""

# ============================================
# STEP 5: Database Initialization
# ============================================
print_header "Step 5: Initializing database..."

mkdir -p data logs backups
chmod 755 data logs backups

python3 -c "from database import init_db; init_db()" 2>/dev/null

if [ $? -eq 0 ]; then
    print_success "Database initialized"
else
    print_error "Database initialization failed"
    exit 1
fi
echo ""

# ============================================
# STEP 6: Systemd Service (Linux only)
# ============================================
if [ "$OS" != "darwin" ]; then
    print_header "Step 6: Setting up auto-start service..."
    
    CURRENT_USER=$(whoami)
    CURRENT_PATH=$(pwd)
    
    sudo tee /etc/systemd/system/student-platform.service > /dev/null <<EOF
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

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable student-platform.service > /dev/null 2>&1
    
    print_success "Auto-start service configured"
    echo ""
fi

# ============================================
# STEP 7: Firewall Configuration
# ============================================
if [ "$OS" != "darwin" ]; then
    print_header "Step 7: Configuring firewall..."
    
    if command -v ufw &> /dev/null; then
        sudo ufw allow 8501/tcp > /dev/null 2>&1 || true
        print_success "Firewall configured (ufw)"
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-port=8501/tcp > /dev/null 2>&1 || true
        sudo firewall-cmd --reload > /dev/null 2>&1 || true
        print_success "Firewall configured (firewalld)"
    else
        print_info "No firewall detected - configure manually if needed"
    fi
    echo ""
fi

# ============================================
# Installation Complete
# ============================================
echo ""
echo "============================================"
echo "✓ Installation Complete!"
echo "============================================"
echo ""

# Get IP address
if [ "$OS" = "amzn" ]; then
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")
else
    PUBLIC_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
fi

echo -e "${GREEN}Admin Credentials:${NC}"
echo "  Username: $admin_user"
echo "  Password: [as entered]"
echo ""

echo -e "${GREEN}Start Application:${NC}"
if [ "$OS" != "darwin" ]; then
    echo "  sudo systemctl start student-platform"
    echo ""
    echo -e "${GREEN}Or manually:${NC}"
fi
echo "  source venv/bin/activate"
echo "  streamlit run app.py"
echo ""

echo -e "${GREEN}Access Application:${NC}"
echo "  http://$PUBLIC_IP:8501"
echo ""

if [ "$OS" = "amzn" ]; then
    echo -e "${YELLOW}⚠ AWS Users:${NC}"
    echo "  Configure Security Group to allow port 8501"
    echo ""
fi

echo -e "${GREEN}Manage Service:${NC}"
if [ "$OS" != "darwin" ]; then
    echo "  Start:   sudo systemctl start student-platform"
    echo "  Stop:    sudo systemctl stop student-platform"
    echo "  Status:  sudo systemctl status student-platform"
    echo "  Logs:    sudo journalctl -u student-platform -f"
    echo ""
fi

echo -e "${GREEN}Application Logs:${NC}"
echo "  tail -f logs/app.log"
echo ""

# Ask to start now
if [ "$OS" != "darwin" ]; then
    read -p "Start the application now? (y/n): " start_now
    if [ "$start_now" = "y" ]; then
        sudo systemctl start student-platform
        sleep 2
        if sudo systemctl is-active --quiet student-platform; then
            print_success "Application started successfully!"
            echo ""
            echo "Access at: http://$PUBLIC_IP:8501"
        else
            print_error "Failed to start. Check logs: sudo journalctl -u student-platform -xe"
        fi
    fi
else
    echo "Run: streamlit run app.py"
fi

echo ""
echo "============================================"
