# 📑 Canonical Compaction Templates (with Mentionable IDs)

Dokumen ini menyediakan 4 template standar ber-ID untuk memadatkan konteks sesi chat.

---

## Template 1: ID-Mentionable Session Checkpoint Document

*Format dokumen standar ber-ID yang disimpan di `.checkpoints/<DOC-ID>.md` dan `~/.gemini/checkpoints/<DOC-ID>.md`.*

```markdown
# 📑 [DOC-ID: CTX-XXXXXX-001] HIGH-FIDELITY SESSION STATE CHECKPOINT

> **Document ID**: `CTX-XXXXXX-001` | **Metode**: Lossless State Distillation
>
> **CARA MENTION DI SESI BARU (NEW CHAT)**:
> Cukup sebutkan ID dokumen ini di pesan obrolan baru mana pun:
> *"Lanjutkan pekerjaan dari checkpoint `CTX-XXXXXX-001`"* atau *"Kerjakan `[ACT-001]` dari `CTX-XXXXXX-001`"*
> Agen di sesi baru akan otomatis memuat dan membaca dokumen ini.

> [!IMPORTANT]
> **AGENT COLD-START DIRECTIVE**:
> Anda melanjutkan sesi kerja yang telah dipadatkan. Seluruh state invariant berstatus **VALID & AKTIF**.
> Dilarang mengulang salam atau menanyakan ulang latar belakang tugas.
> **Langsung eksekusi tindakan pada Section 6.**

---

## 1. 🎯 Linimasa Instruksi & Tujuan User (User Intent Invariants)
<a id="REQ-001"></a>
### `[REQ-001]` Instruksi #1
```text
[Permintaan pertama pengguna]
```

<a id="REQ-002"></a>
### `[REQ-002]` Instruksi #2
```text
[Koreksi atau batasan khusus pengguna]
```

---

## 2. 🛠️ Berkas yang Termutasi ([NEW] / [MODIFY])
| Item ID | Path Berkas Absolut | Deskripsi Mutasi / Simbol Terpengaruh |
| :---: | :--- | :--- |
| <a id="FILE-001"></a>`[FILE-001]` | `g:/project/app/src/services/api.ts` | Service baru untuk mengambil data dengan retry |
| <a id="FILE-002"></a>`[FILE-002]` | `g:/project/app/src/components/Table.tsx` | Menambahkan sorting kolom tanggal & pagination |

---

## 3. 🌿 Status Git & Real-Time Workspace Disk
- **Direktori Kerja (CWD)**: `[Path absolut]`
- **Active Branch**: `master`
- **Status Working Tree**: `[Clean atau daftar dirty files]`

---

## 4. ⚠️ Insiden Error & Resolusi (Negative Knowledge Defense)
<a id="ERR-001"></a>
### `[ERR-001]` Kegagalan pada `[Command / Action]`
- *Gejala Error*: `[Pesan error]`
- *Status Resolusi*: Diatasi pada langkah berikutnya dengan cara [solusi].

---

## 5. 🧠 Milestone Penalaran & Keputusan Teknis
<a id="ADR-001"></a>
- `[ADR-001]` [Keputusan teknis yang diambil dan alasannya]
<a id="ADR-002"></a>
- `[ADR-002]` [Pendekatan alternatif yang ditolak dan alasannya]

---

## 6. 🚀 Immediate Execution Horizon (Checklist Tindakan Berikutnya)
<a id="ACT-001"></a>
- [ ] **`[ACT-001]`**: [Tugas pertama yang harus langsung dikerjakan agen baru]
<a id="ACT-002"></a>
- [ ] **`[ACT-002]`**: [Tugas kedua]
<a id="ACT-003"></a>
- [ ] **`[ACT-003]`**: [Verifikasi dan pengujian]
```

---

## Template 2: Inline Working Memory Ledger

*Gunakan template ini di dalam sesi yang sedang berjalan ketika obrolan telah melewati banyak turn dan agen memerlukan penyegaran memori internal agar tidak terjadi attention drift.*

```markdown
---
### 🧠 WORKING MEMORY LEDGER (Session Turn: [TurnCount])
*Konteks aktif disegarkan untuk menjaga fokus dan mencegah degradasi perhatian:*

- **Target Aktif**: [Fokus tugas yang sedang diselesaikan pada giliran ini]
- **File Kunci Terkait**:
  - `[Path absolut file 1]` (status: sudah dimodifikasi)
  - `[Path absolut file 2]` (status: target berikutnya)
- **Batasan Kritis**: [Batasan penting yang tidak boleh dilanggar]
- **Status Sisa Pekerjaan**:
  - [x] [Tugas yang sudah selesai]
  - [ ] **[TUGAS SAAT INI]**: [Aksi yang sedang dieksekusi]
  - [ ] [Tugas berikutnya]
---
```

---

## Template 3: Subagent Dispatch Briefing

*Gunakan template ini ketika memanggil subagent via `invoke_subagent`. Memberikan subagent semua informasi lingkungan tanpa membebani context window-nya.*

```markdown
# SUBAGENT TASK BRIEFING: [Nama Modul / Sub-Tugas]

## Konteks Global & Arsitektur
- **Workspace**: `[Path absolut]`
- **Tumpukan Teknologi**: `[Stack]`
- **Tujuan Sesi Utama**: `[1-2 kalimat tujuan besar]`

## Tanggung Jawab Spesifik Subagent
Anda ditugaskan secara eksklusif untuk menyelesaikan:
`[Deskripsi detail tugas subagent]`

## Batasan & Kontrak Antarmuka (Constraints)
- Wajib mematuhi file antarmuka yang ada di `[Path absolut ke types/interface]`.
- Dilarang memodifikasi file di luar direktori `[Folder spesifik]`.
- Rule sistem: [e.g. Gunakan format async/await, jangan gunakan any di TypeScript].

## Berkas yang Relevan (Target Files)
1. `[Path absolut file target 1]` — [Peran file ini]
2. `[Path absolut file target 2]` — [Peran file ini]

## Output yang Diharapkan
Kembalikan laporan ringkas yang mencakup:
1. File yang dibuat/dimodifikasi.
2. Hasil verifikasi / build / tes.
3. Potensi dampak ke modul lain.
```

---

## Template 4: Incident & Deep Debugging Checkpoint

*Gunakan template ini saat menyelesaikan bug pelik yang melibatkan beberapa file atau eksperimen berulang.*

```markdown
# 🔍 INCIDENT & DEBUGGING CHECKPOINT

## 1. Gejala & Anomali (Symptom)
- **Deskripsi Bug**: [Apa yang rusak / tidak sesuai ekspektasi]
- **Langkah Reproduksi**: [Command atau aksi pemicu bug]
- **Log Error Inti**:
  ```text
  [Cuplikan 3-5 baris error stack trace terpenting]
  ```

## 2. Matriks Eksperimen & Eliminasi Hipotesis
| No | Hipotesis yang Diuji | Aksi / Modifikasi | Hasil | Status |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Masalah CORS di backend | Menambahkan header wildcard di proxy | Error tetap muncul | ❌ Dieliminasi |
| 2 | Mismatch tipe data ID (string vs number) | Mengubah DTO parser ke number | Payload terurai sukses tapi DB tolak | ❌ Dieliminasi |
| 3 | Middleware autentikasi tidak menerima Bearer prefix | Memotong prefix "Bearer " | Request tembus ke controller | ✅ Berhasil |

## 3. Akar Masalah Terkonfirmasi (Confirmed Root Cause)
[Penjelasan teknis penyebab utama masalah]

## 4. Tindakan Perbaikan Permanen (Fix Plan)
- [ ] Patch `[Path absolut file]` pada baris [N]
- [ ] Tambahkan unit test untuk mencegah regresi di `[Path absolut test file]`
- [ ] Verifikasi ulang eksekusi dengan `[Command test]`
```
