#!/bin/bash

# AgentOS Phase 2: Agent Tools Setup
set -e

echo "🛠️ Installing Agentic Tools..."
echo ""

# 1. CodeBurn (Node.js)
echo "------------------------------------------"
echo "🔍 CodeBurn..."
echo "------------------------------------------"

if command -v codeburn &> /dev/null; then
    echo "✅ CodeBurn is already installed."
else
    echo "🔥 Installing CodeBurn (Usage Tracking)..."
    # Note: npm install -g might require sudo on some systems, 
    # but we'll try standard install first.
    npm install -g codeburn
    echo "✅ CodeBurn installed."
fi
echo ""

# 2. Graphify (Python via uv)
echo "------------------------------------------"
echo "📊 Graphify (Code Graph)..."
echo "------------------------------------------"
if uv tool list | grep -q "graphifyy"; then
    echo "✅ Graphify is already installed."
else
    echo "📊 Installing Graphify (Codebase Intelligence)..."
    uv tool install graphifyy
    # Perform a clean global skill installation for ~/.agents/skills
    # We use 'install --platform' to avoid creating local project rules/workflows
    graphify install --platform antigravity
    echo "✅ Graphify installed and initialized globally."
fi
echo ""

# 3. OpenSpecs (Node.js)
echo "------------------------------------------"
echo "📋 OpenSpecs..."
echo "------------------------------------------"

if command -v openspec &> /dev/null; then
    echo "✅ OpenSpecs is already installed."
else
    echo "📋 Installing OpenSpecs (Spec-Driven Development)..."
    npm install -g @fission-ai/openspec@latest
    echo "✅ OpenSpecs installed."
fi
echo ""

# AgentOS Phase 3: Agent Skills

GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
mkdir -p "$GEMINI_SKILLS_DIR"

# Install obsidian-markdown skill
echo "------------------------------------------"
echo "🔧 Installing Obsidian Markdown Skill..."
echo "------------------------------------------"
SKILLS_DIR="$HOME/.agents/skills"
if [ -d "$SKILLS_DIR/obsidian-markdown" ]; then
    echo "✅ obsidian-markdown skill already installed."
else
    echo "📥 Installing obsidian-markdown from kepano/obsidian-skills..."
    npx skills add https://github.com/kepano/obsidian-skills --skill obsidian-markdown --global --yes
    echo "✅ obsidian-markdown skill installed."
fi

# Ensure synced with Gemini config
if [ -d "$SKILLS_DIR/obsidian-markdown" ] && [ ! -d "$GEMINI_SKILLS_DIR/obsidian-markdown" ]; then
    echo "🔗 Linking obsidian-markdown to Gemini UI..."
    cp -R "$SKILLS_DIR/obsidian-markdown" "$GEMINI_SKILLS_DIR/"
fi
echo ""

# Install obsidian-cli skill
echo "------------------------------------------"
echo "🔧 Installing Obsidian CLI Skill..."
echo "------------------------------------------"
if [ -d "$SKILLS_DIR/obsidian-cli" ]; then
    echo "✅ obsidian-cli skill already installed."
else
    echo "📥 Installing obsidian-cli from kepano/obsidian-skills..."
    npx skills add https://github.com/kepano/obsidian-skills --skill obsidian-cli --global --yes
    echo "✅ obsidian-cli skill installed."
fi

# Ensure synced with Gemini config
if [ -d "$SKILLS_DIR/obsidian-cli" ] && [ ! -d "$GEMINI_SKILLS_DIR/obsidian-cli" ]; then
    echo "🔗 Linking obsidian-cli to Gemini UI..."
    cp -R "$SKILLS_DIR/obsidian-cli" "$GEMINI_SKILLS_DIR/"
fi
echo ""