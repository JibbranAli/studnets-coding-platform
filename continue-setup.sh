#!/bin/bash

# Continue Setup After PostgreSQL Error
echo "=========================================="
echo "Continuing Setup"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Fix PostgreSQL authentication first
print_info "Fixing PostgreSQL authentication..."
sudo bash -c 'cat > /var/lib/pgsql/data/pg_hba.conf << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF'

sudo systemctl restart postgresql
sleep 2
print_success "PostgreSQL authentication fixed"
echo ""

# Database configuration
print_info "Database Configuration"
read -p "Database name [student_debug_platform]: " db_name
db_name=${db_name:-student_debug_platform}

read -p "Database user [student_user]: " db_user
db_user=${db_user:-student_user}

read -sp "Database password: " db_pass
echo ""

# Create database and user
print_info "Creating database..."
sudo -u postgres psql -c "CREATE DATABASE $db_name;" 2>/dev/null || print_info "Database may already exist"
sudo -u postgres psql -c "CREATE USER $db_user WITH PASSWORD '$db_pass';" 2>/dev/null || print_info "User may already exist"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
sudo -u postgres psql -c "ALTER DATABASE $db_name OWNER TO $db_user;"

# Update .env
if [ -f .env ]; then
    DB_URL="postgresql://$db_user:$db_pass@localhost:5432/$db_name"
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" .env
    print_success "Database configured in .env"
else
    print_info ".env not found, creating..."
    cp .env.example .env
    DB_URL="postgresql://$db_user:$db_pass@localhost:5432/$db_name"
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" .env
    
    # Generate secure keys
    SECRET_KEY=$(python3.11 -c "import secrets; print(secrets.token_urlsafe(32))")
    sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
fi
echo ""

# Initialize database
print_info "Initializing database..."
source venv/bin/activate
python3.11 -c "from database import init_db; init_db()"

if [ $? -eq 0 ]; then
    print_success "Database initialized successfully!"
else
    echo ""
    print_info "If database initialization failed, try SQLite instead:"
    echo "  sed -i 's|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|' .env"
    echo "  python3.11 -c 'from database import init_db; init_db()'"
    exit 1
fi
echo ""

# Create directories
print_info "Creating directories..."
mkdir -p data logs backups
chmod 755 data logs backups
print_success "Directories created"
echo ""

# Admin credentials
print_info "Admin Configuration"
read -p "Admin username [admin]: " admin_user
admin_user=${admin_user:-admin}

read -sp "Admin password: " admin_pass
echo ""

sed -i "s/ADMIN_USERNAME=.*/ADMIN_USERNAME=$admin_user/" .env
sed -i "s/ADMIN_PASSWORD=.*/ADMIN_PASSWORD=$admin_pass/" .env
print_success "Admin configured"
echo ""

# Systemd service
print_info "Setting up systemd service..."
CURRENT_USER=$(whoami)
CURRENT_PATH=$(pwd)

sudo tee /etc/systemd/system/student-platform.service > /dev/null <<EOF
[Unit]
Description=Student Code Debugging Platform
After=network.target postgresql.service

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
echo ""

# Summary
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "Installation completed successfully!"
echo ""
echo "Start the application:"
echo "  sudo systemctl start student-platform"
echo ""
echo "Or manually:"
echo "  source venv/bin/activate"
echo "  streamlit run app.py"
echo ""
echo "Access at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8501"
echo ""
echo "Admin: $admin_user / [your password]"
echo ""
print_info "Configure AWS Security Group to allow port 8501!"
