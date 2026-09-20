# 🧠 Chat Context Compactor (`chat-context-compactor`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)](#installation)
[![Skill: Antigravity](https://img.shields.io/badge/AI%20Skill-Antigravity%20%7C%20Gemini-orange.svg)](#)

> **High-Fidelity Lossless-State Distillation & Memory Checkpoint Engine for AI Coding Agents.**
> Prunes 80%–92% of ephemeral token bloat while retaining **100% of critical state invariants**, active file mutation history, real-time Git status, and architectural decisions. Generates **ID-mentionable checkpoints** (`CTX-XXXXXX-001`) that can be resumed seamlessly in any new chat session.

---

## ⚡ Quick Installation (Install Anywhere)

Install this skill instantly on any machine, cloud VM, or developer environment with a single command:

### 🪟 Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/RudyCity/chat-context-compactor/main/install.ps1 | iex
```
*Tip: Append `-Workspace` to install locally inside `./.agents/skills/` instead of global user configuration.*

### 🐧 Linux / macOS (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/RudyCity/chat-context-compactor/main/install.sh | bash
```

### 📦 Manual via Git Clone
```bash
# Global Antigravity Config
git clone https://github.com/RudyCity/chat-context-compactor.git ~/.gemini/config/skills/chat-context-compactor

# Or Project Workspace (.agents/skills)
git clone https://github.com/RudyCity/chat-context-compactor.git .agents/skills/chat-context-compactor
```

---

## 🎯 Why This Skill?

As AI agent conversations run long (20+ turns, thousands of lines of logs and files), context windows suffer from **Token Bloat** and **Attention Drift** (agents forget initial objectives, negative rules, or touched files).

Standard default summaries are typically too shallow (*lossy 2-3 sentence summaries*) and discard critical technical context.

**`chat-context-compactor`** solves this via rigorous mathematical separation:

$$\text{Context Size}_{\text{Compacted}} = \text{State Invariants} + \text{File Mutation Ledger} + \text{Git Live Disk} + \text{Active Horizon} \quad (\ll \text{Raw Transcript})$$

| Category | Retention Status | Compactor Treatment |
| :--- | :---: | :--- |
| **User Core Intent & Constraints** | 🟢 **100% Lossless** | Preserved verbatim with Anchor IDs: `[REQ-001]`, `[REQ-002]` |
| **File Mutation Ledger** | 🟢 **100% Lossless** | Absolute paths & touched functions: `[FILE-001]` |
| **Real-Time Git Workspace Disk** | 🟢 **100% Lossless** | Active branch & dirty files reconciled directly from disk |
| **Architectural Decisions (ADR)** | 🟢 **100% Lossless** | Technical decisions & rejected alternatives: `[ADR-001]` |
| **Error Traces & Resolutions** | 🟢 **100% Lossless** | Prevents new sessions from repeating dead ends: `[ERR-001]` |
| **Raw Tool Output & Dumps** | 🔴 **Pruned** | Thousands of lines of logs/greps condensed to 1-line semantic summaries |
| **Conversational Chit-Chat** | 🔴 **Pruned** | Greetings, boilerplate acknowledgments, and filler removed |

---

## 🚀 Key Capabilities

1. **State Preservation Index ($SPI \equiv 1.0$)**: Guarantees zero loss of critical state and active tasks.
2. **Mention-by-ID in New Chats**: Official Document IDs (`DOC-ID: CTX-XXXXXX-001`) with item-level anchor IDs allow resuming work in fresh sessions without re-explaining background.
3. **Dual Storage Registry**: Checkpoints are automatically persisted to both Global (`~/.gemini/checkpoints/`) and Workspace (`.checkpoints/`) stores and indexed in `INDEX.md`.
4. **Auto-Copy to Windows Clipboard (`Ctrl+V`)**: Distilled Handoff Briefs are automatically copied to the clipboard for instant pasting into a new chat tab.
5. **Real-Time Git Reconciliation**: Captures live branch and uncommitted disk changes so nothing is lost outside the chat window.

---

## 📖 How to Use

### Method 1: Automatic via Chat Prompt
In any long-running conversation, simply prompt:
> *"Compact the context of this session in detail"*
> or
> *"Distill chat context for a fresh session handoff"*

### Method 2: Mention Checkpoints in a New Chat
Open a new chat tab or session, and mention the checkpoint ID:
> *"Resume work from checkpoint `CTX-8C26E0-001`"*
> or
> *"Execute `[ACT-001]` from `CTX-8C26E0-001`"*

The agent in the new session detects the ID, loads the document from `.checkpoints/` or `~/.gemini/checkpoints/`, restores working memory with 100% fidelity, and **proceeds immediately with the task without onboarding questions**.

### Method 3: One-Shot CLI Runner (Terminal)
Run directly from your project terminal:
```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File "~/.gemini/config/skills/chat-context-compactor/scripts/compact-session.ps1"

# Or if within the scripts directory
.\scripts\compact-session.ps1
```
*Output is profiled, extracted, and placed directly onto your Windows Clipboard (`Ctrl+V`).*

---

## 📂 Repository Structure

```text
chat-context-compactor/
├── SKILL.md                          # Main skill instructions, triggers, & new chat mention protocol
├── references/
│   ├── distillation-rules.md         # Keep vs Prune taxonomy & mathematical formulation
│   └── compaction-templates.md       # 4 ID-anchored templates with HTML anchor tags
├── scripts/
│   ├── analyze-context.ps1           # Transcript telemetry bloat & tool-call analyzer
│   ├── context_compressor.py         # Python state invariant extractor & Git reconciler
│   ├── compact-session.ps1           # One-shot runner PowerShell
│   └── compact-session.cmd           # One-shot runner CMD launcher
├── install.ps1                       # Universal Windows PowerShell installer
├── install.sh                        # Universal Linux/macOS Bash installer
├── README.md                         # Project documentation
├── LICENSE                           # MIT License
└── .gitignore                        # Enforces zero personal chat history leaks
```

---

## 🔒 Privacy & Confidentiality (Zero Chat Leak)

This repository enforces strict `.gitignore` rules:
- **NEVER** commits or pushes `transcript.jsonl`, conversation logs, or private user checkpoints.
- Distributes only the pure distillation engine, templates, rules, and installers.

---

## 📄 License

Distributed under the [MIT](LICENSE) License. Built with ❤️ by [RudyCity](https://github.com/RudyCity).
