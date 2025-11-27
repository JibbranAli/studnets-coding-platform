#!/bin/bash

# Student Code Debugging Platform - Amazon Linux Setup Script
set -e

echo "=========================================="
echo "Student Platform Setup - Amazon Linux"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Step 1: Update system
print_info "Step 1: Updating system packages..."
sudo yum update -y
print_success "System updated"
echo ""

# Step 2: Install Python 3.11
print_info "Step 2: Installing Python 3.11..."
sudo yum install -y python3.11 python3.11-pip python3.11-devel gcc
print_success "Python 3.11 installed"
python3.11 --version
echo ""

# Step 3: PostgreSQL (optional)
print_info "Step 3: PostgreSQL installation..."
read -p "Install PostgreSQL? (y/n, default: n): " install_pg
if [ "$install_pg" = "y" ]; then
    sudo yum install -y postgresql15-server postgresql15-contrib postgresql15-devel
    
    # Initialize only if not already initialized
    if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
        sudo postgresql-setup --initdb
    else
        print_info "PostgreSQL already initialized"
    fi
    
    # Ensure PostgreSQL is running
    sudo systemctl start postgresql 2>/dev/null || true
    sudo systemctl enable postgresql
    
    # Check if running
    if sudo systemctl is-active --quiet postgresql; then
        print_success "PostgreSQL is running"
    else
        print_info "Starting PostgreSQL..."
        sudo systemctl restart postgresql
    fi
else
    print_info "Skipping PostgreSQL (will use SQLite)"
fi
echo ""

# Step 4: Create virtual environment
print_info "Step 4: Creating virtual environment..."
python3.11 -m venv venv
print_success "Virtual environment created"
echo ""

# Step 5: Install dependencies
print_info "Step 5: Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
print_success "Dependencies installed"
echo ""

# Step 6: Setup environment
print_info "Step 6: Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    
    # Generate secure keys
    SECRET_KEY=$(python3.11 -c "import secrets; print(secrets.token_urlsafe(32))")
    sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
    
    print_success "Environment file created"
    print_info "Please edit .env with your settings"
else
    print_info ".env already exists"
fi
echo ""

# Step 7: Database setup
print_info "Step 7: Database configuration..."
if [ "$install_pg" = "y" ]; then
    read -p "Database name [student_debug_platform]: " db_name
    db_name=${db_name:-student_debug_platform}
    
    read -p "Database user [student_user]: " db_user
    db_user=${db_user:-student_user}
    
    read -sp "Database password: " db_pass
    echo ""
    
    # Create database
    sudo -u postgres psql -c "CREATE DATABASE $db_name;" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_pass';" 2>/dev/null || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
    
    # Update .env
    DB_URL="postgresql://$db_user:$db_pass@localhost:5432/$db_name"
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" .env
    
    print_success "PostgreSQL configured"
else
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|" .env
    print_success "SQLite configured"
fi
echo ""

# Step 8: Initialize database
print_info "Step 8: Initializing database..."
python3.11 -c "from database import init_db; init_db()"
print_success "Database initialized"
echo ""

# Step 9: Create directories
print_info "Step 9: Creating directories..."
mkdir -p data logs backups
chmod 755 data logs backups
print_success "Directories created"
echo ""

# Step 10: Admin credentials
print_info "Step 10: Admin credentials..."
read -p "Admin username [admin]: " admin_user
admin_user=${admin_user:-admin}

read -sp "Admin password: " admin_pass
echo ""

sed -i "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
sed -i "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
print_success "Admin configured"
echo ""

# Step 11: Nginx (optional)
print_info "Step 11: Nginx installation..."
read -p "Install Nginx? (y/n, default: n): " install_nginx
if [ "$install_nginx" = "y" ]; then
    sudo amazon-linux-extras install nginx1 -y 2>/dev/null || sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Configure nginx
    sudo cp nginx.conf /etc/nginx/conf.d/student-platform.conf
    sudo nginx -t && sudo systemctl reload nginx
    
    print_success "Nginx installed"
else
    print_info "Skipping Nginx"
fi
echo ""

# Step 12: Systemd service
print_info "Step 12: Systemd service..."
read -p "Setup systemd service? (y/n, default: y): " setup_service
if [ "$setup_service" != "n" ]; then
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
    sudo systemctl enable student-platform.service
    print_success "Systemd service configured"
    
    read -p "Start service now? (y/n): " start_now
    if [ "$start_now" = "y" ]; then
        sudo systemctl start student-platform.service
        sleep 3
        sudo systemctl status student-platform.service --no-pager
        print_success "Service started"
    fi
fi
echo ""

# Step 13: Firewall
print_info "Step 13: Firewall configuration..."
read -p "Configure firewall? (y/n, default: y): " config_fw
if [ "$config_fw" != "n" ]; then
    # Check if firewalld is available
    if command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-port=8501/tcp
        sudo firewall-cmd --permanent --add-port=80/tcp
        sudo firewall-cmd --permanent --add-port=443/tcp
        sudo firewall-cmd --reload
        print_success "Firewall configured"
    else
        print_info "Firewalld not available, configure AWS Security Group instead"
        echo "  Required ports: 8501, 80, 443"
    fi
fi
echo ""

# Summary
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "Installation completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review .env file: nano .env"
echo "2. Configure AWS Security Group to allow ports: 8501, 80, 443"
echo ""
echo "Start application:"
echo "  Manual: source venv/bin/activate && streamlit run app.py"
echo "  Service: sudo systemctl start student-platform"
echo ""
echo "Access: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8501"
echo ""
echo "Admin: $admin_user / [configured password]"
echo ""
echo "Logs:"
echo "  App: tail -f logs/app.log"
echo "  Service: sudo journalctl -u student-platform -f"
echo ""
