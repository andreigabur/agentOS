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
echo "=========================================="
echo "🎉 AgentOS Installation Complete!"
echo "=========================================="
echo "Next steps:"
echo "1. Run 'codeburn' to start tracking usage."
echo "2. Run 'mempalace init ./memory' to start your local memory."
echo "3. Run 'graphify extract .' to build your code graph."
echo "4. Open the 'notes' folder in Obsidian."
