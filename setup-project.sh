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

# Manually expand tilde (~) to $HOME if passed literally
if [[ "$PROJECT_PATH" == "~/"* ]]; then
    PROJECT_PATH="${PROJECT_PATH/\~/$HOME}"
elif [ "$PROJECT_PATH" = "~" ]; then
    PROJECT_PATH="$HOME"
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

# 5. Local Memory MCP Configuration
echo "------------------------------------------"
echo "🧠 Configuring Local Memory MCP..."
echo "------------------------------------------"
node -e '
const fs = require("fs");
const path = require("path");
const projectPath = process.argv[1];
const memoryFilePath = path.join(projectPath, ".memory", "project.jsonl");
fs.mkdirSync(path.join(projectPath, ".memory"), { recursive: true });

// 1. opencode.json
const opencodePath = path.join(projectPath, "opencode.json");
let opencodeData = {};
if (fs.existsSync(opencodePath)) {
  try { opencodeData = JSON.parse(fs.readFileSync(opencodePath, "utf8")); } catch (e) {}
}
if (!opencodeData["$schema"]) opencodeData["$schema"] = "https://opencode.ai/config.json";
if (!opencodeData["mcp"]) opencodeData["mcp"] = {};
opencodeData["mcp"]["memory"] = {
  type: "local",
  command: ["npx", "-y", "@modelcontextprotocol/server-memory"],
  environment: { MEMORY_FILE_PATH: memoryFilePath }
};
fs.writeFileSync(opencodePath, JSON.stringify(opencodeData, null, 2));

// 2. .agents/mcp_config.json
const agentsDir = path.join(projectPath, ".agents");
fs.mkdirSync(agentsDir, { recursive: true });
const mcpConfigPath = path.join(agentsDir, "mcp_config.json");
let mcpData = {};
if (fs.existsSync(mcpConfigPath)) {
  try { mcpData = JSON.parse(fs.readFileSync(mcpConfigPath, "utf8")); } catch (e) {}
}
if (!mcpData["mcpServers"]) mcpData["mcpServers"] = {};
mcpData["mcpServers"]["memory"] = {
  command: "npx",
  args: ["-y", "@modelcontextprotocol/server-memory"],
  env: { MEMORY_FILE_PATH: memoryFilePath }
};
fs.writeFileSync(mcpConfigPath, JSON.stringify(mcpData, null, 2));
' "$ABS_PROJECT_PATH"
echo "✅ Local Memory MCP configured."
echo ""

# 6. Update AGENTS.md with Memory MCP rules
echo "------------------------------------------"
echo "📝 Updating AGENTS.md with Memory rules..."
echo "------------------------------------------"
AGENTS_MD_PATH="AGENTS.md"
if [ ! -f "$AGENTS_MD_PATH" ]; then
    touch "$AGENTS_MD_PATH"
fi

if ! grep -q "## Memory MCP" "$AGENTS_MD_PATH"; then
    cat << 'EOF' >> "$AGENTS_MD_PATH"

## Memory MCP

This project uses the Memory MCP server to persist context, decisions, and preferences across sessions. The memory graph stores what we've *learned* about the code — distinct from graphify, which maps what the code *is*.

Rules:
- **When to read memory:** Use `search_nodes` or `read_graph` before starting tasks that depend on architectural decisions, environment quirks, or user preferences, especially when a previous session may have already investigated the same area.
- **When to write memory:** Use `create_entities`, `create_relations`, and `add_observations` after resolving a non-obvious bug, establishing a new convention, or making a trade-off decision the user would want remembered.
- **Scope:** Do NOT store raw code snippets, file structure, or AST-level facts — those belong in graphify. Memory is for experiential context (gotchas, rationale, preferences, workflows).
EOF
    echo "✅ Memory rules appended to AGENTS.md."
else
    echo "✅ Memory rules already exist in AGENTS.md."
fi
echo ""

echo "=========================================="
echo "🎉 Project Setup Complete!"
echo "=========================================="
echo "Your project at $ABS_PROJECT_PATH is ready for agentic coding."
echo "Local skills are configured in .agents/skills/"
echo ""
