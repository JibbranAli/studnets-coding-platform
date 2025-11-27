#!/bin/bash

# Student Code Debugging Platform - Deployment Script for AWS EC2
# This script automates the deployment process

set -e

echo "=========================================="
echo "Student Code Debugging Platform Deployment"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Python 3.10+
echo "Installing Python..."
sudo apt install -y python3 python3-pip python3-venv

# Install PostgreSQL (optional, comment out if using SQLite)
echo "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create PostgreSQL database and user
echo "Setting up PostgreSQL database..."
sudo -u postgres psql -c "CREATE DATABASE student_debug_platform;"
sudo -u postgres psql -c "CREATE USER platformuser WITH PASSWORD 'secure_password_here';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE student_debug_platform TO platformuser;"

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Create application directory
APP_DIR="/home/ubuntu/student-platform"
echo "Creating application directory at $APP_DIR..."
mkdir -p $APP_DIR
cd $APP_DIR

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "Installing Python packages..."
pip install --upgrade pip
pip install -r requirements.txt

# Create data directory
echo "Creating data directory..."
mkdir -p /home/ubuntu/student-platform/data

# Setup environment variables
echo "Setting up environment variables..."
cat > .env << EOF
DATABASE_URL=postgresql://platformuser:secure_password_here@localhost:5432/student_debug_platform
ADMIN_USERNAME=admin
ADMIN_PASSWORD=$(openssl rand -base64 32)
SECRET_KEY=$(openssl rand -base64 32)
EXCEL_FILE_PATH=/home/ubuntu/student-platform/data/student_results.xlsx
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0
EOF

echo "Generated secure admin password. Check .env file for credentials."

# Initialize database
echo "Initializing database..."
python database.py

# Setup systemd service
echo "Setting up systemd service..."
sudo cp streamlit_service.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable streamlit_service
sudo systemctl start streamlit_service

# Configure Nginx
echo "Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/student-platform
sudo ln -sf /etc/nginx/sites-available/student-platform /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8501/tcp
sudo ufw --force enable

echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Check .env file for admin credentials"
echo "2. Access the application at http://YOUR_EC2_IP"
echo "3. Setup SSL certificate using certbot (see DEPLOYMENT.md)"
echo "4. Update AWS Security Group to allow ports 80, 443, 8501"
echo ""
echo "Service status:"
sudo systemctl status streamlit_service --no-pager
