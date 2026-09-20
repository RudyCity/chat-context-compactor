---
name: chat-context-compactor
description: >-
  Triggered when compacting, summarizing, or distilling a long chat session or conversation history ("compact context", "compacting context", "compacting cintext", "padatkan context", "ringkas sesi chat", "rampingkan konteks", "session compacting", "clean context", "compact detail gak kehilangan context", "reduce tokens without losing state", "session handoff", "context checkpoint", "mention by id", "lanjutkan dari checkpoint CTX-", "checkpoint id") into a high-fidelity, lossless architectural memory ledger and handoff checkpoint.
---

# 🧠 Chat Context Compactor (High-Fidelity Lossless-State Distillation with ID-Mention)

This skill is purpose-built to **compact long chat session contexts without losing critical technical details (*zero context loss*)**. It prunes 80%–92% of *ephemeral noise* (raw terminal output, duplicate file views, trial-and-error syntax loops, conversational pleasantries), while **retaining 100% of State Invariants**: user goals, chronological instruction timeline, architectural decision records (ADRs), file mutation lineage, real-time Git status, active bug states, and immediate next actions. Checkpoint documents have official identifiers (`DOC-ID`) and item-level anchor IDs (`REQ-xxx`, `FILE-xxx`, `ADR-xxx`, `ERR-xxx`, `ACT-xxx`) that **can be directly mentioned in any new chat session**.

---

## 🎯 Trigger Keywords & Activation Contexts

This skill activates in two primary scenarios:

### Scenario A: Compacting an Active Session (Compaction Mode)
- **Trigger Keywords**: 
  - `"compact context"`, `"compacting context"`, `"compacting cintext"`, `"padatkan konteks"`, `"ringkas sesi chat"`
  - `"session compacting"`, `"clean context"`, `"compact detail gak kehilangan context"`, `"reduce tokens without losing state"`
  - `"create memory checkpoint by id"`, `"session handoff"`, `"save checkpoint"`
  - `"export session state"`, `"copy state to clipboard"`

### Scenario B: Restoring State in a New Chat (New Chat Mention Resolution)
- **Trigger Keywords in New Chat**:
  - `"Resume from checkpoint CTX-..."`
  - `"Continue from CTX-..."`, `"Refer to CTX-..."`, `"@CTX-..."`
  - `"Execute [ACT-xxx] from CTX-..."`
  - Regex trigger pattern: `\b(CTX|CKPT)-[A-Za-z0-9_-]+\b`

---

## 🔄 Protocol: Resolving Checkpoint Mentions in a New Chat

> [!IMPORTANT]
> **MANDATORY DIRECTIVE WHEN A USER MENTIONS A CHECKPOINT ID IN A NEW CHAT**:
>
> 1. **Detect Mention ID**:
>    When the user prompt includes a checkpoint ID pattern (e.g., `CTX-8C26E0-001`), the agent **MUST NEVER** reply with generic confusion or ask the user to explain the project from scratch.
>
> 2. **Locate & Read Checkpoint Document**:
>    The agent must immediately inspect and read the document using `view_file` at:
>    - **Workspace**: `<workspace_root>/.checkpoints/<DOC-ID>.md`
>    - **Global**: `~/.gemini/checkpoints/<DOC-ID>.md` (or `C:\Users\USER\.gemini\checkpoints\<DOC-ID>.md`)
>    - Or inspect `INDEX.md` in either directory if the exact file name varies.
>
> 3. **Restore State Invariants (Working Memory Adoption)**:
>    - Adopt the user's primary objectives from `[REQ-xxx]`.
>    - Recognize all files already created or modified from `[FILE-xxx]`.
>    - Adhere to technical decisions in `[ADR-xxx]` and failure avoidance in `[ERR-xxx]`.
>
> 4. **Execute Immediately Without Onboarding Fluff**:
>    - If the user referenced a specific action (e.g., *"Work on `[ACT-002]`"*), execute that action immediately.
>    - If the user simply said *"Continue"*, proceed directly with the first unchecked item in `[ACT-xxx]`.
>    - Do not output repetitive greetings or regurgitate the entire context back to the user.

---

## 🏛️ Core Principles: Zero-Loss State Invariants

Effective compaction is **a mathematical separation of Invariant State (Essential Data) and Ephemeral Noise (Temporary Artifacts)**:

$$\text{Context Size}_{\text{Compacted}} = \text{State Invariants} + \text{Decision Ledger} + \text{Git Live Disk} + \text{Active Horizon} \quad (\ll \text{Raw Transcript})$$

| Category | Retention Status | Compactor Treatment |
| :--- | :---: | :--- |
| **User Core Intent & Constraints** | **LOSSLESS** | Preserved verbatim with Anchor IDs: `[REQ-001]`, `[REQ-002]`. |
| **File Mutation Ledger** | **LOSSLESS** | Absolute file paths & affected functions: `[FILE-001]`, `[FILE-002]`. |
| **Git & Live Disk State** | **LOSSLESS** | Reconciled directly with disk reality (active branch, uncommitted diffs). |
| **Architectural Decisions (ADR)** | **LOSSLESS** | Rationale for chosen solutions & rejected alternatives: `[ADR-001]`. |
| **Error Traces & Resolutions** | **LOSSLESS** | Past failures & verified fixes: `[ERR-001]` (prevents failure loops). |
| **Immediate Next Actions** | **LOSSLESS** | Concrete upcoming checklist: `[ACT-001]`, `[ACT-002]`. |
| **Raw Tool Output & Dumps** | **PRUNED** | Thousands of lines of logs/greps compressed to 1-line semantic summaries. |
| **Dead-End Trials & Syntax Churn** | **PRUNED** | Failed trials summarized into concise resolution notes in `[ERR-xxx]`. |

See [distillation-rules.md](./references/distillation-rules.md) for the complete taxonomy.

---

## ⚡ 5-Stage Compaction Pipeline

When invoked to compact chat session context, the agent must execute the following 5 stages:

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    5-STAGE HIGH-FIDELITY COMPACTION PIPELINE                │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ STAGE 1: Context Telemetry & Bloat Profiling                          │  │
│  │ Scan conversation history / transcript.jsonl, count steps, tool ratio │  │
│  └──────────────────────────────────┬────────────────────────────────────┘  │
│                                     │                                       │
│                                     ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ STAGE 2: Chronological User Intent & Constraint Ledger                │  │
│  │ Extract all user prompts, sub-goals, and negative rules chronologically│  │
│  └──────────────────────────────────┬────────────────────────────────────┘  │
│                                     │                                       │
│                                     ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ STAGE 3: Structural File & Git Live State Reconciliation             │  │
│  │ Reconcile chat mutations ([NEW]/[MODIFY]) with live git disk status   │  │
│  └──────────────────────────────────┬────────────────────────────────────┘  │
│                                     │                                       │
│                                     ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ STAGE 4: Architectural Decisions (ADR) & Error Resolution Ledger     │  │
│  │ Record permanent technical choices, rejected designs, & resolved bugs │  │
│  └──────────────────────────────────┬────────────────────────────────────┘  │
│                                     │                                       │
│                                     ▼                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ STAGE 5: Active State & Immediate Execution Horizon                   │  │
│  │ Produce next action checklist, cold-start directive, & clipboard copy │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 3 Output Compaction Modes

### Mode 1: Clean Session Handoff Blueprint (Zero-Loss Migration to a New Chat)
*Use when the user wants to start a fresh chat session.*
- Produces a self-contained Markdown prompt equipped with an **Agent Cold-Start Directive**.
- Automatically copied to the Windows Clipboard (`Ctrl+V`).
- The agent in the new session continues work immediately from turn one without onboarding delay.
- Template: [TEMPLATE_SESSION_HANDOFF](./references/compaction-templates.md#template-1-id-mentionable-session-checkpoint-document).

### Mode 2: Inline Working Memory Ledger (Attention Refresh in Ongoing Chat)
*Use when the session has grown long and the agent needs an internal memory refresh to mitigate attention drift.*
- Injects a compact memory table directly into the current chat stream.
- Resets attention weights to focus on immediate high-priority invariants.
- Template: [TEMPLATE_INLINE_LEDGER](./references/compaction-templates.md#template-2-inline-working-memory-ledger).

### Mode 3: Subagent Dispatch Briefing (Focused Delegation)
*Use when delegating a sub-task via `invoke_subagent`.*
- Supplies the subagent with an accurate, high-density briefing of global variables, architecture constraints, and relevant files without burdening its context window with past conversational churn.
- Template: [TEMPLATE_SUBAGENT_DISPATCH](./references/compaction-templates.md#template-3-subagent-dispatch-briefing).

---

## 🛠️ Automated Scripts & Tooling

### 1. Unified One-Shot Runner (`compact-session.ps1` / `compact-session.cmd`)
Run from any terminal to profile, extract state, persist to Dual Storage (`.checkpoints/` and `~/.gemini/checkpoints/`), and copy to Clipboard:
```powershell
powershell -ExecutionPolicy Bypass -File "scripts/compact-session.ps1"
```
*Outputs the DOC-ID and copies the Handoff Brief to the Windows Clipboard (`Ctrl+V`).*

### 2. Python State Extractor with ID-Mention (`context_compressor.py`)
Extracts transcripts into ID-anchored Markdown documents and updates `INDEX.md`:
```powershell
python "scripts/context_compressor.py" --doc-id CTX-DEMO-001 --clipboard
```

### 3. PowerShell Context Auditor (`analyze-context.ps1`)
Analyzes conversation telemetry, step counts, tool call distributions, and recommends compaction strategy:
```powershell
powershell -ExecutionPolicy Bypass -File "scripts/analyze-context.ps1" -CopyToClipboard
```

---

## 🏷️ Mention-by-ID Syntax in Conversations

Users can reference checkpoints in new conversations using flexible formats:

- **Full Document Mention**:
  > *"Resume work from checkpoint `CTX-8C26E0-001`"*
- **Item-Specific Mention**:
  > *"Execute `[ACT-002]` from `CTX-8C26E0-001`"*
- **Constraint Reference**:
  > *"Ensure adherence to `[REQ-002]` and review `[FILE-003]` from `CTX-8C26E0-001`"*
- **Shorthand**:
  > *"@CTX-8C26E0-001 continue"*
