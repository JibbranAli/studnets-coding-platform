# PostgreSQL Authentication Fix

## Problem
PostgreSQL is using "ident" authentication which doesn't work with password-based connections.

## Quick Fix

Run these commands:

```bash
# 1. Fix PostgreSQL authentication
chmod +x fix-postgres-auth.sh
sudo ./fix-postgres-auth.sh

# 2. Initialize database
source venv/bin/activate
python3.11 -c "from database import init_db; init_db()"

# 3. Start the application
streamlit run app.py
```

## Manual Fix (if script doesn't work)

### Step 1: Edit PostgreSQL config
```bash
sudo nano /var/lib/pgsql/data/pg_hba.conf
```

### Step 2: Change these lines from "ident" to "md5"
```
# Change FROM:
local   all             all                                     peer
host    all             all             127.0.0.1/32            ident

# Change TO:
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
```

### Step 3: Restart PostgreSQL
```bash
sudo systemctl restart postgresql
```

### Step 4: Initialize database
```bash
source venv/bin/activate
python3.11 -c "from database import init_db; init_db()"
```

## Alternative: Use SQLite (Simpler)

If PostgreSQL is causing issues, use SQLite instead:

```bash
# 1. Edit .env file
nano .env

# 2. Change DATABASE_URL to:
DATABASE_URL=sqlite:///./student_platform.db

# 3. Initialize database
source venv/bin/activate
python3.11 -c "from database import init_db; init_db()"

# 4. Start application
streamlit run app.py
```

## Verify Setup

```bash
# Check if database is initialized
ls -la student_platform.db  # For SQLite

# Or for PostgreSQL
psql -U admin -d vgu -h localhost -c "\dt"
```

## Start Application

```bash
# Activate virtual environment
source venv/bin/activate

# Start Streamlit
streamlit run app.py

# Or use systemd service
sudo systemctl start student-platform
sudo systemctl status student-platform
```

## Access Application

Open browser: http://YOUR_EC2_IP:8501

**Don't forget to open port 8501 in AWS Security Group!**
