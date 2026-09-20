# 📏 Distillation Rules & Taksonomi Retensi Presisi (Zero Context-Loss)

Dokumen ini mendefinisikan aturan ketat untuk membedakan antara informasi yang **WAJIB DIPERTAHANKAN 100% (Lossless Invariants)** dan informasi yang **WAJIB DIPANGKAS (Ephemeral Noise)** agar menghasilkan pemadatan konteks yang detail tanpa kehilangan esensi obrolan.

---

## 1. Taksonomi Retensi (Keep vs Prune Matrix)

| Kategori Elemen | Status Retensi | Alasan & Bentuk Representasi yang Benar |
| :--- | :---: | :--- |
| **Pernyataan Tujuan User (Initial Request)** | 🟢 **WAJIB (100%)** | Menentukan kompas utama proyek. Tulis verbatim atau parafrase presisi tinggi. |
| **Koreksi & Batasan Khusus User** | 🟢 **WAJIB (100%)** | Batasan negatif ("jangan gunakan library X", "wajib pakai bahasa Y", "gunakan `;` pengganti `&&`"). Kehilangan batasan ini menyebabkan agen mengulangi kesalahan. |
| **File Mutation History** | 🟢 **WAJIB (100%)** | Daftar file yang dibuat `[NEW]`, diubah `[MODIFY]`, atau dihapus `[DELETE]` beserta nama fungsi/komponen yang tersentuh. |
| **Architectural Decisions (ADR)** | 🟢 **WAJIB (100%)** | Pilihan arsitektural (misal: memilih SQLite WAL daripada Memory DB karena persistensi, memilih regex over parser). |
| **Discarded Hypotheses & Dead Ends** | 🟢 **WAJIB (100%)** | Solusi yang sudah terbukti gagal beserta alasannya. Tanpa ini, sesi baru akan mengulang eksperimen yang sama. |
| **Active Unresolved Bugs & Stack Traces** | 🟢 **WAJIB (100%)** | Pesan error spesifik, kode baris yang gagal, dan hipotesis akar masalah yang sedang diinvestigasi. |
| **Environment State & Credentials Topology** | 🟢 **WAJIB (100%)** | Port aktif, URL endpoint lokal/staging, konfigurasi OS, nama database (sanitasi secret/token). |
| **Next Action Checklist** | 🟢 **WAJIB (100%)** | 1–5 langkah tindakan konkret berikutnya yang harus segera dikerjakan. |
| **Raw Tool Output (View File, Terminal Logs)** | 🔴 **PANGKAS (100%)** | Ribuan baris kode atau log terminal. Ganti dengan intisari 1 baris semantik (misal: `build sukses dalam 4.2s`, `file berisi 120 baris dengan 4 class`). |
| **Duplicate Content Reads** | 🔴 **PANGKAS (100%)** | Membaca file yang sama berkali-kali tanpa perubahan. Cukup catat state akhir file tersebut. |
| **Intermediate Conversational Fluff** | 🔴 **PANGKAS (100%)** | "Baik, saya mengerti", "Tentu, mari kita mulai", "Mohon tunggu sebentar". |
| **Trial-and-Error Syntax Churn** | 🔴 **PANGKAS (100%)** | 5 kali percobaan memperbaiki typo/lint error kecil. Cukup catat status akhir bahwa file sudah lolos linter. |

---

## 2. Formulasi Teoretis Distilasi Konteks

### State Preservation Index ($SPI$)
Tolak ukur kelayakan compacting adalah $SPI \equiv 1.0$ (100% Invariants Retained):

$$SPI = \frac{\sum \text{Invariant Tokens yang Dipertahankan}}{\sum \text{Total Invariant Tokens Kritis dalam Sesi}} = 1.0$$

Jika ada file mutasi yang terlupakan, atau batasan user yang terhapus, maka $SPI < 1.0$ (GAGAL: terjadi *context loss*).

### Token Compression Ratio ($CR$)
Target pemangkasan token tanpa mengorbankan $SPI$:

$$CR = 1 - \frac{T_{\text{compact}}}{T_{\text{raw}}} \ge 0.80 \quad (\text{Target: 80\% – 92\% kompresi})$$

---

## 3. Teknik Transformasi: Dari Noise Menjadi Invariant Tuple

### Contoh 1: Eksekusi Perintah Terminal / Run Command
- ❌ **Mentah (Noise - 150 baris)**:
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
- ✅ **Terdistilasi (Lossless Invariant - 2 baris)**:
  - `Dependency Added`: `@tanstack/react-query` terpasang (0 vulnerabilities).
  - `Build Status`: Vite build sukses (`dist/assets/index-Cz4Wk32Q.js` ~142 kB).

### Contoh 2: Investigasi & Pembacaan File (View File)
- ❌ **Mentah (Noise - 80 baris kode utuh)**:
  Membaca seluruh isi `src/auth/jwt.ts` hanya untuk mengecek nama fungsi verifikasi token.
- ✅ **Terdistilasi (Lossless Invariant - 1 baris)**:
  - `src/auth/jwt.ts`: Menggunakan fungsi `verifyToken(token: string, secret: string): JwtPayload` dengan algoritma `HS256`.

### Contoh 3: Percobaan Perbaikan Bug (Debugging Trial)
- ❌ **Mentah (Noise - 6 giliran chat mencoba-coba)**:
  Percobaan 1 ubah A gagal dengan error `Cannot read property of undefined`. Percobaan 2 ubah B gagal dengan `TypeError`. Percobaan 3 berhasil dengan null-coalescing.
- ✅ **Terdistilasi (Lossless Invariant - 2 baris)**:
  - `Bug Fixed`: Null reference pada `user.profile.avatar` saat first-time login.
  - `Root Cause & Fix`: Profile belum terbentuk di database. Diatasi dengan optional chaining `user?.profile?.avatar ?? DEFAULT_AVATAR` di `UserProfileCard.tsx#L32`.

---

## 4. Perlindungan Data Sensitif (Secret Sanitization)

Saat memadatkan konteks sesi, rahasia sistem dan kredensial wajib disanitasi:
- `API Keys`: `sk-proj-abc...123` $\to$ `[STORED_IN_ENV: OPENAI_API_KEY]`
- `Passwords`: `admin12345` $\to$ `[REDACTED_PASSWORD]`
- `JWT Tokens`: `eyJhbGciOiJIUz...` $\to$ `[VALID_SESSION_JWT_TOKEN]`
- Path folder pribadi yang mengandung identitas pribadi disederhanakan dengan placeholder kanonikal (misal: `C:\Users\USER\...`).

---

## 5. Algoritma Rekonstruksi State (Mental Model Sesi Baru)

Sesi baru yang menerima hasil pemadatan harus dapat membentuk mental model lengkap dalam 1 kali pembacaan:

1. **WHERE WE ARE**: Lokasi repo, branch/workspace, dan tujuan besar.
2. **WHAT WAS DONE**: Rekapitulasi setiap file yang dimodifikasi beserta alasan logisnya.
3. **WHY IT WAS DONE**: Pilihan desain yang telah disepakati dan dilarang diutak-atik.
4. **WHAT IS BROKEN / PENDING**: Masalah yang belum tuntas dan checklist yang menunggu dieksekusi.
5. **WHAT IS NEXT**: Instruksi persis giliran pertama yang harus dikerjakan agen baru.
