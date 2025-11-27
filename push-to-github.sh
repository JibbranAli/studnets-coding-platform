#!/bin/bash

# Automated GitHub Push Script
echo "=========================================="
echo "Push to GitHub"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Check if git is initialized
if [ ! -d .git ]; then
    print_info "Initializing git repository..."
    git init
    print_success "Git initialized"
fi

# Get GitHub username
read -p "Enter your GitHub username: " github_user

# Get repository name
read -p "Enter repository name [student-debug-platform]: " repo_name
repo_name=${repo_name:-student-debug-platform}

# Check if remote exists
if git remote | grep -q origin; then
    print_info "Remote 'origin' already exists"
    git remote -v
    read -p "Remove and re-add? (y/n): " remove_remote
    if [ "$remove_remote" = "y" ]; then
        git remote remove origin
        print_success "Remote removed"
    fi
fi

# Add remote if not exists
if ! git remote | grep -q origin; then
    print_info "Adding remote repository..."
    git remote add origin "https://github.com/$github_user/$repo_name.git"
    print_success "Remote added"
fi

# Show current status
print_info "Current git status:"
git status --short

# Add all files
print_info "Adding files..."
git add .
print_success "Files added"

# Commit
read -p "Enter commit message [Initial commit: Production-ready platform]: " commit_msg
commit_msg=${commit_msg:-"Initial commit: Production-ready student debugging platform"}

git commit -m "$commit_msg"
print_success "Changes committed"

# Set main branch
git branch -M main
print_success "Branch set to main"

# Push to GitHub
print_info "Pushing to GitHub..."
echo ""
echo "You may be prompted for GitHub credentials"
echo "Use Personal Access Token as password"
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    print_success "Successfully pushed to GitHub!"
    echo ""
    echo "Repository URL: https://github.com/$github_user/$repo_name"
    echo ""
    
    # Ask about tags
    read -p "Create release tag v1.0.0? (y/n): " create_tag
    if [ "$create_tag" = "y" ]; then
        git tag -a v1.0.0 -m "Production-ready release v1.0.0"
        git push origin v1.0.0
        print_success "Tag v1.0.0 created and pushed"
        echo ""
        echo "Create release on GitHub:"
        echo "https://github.com/$github_user/$repo_name/releases/new?tag=v1.0.0"
    fi
else
    echo ""
    echo "Push failed. Common solutions:"
    echo "1. Create repository on GitHub first: https://github.com/new"
    echo "2. Use Personal Access Token instead of password"
    echo "3. Check repository name and username"
    echo ""
    echo "Manual commands:"
    echo "  git remote add origin https://github.com/$github_user/$repo_name.git"
    echo "  git push -u origin main"
fi

echo ""
print_info "Next steps:"
echo "1. Visit: https://github.com/$github_user/$repo_name"
echo "2. Add repository description and topics"
echo "3. Create a release (optional)"
echo "4. Share with your team!"
