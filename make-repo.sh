#!/bin/bash

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub CLI first:"
    gh auth login
fi

# Create README if it doesn't exist
if [ ! -f README.md ]; then
    echo "# ITSMF EMERGE Networking Bingo

A fun networking bingo game with photo capture capabilities for ITSMF EMERGE events.

## Features
- Interactive bingo board
- Photo capture support
- Mobile-friendly design
- Automatic win detection
- Randomized board generation

## How to Play
1. Visit the game website
2. Click cells to mark them
3. Use the camera button to take photos
4. Get 5 in a row to win!
" > README.md
fi

# Create .gitignore
echo "node_modules/
.DS_Store
.env" > .gitignore

# Rename HTML file to index.html if it exists as itsmf-emerge-bingo.html
if [ -f itsmf-emerge-bingo.html ] && [ ! -f index.html ]; then
    mv itsmf-emerge-bingo.html index.html
fi

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    git init
fi

# Create the repository on GitHub
echo "Creating GitHub repository..."
gh repo create itsmf-emerge-bingo --public --source=. --remote=origin --push

# Enable GitHub Pages
echo "Enabling GitHub Pages..."
gh repo edit --enable-pages --branch main --path /

# Get the pages URL
echo "Getting deployment URL..."
PAGES_URL=$(gh api repos/{owner}/{repo}/pages --jq .html_url)

echo "✨ Setup complete! ✨"
echo "Your repository has been created and the game will be deployed to GitHub Pages"
echo "Deployment URL (may take a few minutes to be active): $PAGES_URL"

# Open the repository in browser
gh repo view --web