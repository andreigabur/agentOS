# AgentOS 🤖

AgentOS is a specialized development environment optimized for agentic coding. It provides local-first memory, deep codebase intelligence, and AI usage tracking, all integrated into a unified note-taking system.

## 🚀 Quick Start: Full Installation

To install everything (Languages, Package Managers, and Agent Tools) in one go, run the following command:

```bash
chmod +x *.sh && ./install.sh
```

---

## 🛠 Modular Usage

If you prefer to run the setup in stages, you can use the individual scripts:

### **If you only want to setup the Environment**
Use this to install only the foundations (Node.js/NVM, uv, and Python 3.12) without the agent tools.
```bash
chmod +x setup-environment.sh && ./setup-environment.sh
```

### **If you already have the prerequisites**
If you already have Node.js, uv, and Python 3.10+ and only want to install the tools (CodeBurn, MemPalace, and Graphify):
```bash
chmod +x setup-tools.sh && ./setup-tools.sh
```

---

## 📦 Core Features & Usage

### 1. AI Cost & Usage Tracking (CodeBurn)
CodeBurn provides a local, terminal-based dashboard to track exactly how many tokens and how much money your AI agents are consuming.
*   **To view your dashboard, run:**
    ```bash
    codeburn
    ```
*This will open the TUI (Terminal User Interface) where you can see live token metrics and task classifications across all your tools.*

### 2. Unified Agent Memory (MemPalace)
AgentOS sets up a "Hidden Palace" (`~/.mempalace/vault`) to act as a single, unified brain for all your AI coding tools. 
The installer **automatically configures the MCP server** for the following agents, meaning they all share the exact same context and memories:
*   🤖 **OpenCode**
*   🚀 **Gemini CLI**
*   🌌 **Google Antigravity**
*   🖥️ **Cursor**

*To manually query your memory, run: `mempalace query "your question"`*

### 3. Codebase Intelligence (Graphify)
*(Installation setup in progress)*
Graphify is a codebase intelligence engine that maps your architecture (imports, function calls) into a knowledge graph.

### 4. Obsidian Vault
A pre-configured `notes/` directory is created for your project knowledge. Graphify will export its architectural maps directly into this vault for visual navigation.

## 🧩 Next Steps

After running the installer, your agents are ready. Open Cursor, OpenCode, or Antigravity and ask your agent:
> *"What tools do you have access to through the MemPalace MCP?"*
