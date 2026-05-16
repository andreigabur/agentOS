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
echo "🔍 Check Node.js..."
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
echo "🔍 Check uv..."
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
echo "🔍 Check Python version..."
echo "------------------------------------------"

# Function to compare versions
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

REQUIRED_PYTHON_VERSION="3.10"

# Check system python3 first
CURRENT_PYTHON_VERSION="0.0"
if command -v python3 &> /dev/null; then
    CURRENT_PYTHON_VERSION=$(python3 -c 'import sys; v=sys.version_info; print(f"{v[0]}.{v[1]}")')
fi

# Also check if uv already has a sufficient Python
UV_PYTHON_OK=false
if command -v uv &> /dev/null; then
    UV_PYTHON_VERSIONS=$(uv python list --only-installed 2>/dev/null | grep -oE 'cpython-([0-9]+\.[0-9]+)' | sed 's/cpython-//' | sort -V)
    for v in $UV_PYTHON_VERSIONS; do
        if version_ge "$v" "$REQUIRED_PYTHON_VERSION"; then
            UV_PYTHON_OK=true
            break
        fi
    done
fi

if version_ge "$CURRENT_PYTHON_VERSION" "$REQUIRED_PYTHON_VERSION"; then
    echo "✅ Python $CURRENT_PYTHON_VERSION is sufficient."
elif $UV_PYTHON_OK; then
    echo "✅ Python 3.12 is already available via uv."
else
    echo "⚠️  Python $CURRENT_PYTHON_VERSION is too old (Need >= 3.10)."
    echo "🔄 Installing Python 3.12 via uv..."
    UV_OUTPUT=$(uv python install 3.12 2>&1)
    if echo "$UV_OUTPUT" | grep -q "already installed"; then
        echo "✅ Python 3.12 is already available via uv."
    else
        echo "✅ Python 3.12 installed via uv."
    fi
fi

echo ""
