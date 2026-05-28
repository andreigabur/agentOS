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
If you already have Node.js, uv, and Python 3.10+ and only want to install the tools (CodeBurn and Graphify):
```bash
chmod +x setup-tools.sh && ./setup-tools.sh
```

### **If you want to set up a new project workspace**
Use this script to initialize a project workspace, configure local Graphify settings, run OpenSpecs, normalize agent folders to `.agents`, and optionally install project-specific skills locally:
```bash
./setup-project.sh <project-path> [skill-url-1] [skill-url-2] ...
```
Example:
```bash
# Set up a new project with local graph/specs support and install a search skill locally
./setup-project.sh ~/projects/my-new-app vercel-labs/skills/examples/web-search
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

### 2. Codebase Intelligence (Graphify)
Graphify is a codebase intelligence engine that maps your architecture (imports, function calls) into a knowledge graph.
*   **Documentation:** [graphifyy on GitHub](https://github.com/safishamsi/graphify)

### 3. Agent Skills
AgentOS installs universal agent skills to enhance your tools with specialized capabilities:
*   **Obsidian Markdown** — Create and edit Obsidian Flavored Markdown (wikilinks, callouts, frontmatter, embeds)
*   **Obsidian CLI** — Interact with Obsidian vaults: read, create, search, and manage notes, tasks, and properties
*   Skills are linked to Antigravity automatically; OpenCode discovers them from `~/.agents/skills/`

### 4. Spec-Driven Development (OpenSpecs)
OpenSpecs enables spec-driven development, letting you generate implementation plans from requirements before writing code.
*   **To initialize in a project, run:**
    ```bash
    openspec init
    ```
    This creates an `openspec/` directory in your project and installs agent skills for spec-driven workflows.
*   **Documentation:** [OpenSpec on GitHub](https://github.com/Fission-AI/OpenSpec)

## 🧩 Next Steps

After running the installer, your agents are ready.
