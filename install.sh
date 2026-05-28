#!/bin/bash

# AgentOS Main Installation Entry Point
set -e

echo "🤖 Welcome to the AgentOS Installer"
echo "=========================================="
echo ""

# Phase 1: Environment Setup (Languages and Package Managers)
if [ -f "./setup-environment.sh" ]; then
    bash ./setup-environment.sh
else
    echo "❌ Error: setup-environment.sh not found."
    exit 1
fi

echo ""

# Phase 2: Agent Tools
if [ -f "./setup-tools.sh" ]; then
    bash ./setup-tools.sh
else
    echo "❌ Error: setup-tools.sh not found."
    exit 1
fi

echo ""

# Phase 3: Project Workspace Setup (Optional)
if [ -t 0 ]; then
    echo "------------------------------------------"
    echo "📂 Project Workspace Setup (Optional)"
    echo "------------------------------------------"
    read -p "Would you like to set up a project workspace now? (y/N): " SETUP_PROJECT_CONFIRM
    if [[ "$SETUP_PROJECT_CONFIRM" =~ ^[Yy]$ ]]; then
        read -p "Enter the absolute or relative path of the project: " PROJECT_PATH
        if [ -n "$PROJECT_PATH" ]; then
            if [ -f "./setup-project.sh" ]; then
                bash ./setup-project.sh "$PROJECT_PATH"
            else
                echo "❌ Error: setup-project.sh not found."
            fi
        else
            echo "⚠️  No path entered. Skipping project setup."
        fi
    else
        echo "👋 Skipping project setup. You can run it later via: ./setup-project.sh <project-path>"
    fi
else
    echo "ℹ️  Non-interactive mode detected. Skipping project setup prompt."
fi

echo ""
echo "=========================================="
echo "🎉 AgentOS Installation Complete!"
echo "=========================================="
echo "Next steps:"
echo "1. Run 'codeburn' to start tracking usage."
echo "2. Run 'graphify extract <project-path>' to build your code graph."
echo "3. Run './setup-project.sh <project-path>' if you want to set up additional projects."
echo "4. Open the 'notes' folder in Obsidian."


