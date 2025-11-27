#!/bin/bash

# Student Code Debugging Platform - Setup Script
# This script automates the installation and configuration process

set -e  # Exit on error

echo "=========================================="
echo "Student Code Debugging Platform Setup"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this script as root"
    exit 1
fi

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

# Step 1: Update system packages
print_info "Step 1: Updating system packages..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt update && sudo apt upgrade -y
    print_success "System packages updated"
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ] || [ "$OS" = "amzn" ]; then
    sudo yum update -y
    print_success "System packages updated"
else
    print_error "Unsupported OS: $OS"
    exit 1
fi
echo ""

# Step 2: Install Python 3.11+
print_info "Step 2: Installing Python 3.11..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt install -y python3.11 python3.11-venv python3-pip
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    sudo yum install -y python3.11 python3.11-pip
elif [ "$OS" = "amzn" ]; then
    # Amazon Linux 2023 or AL2
    sudo yum install -y python3.11 python3.11-pip python3.11-devel
fi

# Verify Python installation
if command -v python3.11 &> /dev/null; then
    PYTHON_VERSION=$(python3.11 --version)
    print_success "Python installed: $PYTHON_VERSION"
else
    print_error "Python 3.11 installation failed"
    exit 1
fi
echo ""

# Step 3: Install PostgreSQL
print_info "Step 3: Installing PostgreSQL..."
read -p "Do you want to install PostgreSQL? (y/n): " install_postgres
if [ "$install_postgres" = "y" ]; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt install -y postgresql postgresql-contrib
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        sudo yum install -y postgresql-server postgresql-contrib
        sudo postgresql-setup initdb
    elif [ "$OS" = "amzn" ]; then
        # Amazon Linux
        sudo yum install -y postgresql15-server postgresql15-contrib
        sudo postgresql-setup --initdb
    fi
    
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    print_success "PostgreSQL installed and started"
else
    print_info "Skipping PostgreSQL installation (will use SQLite)"
fi
echo ""

# Step 4: Create virtual environment
print_info "Step 4: Creating Python virtual environment..."
python3.11 -m venv venv
print_success "Virtual environment created"
echo ""

# Step 5: Activate virtual environment and install dependencies
print_info "Step 5: Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
print_success "Dependencies installed"
echo ""

# Step 6: Setup environment file
print_info "Step 6: Setting up environment configuration..."
if [ ! -f .env ]; then
    cp .env.example .env
    print_success "Created .env file from template"
    print_info "Please edit .env file with your configuration"
    
    # Generate random secret key
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    
    # Update .env with generated secret key
    if [ "$OS" = "darwin" ]; then
        sed -i '' "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
    else
        sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
    fi
    
    print_success "Generated secure SECRET_KEY"
else
    print_info ".env file already exists, skipping"
fi
echo ""

# Step 7: Setup database
print_info "Step 7: Setting up database..."
if [ "$install_postgres" = "y" ]; then
    read -p "Enter PostgreSQL database name [student_debug_platform]: " db_name
    db_name=${db_name:-student_debug_platform}
    
    read -p "Enter PostgreSQL username [student_user]: " db_user
    db_user=${db_user:-student_user}
    
    read -sp "Enter PostgreSQL password: " db_password
    echo ""
    
    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE $db_name;" 2>/dev/null || print_info "Database may already exist"
    sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_password';" 2>/dev/null || print_info "User may already exist"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
    
    # Update .env with database URL
    DB_URL="postgresql://$db_user:$db_password@localhost:5432/$db_name"
    if [ "$OS" = "darwin" ]; then
        sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" .env
    else
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" .env
    fi
    
    print_success "PostgreSQL database configured"
else
    # Use SQLite
    if [ "$OS" = "darwin" ]; then
        sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|" .env
    else
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|" .env
    fi
    print_success "SQLite database configured"
fi
echo ""

# Step 8: Initialize database
print_info "Step 8: Initializing database tables..."
python3 -c "from database import init_db; init_db()"
print_success "Database initialized"
echo ""

# Step 9: Create data directory
print_info "Step 9: Creating data directory..."
mkdir -p data
chmod 755 data
print_success "Data directory created"
echo ""

# Step 10: Setup admin credentials
print_info "Step 10: Setting up admin credentials..."
read -p "Enter admin username [admin]: " admin_user
admin_user=${admin_user:-admin}

read -sp "Enter admin password: " admin_pass
echo ""

if [ "$OS" = "darwin" ]; then
    sed -i '' "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
    sed -i '' "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
else
    sed -i "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
    sed -i "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
fi

print_success "Admin credentials configured"
echo ""

# Step 11: Install Nginx (optional)
print_info "Step 11: Nginx installation..."
read -p "Do you want to install Nginx as reverse proxy? (y/n): " install_nginx
if [ "$install_nginx" = "y" ]; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt install -y nginx
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ] || [ "$OS" = "amzn" ]; then
        sudo yum install -y nginx
    fi
    
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Copy nginx configuration
    sudo cp nginx.conf /etc/nginx/sites-available/student-platform 2>/dev/null || \
    sudo cp nginx.conf /etc/nginx/conf.d/student-platform.conf
    
    if [ -d /etc/nginx/sites-enabled ]; then
        sudo ln -sf /etc/nginx/sites-available/student-platform /etc/nginx/sites-enabled/
    fi
    
    sudo nginx -t && sudo systemctl reload nginx
    print_success "Nginx installed and configured"
else
    print_info "Skipping Nginx installation"
fi
echo ""

# Step 12: Setup systemd service
print_info "Step 12: Setting up systemd service..."
read -p "Do you want to setup systemd service for auto-start? (y/n): " setup_service
if [ "$setup_service" = "y" ]; then
    # Update service file with current user and path
    CURRENT_USER=$(whoami)
    CURRENT_PATH=$(pwd)
    
    sudo cp streamlit_service.service /etc/systemd/system/student-platform.service
    sudo sed -i "s|User=ubuntu|User=$CURRENT_USER|" /etc/systemd/system/student-platform.service
    sudo sed -i "s|WorkingDirectory=.*|WorkingDirectory=$CURRENT_PATH|" /etc/systemd/system/student-platform.service
    sudo sed -i "s|ExecStart=.*|ExecStart=$CURRENT_PATH/venv/bin/streamlit run $CURRENT_PATH/app.py|" /etc/systemd/system/student-platform.service
    
    sudo systemctl daemon-reload
    sudo systemctl enable student-platform.service
    print_success "Systemd service configured"
    
    read -p "Do you want to start the service now? (y/n): " start_now
    if [ "$start_now" = "y" ]; then
        sudo systemctl start student-platform.service
        print_success "Service started"
    fi
else
    print_info "Skipping systemd service setup"
fi
echo ""

# Step 13: Configure firewall
print_info "Step 13: Configuring firewall..."
read -p "Do you want to configure firewall rules? (y/n): " config_firewall
if [ "$config_firewall" = "y" ]; then
    if command -v ufw &> /dev/null; then
        sudo ufw allow 8501/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        print_success "UFW firewall rules added"
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-port=8501/tcp
        sudo firewall-cmd --permanent --add-port=80/tcp
        sudo firewall-cmd --permanent --add-port=443/tcp
        sudo firewall-cmd --reload
        print_success "Firewalld rules added"
    else
        print_info "No firewall detected, skipping"
    fi
else
    print_info "Skipping firewall configuration"
fi
echo ""

# Final summary
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "Installation completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review and update .env file with your settings"
echo "2. Start the application:"
echo "   - Manual: source venv/bin/activate && streamlit run app.py"
echo "   - Service: sudo systemctl start student-platform.service"
echo "3. Access the application at http://localhost:8501"
echo ""
echo "For production deployment, refer to DEPLOYMENT.md"
echo ""
print_info "Admin credentials:"
echo "   Username: $admin_user"
echo "   Password: [as configured]"
echo ""
