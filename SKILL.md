---
name: chat-context-compactor
description: >-
  Triggered when compacting, summarizing, or distilling a long chat session or conversation history ("compact context", "compacting context", "compacting cintext", "padatkan context", "ringkas sesi chat", "rampingkan konteks", "session compacting", "clean context", "compact detail gak kehilangan context", "reduce tokens without losing state", "session handoff", "context checkpoint", "transkrip kepanjangan", "salin state ke sesi baru", "mention by id", "lanjutkan dari checkpoint CTX-", "checkpoint id") into a high-fidelity, lossless architectural memory ledger and handoff checkpoint.
---

# 🧠 Chat Context Compactor (High-Fidelity Lossless-State Distillation with ID-Mention)

Skill ini dirancang khusus untuk **memadatkan (*compacting*) konteks sesi percakapan chat yang panjang** tanpa mengorbankan detail penting (*zero context loss*). Menghasilkan dokumen checkpoint beridentitas resmi (`DOC-ID`) dengan item-level anchor IDs (`REQ-xxx`, `FILE-xxx`, `ADR-xxx`, `ERR-xxx`, `ACT-xxx`) yang **dapat langsung di-mention di sesi obrolan baru (*new chat*)**.

---

## 🎯 Trigger Keywords & Activation Contexts

Skill ini aktif dalam 2 skenario:

### Skenario A: Pemadatan Sesi Berjalan (Compacting Mode)
- **Kata Kunci Pemicu**: 
  - `"compact context"`, `"compacting cintext"`, `"padatkan konteks"`, `"ringkas sesi chat"`
  - `"rampingkan chat"`, `"session compacting"`, `"clean context"`, `"compact detail gak kehilangan context"`
  - `"buatkan memory checkpoint by id"`, `"handoff sesi"`, `"simpan checkpoint"`
  - `"export session state"`, `"copy state ke clipboard"`

### Skenario B: Pemulihan State di Sesi Baru (New Chat Mention Resolution)
- **Kata Kunci Pemicu di Sesi Baru**:
  - `"Lanjutkan dari checkpoint CTX-..."`
  - `"Baca checkpoint CTX-..."`, `"Berdasarkan CTX-..."`, `"@CTX-..."`
  - `"Kerjakan [ACT-xxx] dari CTX-..."`
  - Pola regex pemicu: `\b(CTX|CKPT)-[A-Za-z0-9_-]+\b`

---

## 🔄 Protokol Resolusi Mention di Sesi Baru (New Chat Resolution)

> [!IMPORTANT]
> **ATURAN WAJIB BAGI AGEN KETIKA PENGGUNA ME-MENTION ID CHECKPOINT DI SESI BARU**:
>
> 1. **Deteksi Mention ID**:
>    Jika prompt user mengandung pola ID (misal: `CTX-8C26E0-001`), agen **DILARANG** menjawab "Saya tidak tahu checkpoint apa itu" atau menanyakan apa yang harus dilakukan.
>
> 2. **Pencarian Berkas Checkpoint**:
>    Agen wajib langsung mencari dan membaca berkas dokumen menggunakan `view_file` di urutan lokasi berikut:
>    - **Workspace**: `<workspace_root>/.checkpoints/<DOC-ID>.md`
>    - **Global**: `~/.gemini/checkpoints/<DOC-ID>.md` (atau `C:\Users\USER\.gemini\checkpoints\<DOC-ID>.md`)
>    - Atau periksa katalog `INDEX.md` di kedua folder tersebut jika nama berkas tidak persis.
>
> 3. **Restorasi State Invariant (Working Memory Adoption)**:
>    - Serap tujuan awal pengguna dari `[REQ-xxx]`.
>    - Pahami berkas-berkas yang sudah termutasi dari `[FILE-xxx]`.
>    - Perhatikan keputusan arsitektur di `[ADR-xxx]` dan riwayat kegagalan di `[ERR-xxx]`.
>
> 4. **Langsung Eksekusi Tanpa Basa-Basi Onboarding**:
>    - Jika pengguna menyebut tindakan spesifik (misal: *"Kerjakan `[ACT-002]`"*), agen langsung mengeksekusi item tersebut.
>    - Jika pengguna hanya menyebut *"Lanjutkan"*, agen langsung melanjutkan item checklist pertama yang belum selesai di `[ACT-xxx]`.
>    - Tidak perlu mengulang salam panjang atau menjelaskan ulang konteks awal.

---

## 🏛️ Prinsip Inti: Zero-Loss State Invariants (Gak Kehilangan Konteks)

Compacting adalah **pemisahan matematis antara Invariant State (Data Esensial) dan Ephemeral Noise (Artefak Sementara)**:

$$\text{Context Size}_{\text{Compacted}} = \text{State Invariants} + \text{Decision Ledger} + \text{Git Live State} + \text{Active Horizon} \quad (\ll \text{Raw Transcript})$$

| Kategori | Status | Perlakuan Compacting |
| :--- | :---: | :--- |
| **User Core Intent & Constraints** | **LOSSLESS** | Disimpan utuh dengan Anchor ID: `[REQ-001]`, `[REQ-002]`. |
| **File Mutation Ledger** | **LOSSLESS** | Disimpan dengan Anchor ID: `[FILE-001]`, `[FILE-002]` (path absolut & fungsi tersentuh). |
| **Git & Live Disk State** | **LOSSLESS** | Rekonsiliasi langsung dengan status riil Git (branch, uncommitted diffs di disk). |
| **Architectural Decisions (ADR)** | **LOSSLESS** | Disimpan dengan Anchor ID: `[ADR-001]`, `[ADR-002]` (alasan teknis pemilihan solusi). |
| **Error History & Resolutions** | **LOSSLESS** | Disimpan dengan Anchor ID: `[ERR-001]`, `[ERR-002]` (mencegah loop kegagalan di sesi baru). |
| **Immediate Next Actions** | **LOSSLESS** | Disimpan dengan Anchor ID: `[ACT-001]`, `[ACT-002]` (tindakan konkret berikutnya). |
| **Raw Tool Output & Dumps** | **PRUNED** | Pangkas ribuan baris terminal, grep, atau dump file utuh menjadi 1 baris intisari semantik. |
| **Dead-End Trials & Syntax Churn** | **PRUNED** | Pangkas loop trial-error yang gagal menjadi 1 catatan ringkas pada `[ERR-xxx]`. |

---

## 🛠️ Tooling & Scripts Otomatis

Skill ini dilengkapi paket automasi terpadu:

### 1. Unified One-Shot Runner (`compact-session.ps1` / `compact-session.cmd`)
Eksekusi langsung dari terminal untuk mengaudit, mengekstrak state ber-ID, menyimpan ke Dual Storage (`.checkpoints/` dan `~/.gemini/checkpoints/`), serta menyalin ke Clipboard:
```powershell
powershell -ExecutionPolicy Bypass -File "scripts/compact-session.ps1"
```
*Output menampilkan DOC-ID dan otomatis tersalin ke Clipboard Windows (`Ctrl+V`).*

### 2. Python State Extractor dengan Mention by ID (`context_compressor.py`)
Mengekstrak transkrip ke dokumen Markdown ber-ID dan memperbarui `INDEX.md`:
```powershell
python "scripts/context_compressor.py" --doc-id CTX-DEMO-001 --clipboard
```

### 3. PowerShell Context Auditor (`analyze-context.ps1`)
Menganalisis telemetri bloat konteks sesi:
```powershell
powershell -ExecutionPolicy Bypass -File "scripts/analyze-context.ps1" -CopyToClipboard
```

---

## 🏷️ Format Mention by ID dalam Percakapan

Pengguna dapat me-mention hasil pemadatan dengan berbagai cara yang fleksibel:

- **Full Document Mention**:
  > *"Lanjutkan pekerjaan dari checkpoint `CTX-8C26E0-001`"*
- **Item-Specific Mention**:
  > *"Tolong selesaikan `[ACT-002]` dari `CTX-8C26E0-001`"*
- **Reference by ID**:
  > *"Periksa kembali mutasi `[FILE-003]` pada `CTX-8C26E0-001`"*
- **Short Hand**:
  > *"@CTX-8C26E0-001 lanjut"*
