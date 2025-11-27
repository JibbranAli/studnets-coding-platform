# GitHub Setup Guide

Step-by-step guide to push this project to GitHub.

## Prerequisites

- Git installed on your system
- GitHub account created
- SSH key or personal access token configured

## Step 1: Initialize Git Repository

```bash
# Navigate to project directory
cd student-debug-platform

# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Production-ready student debugging platform"
```

## Step 2: Create GitHub Repository

### Option A: Via GitHub Website

1. Go to https://github.com
2. Click the **"+"** icon (top right)
3. Select **"New repository"**
4. Fill in details:
   - **Repository name:** `student-debug-platform`
   - **Description:** `Production-ready platform for students to practice Python debugging with secure code execution`
   - **Visibility:** Public or Private
   - **DO NOT** initialize with README (we already have one)
5. Click **"Create repository"**

### Option B: Via GitHub CLI

```bash
# Install GitHub CLI if needed
# https://cli.github.com/

# Create repository
gh repo create student-debug-platform --public --source=. --remote=origin

# Or for private repo
gh repo create student-debug-platform --private --source=. --remote=origin
```

## Step 3: Connect Local to GitHub

```bash
# Add remote repository (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/student-debug-platform.git

# Or using SSH
git remote add origin git@github.com:YOUR_USERNAME/student-debug-platform.git

# Verify remote
git remote -v
```

## Step 4: Push to GitHub

```bash
# Push to main branch
git branch -M main
git push -u origin main
```

## Step 5: Verify Upload

1. Go to your GitHub repository
2. Verify all files are uploaded
3. Check README.md is displayed

## Step 6: Configure Repository Settings

### Add Repository Description

1. Go to repository page
2. Click **"About"** (gear icon)
3. Add description: `Production-ready platform for students to practice Python debugging`
4. Add topics: `python`, `education`, `streamlit`, `debugging`, `code-execution`
5. Save changes

### Add Repository Topics

```
python
education
streamlit
debugging
code-execution
postgresql
docker
aws
security
monitoring
```

### Enable GitHub Pages (Optional)

1. Go to **Settings** → **Pages**
2. Source: Deploy from branch
3. Branch: `main` → `/docs` or `/root`
4. Save

## Step 7: Create Releases

```bash
# Tag the release
git tag -a v1.0.0 -m "Production-ready release v1.0.0"

# Push tags
git push origin v1.0.0

# Or push all tags
git push --tags
```

### Create Release on GitHub

1. Go to **Releases** → **Create a new release**
2. Choose tag: `v1.0.0`
3. Release title: `v1.0.0 - Production Ready`
4. Description:
```markdown
## Features
- 🔐 Secure authentication with bcrypt
- 🛡️ Sandboxed code execution
- 📊 Admin dashboard
- 📈 Production monitoring
- 🚀 Docker support
- ⚡ Rate limiting
- 📋 Audit logging

## Installation
See [QUICK_START.md](QUICK_START.md)

## Documentation
- [User Guide](USER_GUIDE.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Production Checklist](PRODUCTION_CHECKLIST.md)
```
5. Click **"Publish release"**

## Step 8: Add README Badges (Optional)

Add to top of README.md:

```markdown
![Python](https://img.shields.io/badge/python-3.11+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-production--ready-brightgreen.svg)
![Docker](https://img.shields.io/badge/docker-supported-blue.svg)
```

## Step 9: Create GitHub Actions (Optional)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Run health check
        run: |
          python healthcheck.py
```

## Step 10: Add License

Create `LICENSE` file:

```bash
# For MIT License
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Commit and push
git add LICENSE
git commit -m "Add MIT License"
git push
```

## Complete Command Sequence

Here's the complete sequence to push to GitHub:

```bash
# 1. Initialize and commit
git init
git add .
git commit -m "Initial commit: Production-ready student debugging platform"

# 2. Create repository on GitHub (via website or CLI)
# Then add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/student-debug-platform.git

# 3. Push to GitHub
git branch -M main
git push -u origin main

# 4. Create and push tags
git tag -a v1.0.0 -m "Production-ready release v1.0.0"
git push origin v1.0.0

# Done!
```

## Updating Repository

After making changes:

```bash
# Check status
git status

# Add changes
git add .

# Commit with message
git commit -m "Description of changes"

# Push to GitHub
git push

# For new features, create a branch
git checkout -b feature/new-feature
git add .
git commit -m "Add new feature"
git push -u origin feature/new-feature
```

## Cloning Repository

Others can clone your repository:

```bash
# Clone via HTTPS
git clone https://github.com/YOUR_USERNAME/student-debug-platform.git

# Clone via SSH
git clone git@github.com:YOUR_USERNAME/student-debug-platform.git

# Navigate and setup
cd student-debug-platform
./setup.sh  # or setup-amazon-linux.sh
```

## Repository Structure

Your GitHub repository will have:

```
student-debug-platform/
├── .github/              # GitHub Actions (optional)
├── logs/                 # Excluded via .gitignore
├── data/                 # Excluded via .gitignore
├── venv/                 # Excluded via .gitignore
├── app.py                # Main application
├── auth.py               # Authentication
├── code_runner.py        # Code execution
├── config.py             # Configuration
├── database.py           # Database models
├── logger.py             # Logging
├── monitoring.py         # Monitoring
├── security.py           # Security features
├── rate_limiter.py       # Rate limiting
├── excel_sync.py         # Excel integration
├── healthcheck.py        # Health checks
├── requirements.txt      # Dependencies
├── Dockerfile            # Docker build
├── docker-compose.yml    # Docker orchestration
├── nginx.conf            # Nginx config
├── setup.sh              # Linux setup
├── setup-amazon-linux.sh # Amazon Linux setup
├── setup.bat             # Windows setup
├── deploy.sh             # Deployment script
├── backup.sh             # Backup script
├── README.md             # Main documentation
├── USER_GUIDE.md         # User guide
├── QUICK_START.md        # Quick start
├── DEPLOYMENT.md         # Deployment guide
├── PRODUCTION_CHECKLIST.md # Production checklist
├── GITHUB_SETUP.md       # This file
├── .env.example          # Environment template
├── .gitignore            # Git exclusions
├── .dockerignore         # Docker exclusions
└── LICENSE               # License file
```

## Troubleshooting

### Authentication Failed

```bash
# Use personal access token
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/student-debug-platform.git

# Or configure SSH
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add to GitHub: Settings → SSH Keys
```

### Large Files Error

```bash
# Remove large files from git
git rm --cached large_file.db
echo "*.db" >> .gitignore
git commit -m "Remove database files"
```

### Push Rejected

```bash
# Pull first
git pull origin main --rebase

# Then push
git push origin main
```

## Best Practices

1. **Never commit sensitive data:**
   - `.env` files
   - Database files
   - API keys
   - Passwords

2. **Use meaningful commit messages:**
   - ✅ "Add rate limiting to code execution"
   - ❌ "Update files"

3. **Create branches for features:**
   ```bash
   git checkout -b feature/new-feature
   ```

4. **Keep repository clean:**
   - Use `.gitignore`
   - Remove unnecessary files
   - Organize code properly

5. **Document everything:**
   - Update README.md
   - Add comments
   - Create guides

## Next Steps

After pushing to GitHub:

1. ✅ Share repository URL with team
2. ✅ Add collaborators (Settings → Collaborators)
3. ✅ Enable branch protection (Settings → Branches)
4. ✅ Setup CI/CD (GitHub Actions)
5. ✅ Monitor issues and pull requests
6. ✅ Keep documentation updated

## Support

- GitHub Docs: https://docs.github.com
- Git Docs: https://git-scm.com/doc
- GitHub CLI: https://cli.github.com

---

**Ready to push?** Follow the steps above and your project will be on GitHub! 🚀
