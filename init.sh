#!/bin/bash

echo "================================================"
echo "   Project Nexus - GitHub Upload Script"
echo "================================================"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed!"
    echo "Please install Git first."
    exit 1
fi

# Get GitHub username
read -p "Enter your GitHub username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "ERROR: Username cannot be empty!"
    exit 1
fi

echo
echo "Updating repository URLs..."

# Update main.lua
sed -i.bak "s/YOUR_USERNAME\/ProjectNexus/$USERNAME\/ProjectNexus/g" main.lua
rm -f main.lua.bak

# Update loader.lua
sed -i.bak "s/YOUR_USERNAME\/ProjectNexus/$USERNAME\/ProjectNexus/g" loader.lua
rm -f loader.lua.bak

echo "Done!"
echo

echo "================================================"
echo "   Git Repository Initialization"
echo "================================================"
echo

# Initialize git repository
git init
git add .
git commit -m "Initial commit - Project Nexus v1.0"
git branch -M main

echo
echo "================================================"
echo "   Next Steps:"
echo "================================================"
echo
echo "1. Create a new repository on GitHub named 'ProjectNexus'"
echo "2. Run these commands:"
echo
echo "   git remote add origin https://github.com/$USERNAME/ProjectNexus.git"
echo "   git push -u origin main"
echo
echo "3. Your loadstring will be:"
echo
echo "   loadstring(game:HttpGet(\"https://raw.githubusercontent.com/$USERNAME/ProjectNexus/main/loader.lua\"))()"
echo
echo "================================================"
