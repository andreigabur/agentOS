#!/bin/bash

# AgentOS Prerequisites Setup Script
# Phase 1: Node.js (via NVM), uv, and Python 3.12

set -e

echo "🚀 Starting AgentOS Prerequisite Setup..."
echo ""

# Function to check for Homebrew
check_brew() {
    if command -v brew &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# --- 1. Node.js / NVM Check ---
echo "------------------------------------------"
echo "🔍 Checking for Node.js..."
echo "------------------------------------------"

if command -v node &> /dev/null; then
    echo "✅ Node.js is already installed ($(node -v))."
else
    echo "❌ Node.js is not installed."
    if check_brew; then
        echo "🍺 Homebrew detected. Installing NVM via Homebrew..."
        brew install nvm
        
        # Set up NVM directory and source it
        export NVM_DIR="$HOME/.nvm"
        mkdir -p "$NVM_DIR"
        
        BREW_PREFIX=$(brew --prefix)
        if [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
            . "$BREW_PREFIX/opt/nvm/nvm.sh"
        fi
        
        echo "🟢 Installing latest LTS Node.js via NVM..."
        nvm install --lts
        nvm use --lts
        echo "✅ Node.js installed via NVM."
    else
        echo "⚠️  Homebrew not found. Please install Node.js manually from: https://nodejs.org/"
        echo "   Or install Homebrew first: https://brew.sh/"
    fi
fi

echo ""

# --- 2. uv Check ---
echo "------------------------------------------"
echo "🔍 Checking for uv..."
echo "------------------------------------------"

if command -v uv &> /dev/null; then
    echo "✅ uv is already installed ($(uv --version))."
else
    echo "❌ uv is not installed."
    if check_brew; then
        echo "🍺 Homebrew detected. Installing uv via Homebrew..."
        brew install uv
        uv tool update-shell
        echo "✅ uv installed via Homebrew."
    else
        echo "⚠️  Homebrew not found. To install uv, run the following command:"
        echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi
    
    # Ensure ~/.local/bin is in the PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
fi

echo ""

# --- 3. Python Version Check ---
echo "------------------------------------------"
echo "🔍 Checking Python Version..."
echo "------------------------------------------"

# Function to compare versions
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Try to get the version, handle cases where python3 might not exist yet
if command -v python3 &> /dev/null; then
    # Extracts Major and Minor, e.g., "3.9"
    CURRENT_PYTHON_VERSION=$(python3 -c 'import sys; v=sys.version_info; print(f"{v[0]}.{v[1]}")')
else
    CURRENT_PYTHON_VERSION="0.0"
fi

REQUIRED_PYTHON_VERSION="3.10"

if version_ge "$CURRENT_PYTHON_VERSION" "$REQUIRED_PYTHON_VERSION"; then
    echo "✅ Python $CURRENT_PYTHON_VERSION is sufficient."
else
    echo "⚠️  Python $CURRENT_PYTHON_VERSION is too old (Need >= 3.10)."
    echo "🔄 Installing Python 3.12 via uv..."
    uv python install 3.12
    echo "✅ Python 3.12 installed via uv."
fi

echo ""
