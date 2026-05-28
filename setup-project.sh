#!/bin/bash

# AgentOS Project Setup & Local Skills Installer
set -e

# Help command
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: ./setup-project.sh <project-path> [skill-url-1] [skill-url-2] ..."
    echo ""
    echo "Arguments:"
    echo "  <project-path>     Path to the project directory to setup"
    echo "  [skill-url-n]      Optional list of custom skills to install locally via 'npx skills add'"
    exit 0
fi

# Ensure project path is provided
PROJECT_PATH="$1"
if [ -z "$PROJECT_PATH" ]; then
    echo "❌ Error: Project path is required."
    echo "Usage: $0 <project-path> [skill-url-1] [skill-url-2] ..."
    exit 1
fi

# Resolve the project path to an absolute path
mkdir -p "$PROJECT_PATH"
ABS_PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

echo "=========================================="
echo "🏗️  Setting up AgentOS Project..."
echo "=========================================="
echo "📁 Project Path: $ABS_PROJECT_PATH"
echo ""

# Navigate into the project directory
cd "$ABS_PROJECT_PATH"

# 1. OpenSpecs Initialization
echo "------------------------------------------"
echo "📋 Initializing OpenSpecs..."
echo "------------------------------------------"
if command -v openspec &> /dev/null; then
    openspec init --tools antigravity,opencode
else
    echo "⚠️  openspec CLI not found. Running via npx..."
    npx -y @fission-ai/openspec@latest init --tools antigravity,opencode
fi
echo "✅ OpenSpecs initialized."
echo ""

# 2. Graphify Project Setup
echo "------------------------------------------"
echo "📊 Configuring Graphify for Project..."
echo "------------------------------------------"
if command -v graphify &> /dev/null; then
    echo "🔗 Running Graphify installs..."
    graphify opencode install --project
    graphify antigravity install --project
    echo "✅ Graphify configured."
else
    echo "⚠️  graphify command not found. Skipping Graphify setup."
fi
echo ""

# 3. Normalization (.agent -> .agents)
echo "------------------------------------------"
echo "🔄 Normalizing Agent Directories..."
echo "------------------------------------------"
if [ -d ".agent" ]; then
    echo "📦 Found .agent directory. Merging into .agents..."
    mkdir -p .agents
    # Recursively copy all contents of .agent into .agents (retaining structure)
    cp -R .agent/. .agents/ 2>/dev/null || true
    rm -rf .agent
    echo "✅ Directory merged successfully."
else
    echo "✅ No legacy .agent folder to merge."
fi
echo ""

# 4. Custom Local Skills Setup
shift # Remove project path from arguments
if [ $# -gt 0 ]; then
    echo "------------------------------------------"
    echo "🧩 Installing Custom Skills..."
    echo "------------------------------------------"
    
    # Ensure npm/npx is available
    if ! command -v npx &> /dev/null; then
        echo "❌ Error: npx/npm is required to install skills."
        exit 1
    fi
    
    for SKILL in "$@"; do
        echo "📥 Installing skill: $SKILL..."
        npx skills add "$SKILL" --yes
        
        # Merge local .skills directory (if created) into .agents/skills
        if [ -d ".skills" ]; then
            mkdir -p .agents/skills
            cp -R .skills/. .agents/skills/ 2>/dev/null || true
            rm -rf .skills
        fi
    done
    echo "✅ Custom skills installed."
    echo ""
fi

echo "=========================================="
echo "🎉 Project Setup Complete!"
echo "=========================================="
echo "Your project at $ABS_PROJECT_PATH is ready for agentic coding."
echo "Local skills are configured in .agents/skills/"
echo ""
