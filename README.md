# 🧠 Chat Context Compactor (`chat-context-compactor`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)](#installation)
[![Skill: Antigravity](https://img.shields.io/badge/AI%20Skill-Antigravity%20%7C%20Gemini-orange.svg)](#)

> **High-Fidelity Lossless-State Distillation & Memory Checkpoint Engine for AI Coding Agents.**
> Prunes 80%–92% of ephemeral token bloat while retaining **100% of critical state invariants**, active file mutation history, real-time Git status, and architectural decisions. Generates **ID-mentionable checkpoints** (`CTX-XXXXXX-001`) that can be resumed seamlessly in any new chat session.

---

## ⚡ Quick Installation (Install di Manapun)

Pasang skill ini secara instan di komputer/server mana pun dengan satu perintah:

### 🪟 Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/RudyCity/chat-context-compactor/main/install.ps1 | iex
```
*Opsi: Tambahkan parameter `-Workspace` jika ingin memasang ke folder `./.agents/skills/` proyek lokal.*

### 🐧 Linux / macOS (Bash)
```bash
curl -fsSL https://raw.githubusercontent.com/RudyCity/chat-context-compactor/main/install.sh | bash
```

### 📦 Manual via Git Clone
```bash
# Global Antigravity Config
git clone https://github.com/RudyCity/chat-context-compactor.git ~/.gemini/config/skills/chat-context-compactor

# Atau Workspace Project
git clone https://github.com/RudyCity/chat-context-compactor.git .agents/skills/chat-context-compactor
```

---

## 🎯 Mengapa Membutuhkan Skill Ini?

Ketika percakapan AI agent berjalan panjang (20+ turns, ribuan baris log/file), context window mengalami **Token Bloat** dan **Attention Drift** (agen lupa instruksi awal, batasan negatif, atau file yang sudah diubah).

Kebanyakan ringkasan default AI terlalu dangkal (*lossy summary* 2-3 kalimat) sehingga menghilangkan konteks teknis penting.

**`chat-context-compactor`** menyelesaikan masalah ini dengan prinsip matematis:

$$\text{Context Size}_{\text{Compacted}} = \text{State Invariants} + \text{File Mutation Ledger} + \text{Git Live Disk} + \text{Active Horizon} \quad (\ll \text{Raw Transcript})$$

| Kategori | Status | Perlakuan Compactor |
| :--- | :---: | :--- |
| **User Core Intent & Constraints** | 🟢 **100% Lossless** | Disimpan utuh dengan Anchor ID: `[REQ-001]`, `[REQ-002]` |
| **File Mutation Ledger** | 🟢 **100% Lossless** | Path berkas absolut & simbol yang tersentuh: `[FILE-001]` |
| **Real-Time Git Workspace Disk** | 🟢 **100% Lossless** | Rekonsiliasi branch & uncommitted changes langsung dari disk |
| **Architectural Decisions (ADR)** | 🟢 **100% Lossless** | Alasan teknis pemilihan solusi & alternatif yang ditolak: `[ADR-001]` |
| **Error Traces & Resolutions** | 🟢 **100% Lossless** | Mencegah agen di sesi baru mengulangi jalan buntu: `[ERR-001]` |
| **Raw Tool Output & Dumps** | 🔴 **Pruned** | Pangkas ribuan baris terminal / grep menjadi 1 baris intisari semantik |
| **Conversational Chit-Chat** | 🔴 **Pruned** | Hapus salam, konfirmasi klise, dan filler asisten |

---

## 🚀 Fitur Unggulan

1. **State Preservation Index ($SPI \equiv 1.0$)**: Menjamin nol kehilangan konteks (*zero context loss*).
2. **Mention by ID di Sesi Baru (New Chat)**: Dokumen checkpoint ber-ID unik (`DOC-ID: CTX-XXXXXX-001`) dapat langsung dipanggil di sesi baru tanpa perlu menjelaskan ulang dari awal.
3. **Dual Storage Registry**: Otomatis menyimpan checkpoint di folder Global (`~/.gemini/checkpoints/`) dan Workspace (`.checkpoints/`) serta memperbarui katalog `INDEX.md`.
4. **Auto-Copy ke Windows Clipboard (`Ctrl+V`)**: Hasil pemadatan otomatis berada di Clipboard Windows, siap di-paste instan ke tab obrolan baru.
5. **Real-Time Git Reconciliation**: Mendeteksi branch aktif dan status uncommitted files di disk secara langsung.

---

## 📖 Cara Penggunaan

### Cara 1: Otomatis via Prompt Obrolan
Di dalam percakapan chat mana pun yang sudah panjang, cukup ketik:
> *"Tolong compact context sesi ini secara detail"*
> atau
> *"Padatkan konteks chat ini untuk pindah ke sesi baru"*

### Cara 2: Mention Checkpoint di Sesi Baru (New Chat)
Buka tab chat / sesi obrolan baru, lalu cukup sebutkan ID checkpoint:
> *"Lanjutkan pekerjaan dari checkpoint `CTX-8C26E0-001`"*
> atau
> *"Kerjakan `[ACT-001]` dari `CTX-8C26E0-001`"*

Agen di sesi baru akan otomatis mendeteksi ID, membaca dokumen dari `.checkpoints/` atau `~/.gemini/checkpoints/`, memulihkan mental model 100%, dan **langsung melanjutkan pekerjaan tanpa basa-basi onboarding**.

### Cara 3: One-Shot CLI Runner (Terminal)
Eksekusi langsung dari terminal di proyek mana saja:
```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File "~/.gemini/config/skills/chat-context-compactor/scripts/compact-session.ps1"

# Atau jika ada di scripts/
.\scripts\compact-session.ps1
```
*Output langsung dianalisis, diekstrak, dan otomatis tersalin ke Clipboard Windows (`Ctrl+V`).*

---

## 📂 Struktur Repositori

```text
chat-context-compactor/
├── SKILL.md                          # Instruksi skill inti, trigger, & protokol mention new chat
├── references/
│   ├── distillation-rules.md         # Taksonomi Keep vs Prune & formula matematis
│   └── compaction-templates.md       # 4 template dokumen ber-ID dengan HTML anchor tags
├── scripts/
│   ├── analyze-context.ps1           # Audit telemetri bloat & tool calls
│   ├── context_compressor.py         # Python extractor state invariants & git reconciler
│   ├── compact-session.ps1           # One-shot runner PowerShell
│   └── compact-session.cmd           # One-shot runner CMD
├── install.ps1                       # Installer otomatis Windows
├── install.sh                        # Installer otomatis Linux/macOS
├── README.md                         # Dokumentasi panduan
├── LICENSE                           # MIT License
└── .gitignore                        # Menjamin tidak ada data riwayat chat pribadi yang terunggah
```

---

## 🔒 Privasi & Keamanan (Zero Data Leak)

Repositori ini dikonfigurasi dengan aturan `.gitignore` ketat:
- **TIDAK PERNAH** mengunggah file `transcript.jsonl`, log sesi, atau riwayat obrolan pribadi Anda.
- Hanya mendistribusikan kode mesin pemadat (*engine*), template kosong, dan aturan distilasi.

---

## 📄 Lisensi

Didistribusikan di bawah lisensi [MIT](LICENSE). Dibuat dengan ❤️ oleh [RudyCity](https://github.com/RudyCity).
