# 📑 Canonical Compaction Templates (with Mentionable IDs)

This document provides 4 standard ID-anchored templates for chat session compaction.

---

## Template 1: ID-Mentionable Session Checkpoint Document

*Standard ID-anchored document persisted in `.checkpoints/<DOC-ID>.md` and `~/.gemini/checkpoints/<DOC-ID>.md`.*

```markdown
# 📑 [DOC-ID: CTX-XXXXXX-001] HIGH-FIDELITY SESSION STATE CHECKPOINT

> **Document ID**: `CTX-XXXXXX-001` | **Method**: Lossless State Distillation
>
> **HOW TO MENTION IN A NEW CHAT**:
> Mention this Document ID in any new chat prompt:
> *"Resume work from checkpoint `CTX-XXXXXX-001`"* or *"Execute `[ACT-001]` from `CTX-XXXXXX-001`"*
> The agent in the new session will automatically locate and load this document.

> [!IMPORTANT]
> **AGENT COLD-START DIRECTIVE**:
> You are resuming a previously compacted session. All state invariants below are **VALID & ACTIVE**.
> Do NOT ask onboarding questions or request background recap.
> **Proceed directly with executing the actions in Section 6.**

---

## 1. 🎯 Chronological User Instructions & Intent Invariants
<a id="REQ-001"></a>
### `[REQ-001]` Instruction #1
```text
[Initial user prompt and core goal]
```

<a id="REQ-002"></a>
### `[REQ-002]` Instruction #2
```text
[Subsequent user correction or negative constraint]
```

---

## 2. 🛠️ Structural File Mutation Ledger ([NEW] / [MODIFY] / [DELETE])
| Item ID | Absolute File Path | Mutation Summary & Touched Symbols |
| :---: | :--- | :--- |
| <a id="FILE-001"></a>`[FILE-001]` | `/path/to/project/src/services/api.ts` | New service for fetching orders with exponential retry |
| <a id="FILE-002"></a>`[FILE-002]` | `/path/to/project/src/components/Table.tsx` | Added date column sorting and server pagination |

---

## 3. 🌿 Real-Time Git & Workspace Disk State
- **Working Directory (CWD)**: `/path/to/project`
- **Active Branch**: `main`
- **Working Tree Status**: `Clean (no uncommitted changes) or list of dirty files`

---

## 4. ⚠️ Incident Traces & Resolutions (Negative Knowledge Defense)
<a id="ERR-001"></a>
### `[ERR-001]` Failure during `[Command / Action]`
- *Error Symptom*: `[Error message]`
- *Resolution Status*: Resolved on next step via [fix approach].

---

## 5. 🧠 Reasoning Milestones & Architectural Decisions (ADR)
<a id="ADR-001"></a>
- `[ADR-001]` [Technical decision taken and architectural rationale]
<a id="ADR-002"></a>
- `[ADR-002]` [Alternative approach rejected and justification]

---

## 6. 🚀 Immediate Execution Horizon (Actionable Next Steps)
<a id="ACT-001"></a>
- [ ] **`[ACT-001]`**: [Turn-one task the new agent must immediately execute]
<a id="ACT-002"></a>
- [ ] **`[ACT-002]`**: [Second upcoming task]
<a id="ACT-003"></a>
- [ ] **`[ACT-003]`**: [Validation and testing task]
```

---

## Template 2: Inline Working Memory Ledger

*Inject this template directly into an ongoing conversation when turns exceed threshold to refresh attention and prevent drift.*

```markdown
---
### 🧠 WORKING MEMORY LEDGER (Session Turn: [TurnCount])
*Active context refreshed to maintain precision and eliminate attention drift:*

- **Active Objective**: [Immediate task being resolved on this turn]
- **Key Target Files**:
  - `[Absolute path 1]` (status: modified & verified)
  - `[Absolute path 2]` (status: next edit target)
- **Critical Invariants**: [Must-follow constraints]
- **Remaining Task Horizon**:
  - [x] [Completed task]
  - [ ] **[CURRENT TASK]**: [In-progress action]
  - [ ] [Upcoming task]
---
```

---

## Template 3: Subagent Dispatch Briefing

*Use when delegating a focused sub-task via `invoke_subagent`.*

```markdown
# SUBAGENT TASK BRIEFING: [Module / Sub-Task Name]

## Global Context & Architecture
- **Workspace**: `[Absolute path]`
- **Tech Stack**: `[Stack]`
- **Parent Objective**: `[1-2 sentence core goal]`

## Subagent Scope of Responsibility
You are assigned exclusively to complete:
`[Detailed subagent task description]`

## Constraints & Interface Contracts
- Adhere strictly to interfaces defined in `[Absolute path to types/interface]`.
- Do not modify files outside `[Specific directory]`.
- Rule: [e.g., use async/await, no TypeScript any].

## Relevant Target Files
1. `[Target file 1 path]` — [Role of this file]
2. `[Target file 2 path]` — [Role of this file]

## Expected Return Output
Return a concise summary covering:
1. Files created or modified.
2. Build/test verification results.
3. Potential downstream impact on other modules.
```

---

## Template 4: Incident & Deep Debugging Checkpoint

*Use when tracking complex multi-step debugging and hypothesis elimination.*

```markdown
# 🔍 INCIDENT & DEBUGGING CHECKPOINT

## 1. Symptom & Reproduction
- **Anomaly Description**: [Observed failure vs expected behavior]
- **Reproduction Command**: [Command triggering the bug]
- **Core Error Log**:
  ```text
  [Key 3-5 lines of stack trace]
  ```

## 2. Hypothesis Elimination Matrix
| No | Tested Hypothesis | Action / Mutation | Result | Status |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Backend CORS mismatch | Added wildcard headers | Error persisted | ❌ Rejected |
| 2 | ID type mismatch (string vs number) | Updated DTO parser | Payload parsed, rejected by DB | ❌ Rejected |
| 3 | Auth middleware expects Bearer prefix | Stripped 'Bearer ' prefix | Request reached controller | ✅ Verified Fix |

## 3. Confirmed Root Cause
[Technical explanation of the underlying failure mechanism]

## 4. Remediation Plan
- [ ] Patch `[File path]` at line [N]
- [ ] Add regression test in `[Test file path]`
- [ ] Re-run validation suite via `[Test command]`
```
