# 📏 Distillation Rules & Precision Retention Taxonomy (Zero Context-Loss)

This document establishes strict rules distinguishing between information that **MUST BE RETAINED 100% (Lossless Invariants)** and information that **MUST BE PRUNED (Ephemeral Noise)** to ensure maximum context density without loss of critical technical meaning.

---

## 1. Retention Taxonomy (Keep vs Prune Matrix)

| Element Category | Retention Status | Rationale & Canonical Representation |
| :--- | :---: | :--- |
| **Initial User Goal & Objective** | 🟢 **MANDATORY (100%)** | Dictates the project compass. Preserved verbatim or high-precision paraphrase. |
| **User Corrections & Negative Constraints** | 🟢 **MANDATORY (100%)** | Critical constraints ("do not use library X", "always use language Y", "use `;` instead of `&&`"). Losing these causes agents to repeat avoided mistakes. |
| **File Mutation History** | 🟢 **MANDATORY (100%)** | Comprehensive ledger of files created `[NEW]`, modified `[MODIFY]`, or deleted `[DELETE]` along with touched functions/components. |
| **Architectural Decisions (ADR)** | 🟢 **MANDATORY (100%)** | Architectural choices made (e.g., choosing SQLite WAL over in-memory DB for persistence, choosing regex over AST parser). |
| **Discarded Hypotheses & Dead Ends** | 🟢 **MANDATORY (100%)** | Approaches that failed and the technical reasons why. Without this, fresh sessions re-explore the same failed paths. |
| **Active Unresolved Bugs & Stack Traces** | 🟢 **MANDATORY (100%)** | Precise error messages, failing lines of code, and active root-cause hypotheses currently under test. |
| **Environment State & Credentials Topology** | 🟢 **MANDATORY (100%)** | Active local/staging ports, OS configurations, database names (with secrets sanitized). |
| **Next Action Checklist** | 🟢 **MANDATORY (100%)** | 1–5 concrete, actionable next steps ready for immediate execution. |
| **Raw Tool Outputs (View File, Terminal Logs)** | 🔴 **PRUNED (100%)** | Thousands of lines of build logs or terminal output. Condensed to 1-line semantic summaries (e.g., `Build passed in 4.2s`, `File contains 120 lines with 4 classes`). |
| **Duplicate Content Reads** | 🔴 **PRUNED (100%)** | Repeatedly viewing unchanged files. Record only the final verified state. |
| **Conversational Chit-Chat & Filler** | 🔴 **PRUNED (100%)** | "Certainly!", "I understand", "Let's begin", "Please wait a moment". |
| **Trial-and-Error Syntax Churn** | 🔴 **PRUNED (100%)** | Minor intermediate syntax error correction cycles. Record only the final passing state. |

---

## 2. Theoretical Context Distillation Formulation

### State Preservation Index ($SPI$)
The benchmark of successful compaction is $SPI \equiv 1.0$ (100% Invariants Retained):

$$SPI = \frac{\sum \text{Retained Invariant Tokens}}{\sum \text{Total Critical Invariant Tokens in Session}} = 1.0$$

If any file mutation is omitted, or a user negative constraint is forgotten, then $SPI < 1.0$ (**FAILED: context loss detected**).

### Token Compression Ratio ($CR$)
Target token reduction without compromising $SPI$:

$$CR = 1 - \frac{T_{\text{compact}}}{T_{\text{raw}}} \ge 0.80 \quad (\text{Target: 80\% – 92\% compression})$$

---

## 3. Transformation Techniques: From Noise to Invariant Tuples

### Example 1: Terminal Execution / Run Command
- ❌ **Raw (Noise - 150 lines)**:
  ```text
  > npm install @tanstack/react-query
  added 42 packages, and audited 312 packages in 4s
  found 0 vulnerabilities
  > npm run build
  [vite] building for production...
  ✓ 148 modules transformed.
  dist/index.html                   0.45 kB │ gzip:  0.30 kB
  dist/assets/index-B_9s5tY1.css    1.24 kB │ gzip:  0.64 kB
  dist/assets/index-Cz4Wk32Q.js   142.10 kB │ gzip: 45.32 kB
  ✓ built in 312ms
  ```
- ✅ **Distilled (Lossless Invariant - 2 lines)**:
  - `Dependency Added`: `@tanstack/react-query` installed (0 vulnerabilities).
  - `Build Status`: Vite production build passed (`dist/assets/index-Cz4Wk32Q.js` ~142 kB).

### Example 2: File Investigation (View File)
- ❌ **Raw (Noise - 80 lines of verbatim code)**:
  Reading entire `src/auth/jwt.ts` merely to check a function signature.
- ✅ **Distilled (Lossless Invariant - 1 line)**:
  - `src/auth/jwt.ts`: Exports `verifyToken(token: string, secret: string): JwtPayload` using `HS256`.

### Example 3: Debugging Trial & Resolution
- ❌ **Raw (Noise - 6 turns of trial and error)**:
  Attempt 1 changed A with `Cannot read property of undefined`. Attempt 2 changed B with `TypeError`. Attempt 3 succeeded with null-coalescing.
- ✅ **Distilled (Lossless Invariant - 2 lines)**:
  - `Bug Fixed`: Null reference on `user.profile.avatar` upon first-time login.
  - `Root Cause & Fix`: Profile uninitialized in database. Resolved with optional chaining `user?.profile?.avatar ?? DEFAULT_AVATAR` in `UserProfileCard.tsx#L32`.

---

## 4. Sensitive Data Protection (Secret Sanitization)

When compacting session contexts, all system secrets and credentials must be sanitized:
- `API Keys`: `sk-proj-abc...123` $\to$ `[STORED_IN_ENV: OPENAI_API_KEY]`
- `Passwords`: `admin12345` $\to$ `[REDACTED_PASSWORD]`
- `JWT Tokens`: `eyJhbGciOiJIUz...` $\to$ `[VALID_SESSION_JWT_TOKEN]`
- Private user paths are mapped to standard canonical representations (e.g., `~/.gemini/...`).

---

## 5. State Reconstruction Algorithm (New Session Mental Model)

A fresh session receiving the compacted checkpoint must reconstruct a complete mental model in a single read:

1. **WHERE WE ARE**: Repository root, active branch, and high-level goal.
2. **WHAT WAS DONE**: Ledger of every file touched and the architectural rationale.
3. **WHY IT WAS DONE**: Agreed design invariants and avoided anti-patterns.
4. **WHAT IS BROKEN / PENDING**: Open issues and awaiting checklist items.
5. **WHAT IS NEXT**: The exact turn-one action the new agent must execute.
