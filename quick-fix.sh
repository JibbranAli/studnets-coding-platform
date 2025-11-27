#!/bin/bash

# Quick Fix Script for Setup Issues
echo "=========================================="
echo "Quick Fix - Student Platform"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

echo "Choose fix option:"
echo "1. Fix PostgreSQL authentication"
echo "2. Switch to SQLite (simpler)"
echo "3. Complete fresh setup"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        print_info "Fixing PostgreSQL authentication..."
        
        # Backup config
        sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.backup 2>/dev/null
        
        # Update authentication method
        sudo bash -c 'cat > /var/lib/pgsql/data/pg_hba.conf << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF'
        
        # Restart PostgreSQL
        sudo systemctl restart postgresql
        sleep 2
        
        print_success "PostgreSQL authentication fixed"
        
        # Initialize database
        print_info "Initializing database..."
        source venv/bin/activate
        python3.11 -c "from database import init_db; init_db()"
        
        if [ $? -eq 0 ]; then
            print_success "Database initialized successfully!"
        else
            print_error "Database initialization failed"
            echo "Try option 2 (SQLite) instead"
            exit 1
        fi
        ;;
        
    2)
        print_info "Switching to SQLite..."
        
        # Update .env to use SQLite
        if [ -f .env ]; then
            sed -i 's|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|' .env
            print_success "Updated .env to use SQLite"
        else
            print_error ".env file not found"
            exit 1
        fi
        
        # Initialize database
        print_info "Initializing SQLite database..."
        source venv/bin/activate
        python3.11 -c "from database import init_db; init_db()"
        
        if [ $? -eq 0 ]; then
            print_success "SQLite database initialized successfully!"
        else
            print_error "Database initialization failed"
            exit 1
        fi
        ;;
        
    3)
        print_info "Starting fresh setup..."
        
        # Clean up
        rm -f student_platform.db
        rm -rf logs/* data/*
        
        # Use SQLite for simplicity
        if [ -f .env ]; then
            sed -i 's|DATABASE_URL=.*|DATABASE_URL=sqlite:///./student_platform.db|' .env
            print_success "Configured to use SQLite"
        fi
        
        # Initialize
        source venv/bin/activate
        python3.11 -c "from database import init_db; init_db()"
        
        if [ $? -eq 0 ]; then
            print_success "Fresh setup completed!"
        else
            print_error "Setup failed"
            exit 1
        fi
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_success "You can now start the application"
echo ""
echo "Start commands:"
echo "  1. Activate venv: source venv/bin/activate"
echo "  2. Run app: streamlit run app.py"
echo ""
echo "Or use systemd service:"
echo "  sudo systemctl start student-platform"
echo ""
echo "Access at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'localhost'):8501"
echo ""
print_info "Don't forget to configure AWS Security Group to allow port 8501!"
