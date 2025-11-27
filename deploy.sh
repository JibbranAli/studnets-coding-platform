#!/bin/bash

# Production Deployment Script
set -e

echo "=========================================="
echo "Production Deployment"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if .env exists
if [ ! -f .env ]; then
    print_error ".env file not found"
    echo "Please create .env file from .env.example"
    exit 1
fi

# Load environment
source .env

# Validate production settings
print_info "Validating production configuration..."
python3 -c "from config import config; config.validate()" || {
    print_error "Configuration validation failed"
    exit 1
}
print_success "Configuration validated"
echo ""

# Backup database
print_info "Creating database backup..."
if [ -f "student_platform.db" ]; then
    BACKUP_FILE="backups/student_platform_$(date +%Y%m%d_%H%M%S).db"
    mkdir -p backups
    cp student_platform.db "$BACKUP_FILE"
    print_success "Database backed up to $BACKUP_FILE"
elif [ ! -z "$DATABASE_URL" ] && [[ $DATABASE_URL == postgresql* ]]; then
    BACKUP_FILE="backups/database_$(date +%Y%m%d_%H%M%S).sql"
    mkdir -p backups
    pg_dump "$DATABASE_URL" > "$BACKUP_FILE" 2>/dev/null || print_info "Database backup skipped"
    print_success "Database backed up to $BACKUP_FILE"
fi
echo ""

# Run database migrations
print_info "Running database migrations..."
python3 -c "from database import init_db; init_db()"
print_success "Database migrations completed"
echo ""

# Create required directories
print_info "Creating required directories..."
mkdir -p logs data backups
chmod 755 logs data backups
print_success "Directories created"
echo ""

# Run health check
print_info "Running health check..."
python3 healthcheck.py || {
    print_error "Health check failed"
    exit 1
}
print_success "Health check passed"
echo ""

# Deployment method selection
echo "Select deployment method:"
echo "1. Docker Compose (recommended)"
echo "2. Systemd Service"
echo "3. Manual"
read -p "Enter choice (1-3): " deploy_choice

case $deploy_choice in
    1)
        print_info "Deploying with Docker Compose..."
        
        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            print_error "Docker is not installed"
            exit 1
        fi
        
        # Build and start containers
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        
        print_success "Application deployed with Docker Compose"
        echo ""
        echo "Access the application at: http://localhost:8501"
        echo "View logs: docker-compose logs -f app"
        echo "Stop: docker-compose down"
        ;;
        
    2)
        print_info "Deploying with Systemd..."
        
        # Create systemd service
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
ExecStart=$CURRENT_PATH/venv/bin/streamlit run $CURRENT_PATH/app.py --server.port=8501 --server.address=0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable student-platform.service
        sudo systemctl restart student-platform.service
        
        print_success "Application deployed with Systemd"
        echo ""
        echo "Service status: sudo systemctl status student-platform"
        echo "View logs: sudo journalctl -u student-platform -f"
        echo "Stop: sudo systemctl stop student-platform"
        ;;
        
    3)
        print_info "Manual deployment selected"
        echo ""
        echo "To start the application manually:"
        echo "  source venv/bin/activate"
        echo "  streamlit run app.py"
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Deployment completed successfully!"
echo ""
echo "Important: Monitor logs for any issues"
echo "Health check: python3 healthcheck.py"
