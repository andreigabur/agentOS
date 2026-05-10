#!/bin/bash

# AgentOS Phase 2: Agent Tools Setup
set -e

echo "🛠️ Installing Agentic Tools..."
echo ""

# 1. CodeBurn (Node.js)
echo "------------------------------------------"
echo "🔍 Checking for CodeBurn..."
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

# 2. MemPalace (Python via uv)
echo "------------------------------------------"
echo "🧠 Checking for MemPalace..."
echo "------------------------------------------"

MEM_PATH="$HOME/.mempalace/vault"

if uv tool list | grep -q "mempalace"; then
    echo "✅ MemPalace is already installed."
else
    echo "🧠 Installing MemPalace (Long-term Memory)..."
    uv tool install mempalace
    echo "✅ MemPalace installed."
fi

# Initialize memory vault if it doesn't exist
if [ ! -d "$MEM_PATH" ]; then
    echo "📂 Creating and Initializing Memory Vault at $MEM_PATH..."
    mkdir -p "$MEM_PATH"
    # Continually press enter to auto-accept all initialization prompts
    yes "" | mempalace init "$MEM_PATH" --no-llm
    echo "✅ Memory vault initialized."
else
    echo "✅ Memory vault already exists."
fi

echo ""
echo "🔌 MCP Configuration Tip:"
echo "To let your AI agents (Claude/Cursor) use this memory automatically, add this to your MCP config:"
echo " { \"mcpServers\": { \"mempalace\": { \"command\": \"$HOME/.local/bin/mempalace-mcp\" } } }"
echo ""

# 2.1 OpenCode Integration
if [ -d "$HOME/.config/opencode" ]; then
    echo "------------------------------------------"
    echo "🤖 Configuring OpenCode Integration..."
    echo "------------------------------------------"
    OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"
    
    # Create the config file if it doesn't exist
    if [ ! -f "$OPENCODE_CONFIG" ]; then
        echo '{"mcp": {}}' > "$OPENCODE_CONFIG"
    fi

    # Use python to safely check and update the JSON
    python3 -c "
import json, os
path = os.path.expanduser('$OPENCODE_CONFIG')
mempalace_mcp_path = os.path.expanduser('~/.local/bin/mempalace-mcp')

try:
    with open(path, 'r') as f: config = json.load(f)
except (json.JSONDecodeError, ValueError):
    config = {}

if 'mcp' not in config: config['mcp'] = {}

if 'mempalace' in config['mcp']:
    print('✅ MemPalace MCP is already configured in OpenCode.')
else:
    config['mcp']['mempalace'] = {
        'type': 'local',
        'command': [mempalace_mcp_path]
    }
    with open(path, 'w') as f: json.dump(config, f, indent=2)
    print('✅ MemPalace MCP added to OpenCode configuration.')
"
fi

# 2.2 Gemini CLI Integration
if command -v gemini &> /dev/null; then
    echo "------------------------------------------"
    echo "🤖 Configuring Gemini CLI Integration..."
    echo "------------------------------------------"
    # Redirect stderr to stdout (2>&1) because gemini prints the list to stderr
    if gemini mcp list 2>&1 | grep -q "mempalace:"; then
        echo "✅ MemPalace MCP is already configured in Gemini CLI."
    else
        # Silent add if it's missing
        MEMPALACE_MCP_PATH="$HOME/.local/bin/mempalace-mcp"
        gemini mcp add mempalace "$MEMPALACE_MCP_PATH" --scope user &> /dev/null
        echo "✅ MemPalace MCP added to Gemini CLI (User Scope)."
    fi
fi

# 2.3 Antigravity Integration
if [ -d "$HOME/.gemini/antigravity" ]; then
    echo "------------------------------------------"
    echo "🤖 Configuring Antigravity Integration..."
    echo "------------------------------------------"
    ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
    
    # Create or initialize the config file if it doesn't exist or is empty
    if [ ! -s "$ANTIGRAVITY_CONFIG" ]; then
        mkdir -p "$(dirname "$ANTIGRAVITY_CONFIG")"
        echo '{"mcpServers": {}}' > "$ANTIGRAVITY_CONFIG"
    fi

    # Use python to safely check and update the JSON
    python3 -c "
import json, os
path = os.path.expanduser('$ANTIGRAVITY_CONFIG')
mempalace_mcp_path = os.path.expanduser('~/.local/bin/mempalace-mcp')

try:
    with open(path, 'r') as f: config = json.load(f)
except Exception:
    config = {}

if 'mcpServers' not in config: config['mcpServers'] = {}

if 'mempalace' in config['mcpServers']:
    print('✅ MemPalace MCP is already configured in Antigravity.')
else:
    config['mcpServers']['mempalace'] = {
        'command': mempalace_mcp_path,
        'args': []
    }
    with open(path, 'w') as f: json.dump(config, f, indent=2)
    print('✅ MemPalace MCP added to Antigravity configuration.')
"
fi


# 2.4 Cursor Integration
if [ -d "$HOME/.cursor" ]; then
    echo "------------------------------------------"
    echo "🤖 Configuring Cursor Integration..."
    echo "------------------------------------------"
    CURSOR_CONFIG="$HOME/.cursor/mcp.json"
    
    # Create the config file if it doesn't exist
    if [ ! -f "$CURSOR_CONFIG" ]; then
        mkdir -p "$(dirname "$CURSOR_CONFIG")"
        echo '{"mcpServers": {}}' > "$CURSOR_CONFIG"
    fi

    # Use python to safely check and update the JSON
    python3 -c "
import json, os
path = os.path.expanduser('$CURSOR_CONFIG')
mempalace_mcp_path = os.path.expanduser('~/.local/bin/mempalace-mcp')

try:
    with open(path, 'r') as f: config = json.load(f)
except (json.JSONDecodeError, ValueError):
    config = {}

if 'mcpServers' not in config: config['mcpServers'] = {}

if 'mempalace' in config['mcpServers']:
    print('✅ MemPalace MCP is already configured in Cursor.')
else:
    config['mcpServers']['mempalace'] = {
        'command': mempalace_mcp_path,
        'args': []
    }
    with open(path, 'w') as f: json.dump(config, f, indent=2)
    print('✅ MemPalace MCP added to Cursor configuration.')
"
fi

# --- NEXT TOOLS (Commented out for now) ---

# # 3. Graphify (Python via uv)
# echo "------------------------------------------"
# echo "📊 Installing Graphify (Code Graph)..."
# echo "------------------------------------------"
# uv tool install graphifyy
# # Initialize graphify default config
# graphify install --platform gemini
# echo "✅ Graphify installed and initialized."
# echo ""

# # 4. Workspace Initialization
# echo "------------------------------------------"
# echo "📁 Initializing Workspace Folders..."
# echo "------------------------------------------"
# mkdir -p notes
# mkdir -p memory

# # Create a basic index for Obsidian if it doesn't exist
# if [ ! -f notes/Index.md ]; then
# cat <<EOF > notes/Index.md
# # AgentOS Vault Index

# Welcome to your AgentOS vault.

# - [[Project Roadmap]]
# - [[Architecture Graph]]
# - [[Agent Logs]]

# ---
# *Created by AgentOS Setup*
# EOF
# fi

# echo "✅ Workspace initialized."
# echo ""
