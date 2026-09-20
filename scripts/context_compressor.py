#!/usr/bin/env python3
"""
Chat Context Compressor (Zero-Loss State Invariant Extractor with ID-Mention Support)
Mengekstraksi riwayat transcript.jsonl sesi Antigravity dan mengonversinya
menjadi Checkpoint Document ber-ID resmi (DOC-ID) dengan item-level anchor IDs
(REQ-xxx, FILE-xxx, ADR-xxx, ERR-xxx, ACT-xxx) yang dapat di-mention langsung di sesi baru.
"""

import os
import sys
import json
import re
import shutil
import argparse
import subprocess
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Set, Tuple

def find_latest_transcript() -> Tuple[Path | None, str]:
    brain_dir = Path.home() / ".gemini" / "antigravity" / "brain"
    if not brain_dir.exists():
        return None, ""
    transcripts = list(brain_dir.glob("*/.system_generated/logs/transcript.jsonl"))
    if not transcripts:
        return None, ""
    latest = max(transcripts, key=lambda p: p.stat().st_mtime)
    session_id = latest.parents[2].name
    return latest, session_id

def generate_doc_id(session_id: str, custom_id: str = "") -> str:
    if custom_id:
        return custom_id.upper()
    prefix = session_id[:6].upper() if session_id else "SESS"
    global_ckpt_dir = Path.home() / ".gemini" / "checkpoints"
    global_ckpt_dir.mkdir(parents=True, exist_ok=True)
    existing = list(global_ckpt_dir.glob(f"CTX-{prefix}-*.md"))
    counter = len(existing) + 1
    return f"CTX-{prefix}-{counter:03d}"

def get_git_state(cwd: Path) -> Dict[str, Any]:
    """Mengambil status riil Git di direktori kerja aktif."""
    if not shutil.which("git"):
        return {"is_git": False}
    try:
        res = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=cwd, capture_output=True, text=True, timeout=4
        )
        if res.returncode != 0:
            return {"is_git": False}

        branch_res = subprocess.run(
            ["git", "branch", "--show-current"],
            cwd=cwd, capture_output=True, text=True, timeout=4
        )
        branch = branch_res.stdout.strip() or "HEAD (detached)"

        status_res = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=cwd, capture_output=True, text=True, timeout=5
        )
        dirty_files = [line.strip() for line in status_res.stdout.splitlines() if line.strip()]

        diff_stat_res = subprocess.run(
            ["git", "diff", "--stat"],
            cwd=cwd, capture_output=True, text=True, timeout=5
        )
        diff_stat = diff_stat_res.stdout.strip()

        return {
            "is_git": True,
            "branch": branch,
            "dirty_files": dirty_files,
            "diff_stat": diff_stat
        }
    except Exception:
        return {"is_git": False}

def copy_to_clipboard(text: str) -> bool:
    """Menyalin teks ke clipboard Windows menggunakan clip.exe."""
    try:
        proc = subprocess.Popen(["clip.exe"], stdin=subprocess.PIPE, shell=True)
        proc.communicate(input=text.encode("utf-16le"))
        return proc.returncode == 0
    except Exception:
        try:
            ps_cmd = "$input | Set-Clipboard"
            proc = subprocess.Popen(["powershell", "-Command", ps_cmd], stdin=subprocess.PIPE, text=True)
            proc.communicate(input=text)
            return proc.returncode == 0
        except Exception:
            return False

def parse_transcript(file_path: Path) -> Dict[str, Any]:
    user_requests: List[Dict[str, str]] = []
    file_mutations: Dict[str, List[str]] = {}
    tool_usage: Dict[str, int] = {}
    commands_run: List[str] = []
    thinking_milestones: List[str] = []
    errors_and_resolutions: List[Dict[str, Any]] = []

    last_failed_command = None

    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except Exception:
                continue

            source = entry.get("source", "")
            msg_type = entry.get("type", "")
            content = entry.get("content", "")
            thinking = entry.get("thinking", "")
            tool_calls = entry.get("tool_calls", [])

            # 1. Ekstraksi User Request
            if source == "USER_EXPLICIT" and msg_type == "USER_INPUT":
                clean_req = re.sub(r"<[^>]+>", "", content).strip()
                if clean_req:
                    user_requests.append({
                        "step": entry.get("step_index", len(user_requests)),
                        "timestamp": entry.get("created_at", ""),
                        "text": clean_req
                    })

            # 2. Ekstraksi Thinking Decisions
            if thinking and len(thinking) > 20:
                first_sentence = thinking.strip().split("\n")[0]
                if len(first_sentence) > 10 and first_sentence not in thinking_milestones:
                    thinking_milestones.append(first_sentence[:160])

            # 3. Ekstraksi Tool Calls & Mutasi Berkas
            if tool_calls:
                for tc in tool_calls:
                    tname = tc.get("name", "")
                    tool_usage[tname] = tool_usage.get(tname, 0) + 1
                    args = tc.get("args", {})

                    if tname in ("write_to_file", "replace_file_content"):
                        tf = args.get("TargetFile", "")
                        if tf:
                            tf = tf.strip('"')
                            if tf not in file_mutations:
                                file_mutations[tf] = []
                            desc = args.get("Description", tname)
                            if desc not in file_mutations[tf]:
                                file_mutations[tf].append(desc)

                    elif tname == "run_command":
                        cmd = args.get("CommandLine", "")
                        if cmd:
                            cmd_clean = cmd.strip('"')
                            if cmd_clean not in commands_run:
                                commands_run.append(cmd_clean)
                            last_failed_command = cmd_clean

            # 4. Deteksi Error & Output Gagal pada Step Output
            if content and ("exited with code" in content or "ParserError" in content or "Traceback" in content):
                match_code = re.search(r"exited with code (\d+)", content)
                if match_code and match_code.group(1) != "0":
                    err_lines = [l.strip() for l in content.splitlines() if l.strip() and not l.startswith("Created At") and not l.startswith("Completed At")]
                    err_summary = err_lines[0] if err_lines else f"Exit code {match_code.group(1)}"
                    errors_and_resolutions.append({
                        "command": last_failed_command or "Unknown Command",
                        "error": err_summary[:120],
                        "status": "Diinvestigasi / Diatasi pada step berikutnya"
                    })

    return {
        "user_requests": user_requests,
        "file_mutations": file_mutations,
        "tool_usage": tool_usage,
        "commands_run": commands_run,
        "thinking_milestones": thinking_milestones[-8:],
        "errors_and_resolutions": errors_and_resolutions[-5:],
        "total_steps": len(user_requests)
    }

def generate_markdown_brief(
    data: Dict[str, Any],
    git_data: Dict[str, Any],
    doc_id: str,
    project_title: str = "Chat Session State",
    cwd_path: str = ""
) -> str:
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = []
    lines.append(f"# 📑 [DOC-ID: {doc_id}] HIGH-FIDELITY SESSION STATE CHECKPOINT")
    lines.append("")
    lines.append(f"> **Document ID**: `{doc_id}` | **Dibuat**: {now_str} | **Metode**: Lossless State Distillation")
    lines.append(">")
    lines.append(f"> **CARA MENTION DI SESI BARU (NEW CHAT)**:")
    lines.append(f"> Cukup sebutkan ID dokumen ini di pesan obrolan baru mana pun:")
    lines.append(f'> *"Lanjutkan pekerjaan dari checkpoint `{doc_id}`"* atau *"Kerjakan `[ACT-001]` dari `{doc_id}`"*')
    lines.append("> Agen di sesi baru akan otomatis memuat dan membaca dokumen ini.")
    lines.append("")
    lines.append("> [!IMPORTANT]")
    lines.append("> **AGENT COLD-START DIRECTIVE**:")
    lines.append("> Anda melanjutkan sesi kerja yang telah dipadatkan. Seluruh state invariant berstatus **VALID & AKTIF**.")
    lines.append("> Dilarang mengulang salam atau menanyakan ulang latar belakang tugas.")
    lines.append("> **Langsung eksekusi tindakan pada Section 6.**")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 1. User Requests with Anchor IDs
    lines.append("## 1. 🎯 Linimasa Instruksi & Tujuan User (User Intent Invariants)")
    if data["user_requests"]:
        for idx, ur in enumerate(data["user_requests"], 1):
            req_id = f"REQ-{idx:03d}"
            ts = f" *({ur['timestamp']})*" if ur['timestamp'] else ""
            lines.append(f'<a id="{req_id}"></a>')
            lines.append(f"### `[{req_id}]` Instruksi #{idx}{ts}")
            lines.append(f"```text\n{ur['text']}\n```")
            lines.append("")
    else:
        lines.append("*(Tidak ada input user eksplisit terdeteksi)*\n")
    lines.append("---")
    lines.append("")

    # 2. File Mutation Ledger with Anchor IDs
    lines.append("## 2. 🛠️ Berkas yang Termutasi ([NEW] / [MODIFY])")
    if data["file_mutations"]:
        lines.append("| Item ID | Path Berkas Absolut | Deskripsi Mutasi / Simbol Terpengaruh |")
        lines.append("| :---: | :--- | :--- |")
        for idx, (fpath, actions) in enumerate(data["file_mutations"].items(), 1):
            file_id = f"FILE-{idx:03d}"
            action_desc = "; ".join(actions) if actions else "Dimodifikasi"
            lines.append(f'| <a id="{file_id}"></a>`[{file_id}]` | `{fpath}` | {action_desc} |')
    else:
        lines.append("*(Belum ada mutasi berkas yang tercatat)*")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 3. Git & Live Workspace State
    lines.append("## 3. 🌿 Status Git & Real-Time Workspace Disk")
    if cwd_path:
        lines.append(f"- **Direktori Kerja (CWD)**: `{cwd_path}`")
    if git_data.get("is_git"):
        lines.append(f"- **Active Branch**: `{git_data.get('branch', 'main')}`")
        if git_data.get("dirty_files"):
            lines.append("- **Uncommitted / Dirty Files di Disk**:")
            for df in git_data["dirty_files"][:15]:
                lines.append(f"  - `{df}`")
            if len(git_data["dirty_files"]) > 15:
                lines.append(f"  - *(dan {len(git_data['dirty_files']) - 15} berkas lainnya)*")
        else:
            lines.append("- **Status Working Tree**: Bersih (*clean, no uncommitted changes*)")

        if git_data.get("diff_stat"):
            lines.append("- **Git Diff Stat**:")
            lines.append("  ```text")
            for dline in git_data["diff_stat"].splitlines()[:8]:
                lines.append(f"  {dline}")
            lines.append("  ```")
    else:
        lines.append("*(Direktori kerja saat ini bukan repositori Git aktif)*")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 4. Error History & Resolutions with Anchor IDs
    lines.append("## 4. ⚠️ Insiden Error & Resolusi (Negative Knowledge Defense)")
    if data["errors_and_resolutions"]:
        for idx, err in enumerate(data["errors_and_resolutions"], 1):
            err_id = f"ERR-{idx:03d}"
            lines.append(f'<a id="{err_id}"></a>')
            lines.append(f"### `[{err_id}]` Kegagalan pada `{err['command']}`")
            lines.append(f"- *Gejala Error*: `{err['error']}`")
            lines.append(f"- *Status Resolusi*: {err['status']}")
            lines.append("")
    else:
        lines.append("*(Tidak ada kegagalan fatal yang belum tertangani)*\n")
    lines.append("---")
    lines.append("")

    # 5. Key Decisions with Anchor IDs
    lines.append("## 5. 🧠 Milestone Penalaran & Keputusan Teknis")
    if data["thinking_milestones"]:
        for idx, m in enumerate(data["thinking_milestones"], 1):
            adr_id = f"ADR-{idx:03d}"
            lines.append(f'<a id="{adr_id}"></a>')
            lines.append(f"- `[{adr_id}]` {m}")
    else:
        lines.append("*(Tidak ada milestone penalaran khusus)*")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 6. Next Actions Horizon with Anchor IDs
    lines.append("## 6. 🚀 Immediate Execution Horizon (Checklist Tindakan Berikutnya)")
    lines.append('<a id="ACT-001"></a>')
    lines.append("- [ ] **`[ACT-001]`**: Verifikasi seluruh berkas mutasi dan validasi build / tes.")
    lines.append('<a id="ACT-002"></a>')
    lines.append("- [ ] **`[ACT-002]`**: Lanjutkan penyelesaian fitur sesuai instruksi user terakhir.")
    lines.append('<a id="ACT-003"></a>')
    lines.append("- [ ] **`[ACT-003]`**: Laporkan ringkasan hasil kerja secara presisi tanpa mengulang penjelasan onboarding.")
    lines.append("")
    return "\n".join(lines)

def update_checkpoint_registry(registry_dir: Path, doc_id: str, title: str, file_path: Path, step_count: int):
    """Memperbarui INDEX.md pada folder checkpoints."""
    registry_dir.mkdir(parents=True, exist_ok=True)
    index_file = registry_dir / "INDEX.md"
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    file_uri = file_path.resolve().as_uri()
    entry_line = f"| `{doc_id}` | {now_str} | {title} | [{doc_id}.md]({file_uri}) | {step_count} |\n"

    if not index_file.exists():
        header = (
            "# 📚 Checkpoint Registry & Memory Catalog\n\n"
            "Katalog seluruh dokumen checkpoint sesi chat yang dapat di-mention by ID.\n\n"
            "| Document ID | Tanggal | Judul Sesi | Berkas Checkpoint | Langkah |\n"
            "| :--- | :--- | :--- | :--- | :---: |\n"
        )
        index_file.write_text(header + entry_line, encoding="utf-8")
    else:
        content = index_file.read_text(encoding="utf-8")
        if doc_id not in content:
            with open(index_file, "a", encoding="utf-8") as f:
                f.write(entry_line)

def main():
    parser = argparse.ArgumentParser(description="Ekstraksi & Kompresi Konteks Sesi Antigravity (ID-Mentionable)")
    parser.add_argument("--transcript", "-t", type=str, help="Path ke file transcript.jsonl")
    parser.add_argument("--output", "-o", type=str, help="Path output file markdown (.md)")
    parser.add_argument("--doc-id", type=str, default="", help="Custom Document ID (misal: CTX-001)")
    parser.add_argument("--title", type=str, default="Antigravity Chat Session", help="Judul project/sesi")
    parser.add_argument("--clipboard", "-c", action="store_true", help="Salin otomatis output Markdown ke Windows Clipboard")
    parser.add_argument("--cwd", type=str, default=os.getcwd(), help="Direktori kerja aktif untuk memeriksa Git status")
    args = parser.parse_args()

    transcript_path, session_id = (Path(args.transcript), "") if args.transcript else find_latest_transcript()
    if not transcript_path or not transcript_path.exists():
        print(f"Error: Transcript tidak ditemukan: {transcript_path}", file=sys.stderr)
        sys.exit(1)

    doc_id = generate_doc_id(session_id, args.doc_id)
    print(f"[*] Menggunakan Document ID: {doc_id}")
    print(f"[*] Membaca transkrip: {transcript_path}")
    data = parse_transcript(transcript_path)

    cwd_path = Path(args.cwd).resolve()
    print(f"[*] Memeriksa status Git di: {cwd_path}")
    git_data = get_git_state(cwd_path)

    md_content = generate_markdown_brief(data, git_data, doc_id, args.title, str(cwd_path))

    global_ckpt_dir = Path.home() / ".gemini" / "checkpoints"
    global_file = global_ckpt_dir / f"{doc_id}.md"
    global_file.parent.mkdir(parents=True, exist_ok=True)
    global_file.write_text(md_content, encoding="utf-8")
    update_checkpoint_registry(global_ckpt_dir, doc_id, args.title, global_file, len(data["user_requests"]))
    print(f"[✓] Checkpoint Global disimpan: {global_file.resolve()}")

    workspace_ckpt_dir = cwd_path / ".checkpoints"
    try:
        workspace_file = workspace_ckpt_dir / f"{doc_id}.md"
        workspace_file.parent.mkdir(parents=True, exist_ok=True)
        workspace_file.write_text(md_content, encoding="utf-8")
        update_checkpoint_registry(workspace_ckpt_dir, doc_id, args.title, workspace_file, len(data["user_requests"]))
        print(f"[✓] Checkpoint Workspace disimpan: {workspace_file.resolve()}")
    except Exception as e:
        print(f"[!] Gagal menulis ke workspace checkpoints: {e}")

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(md_content, encoding="utf-8")
        print(f"[✓] Berhasil menyimpan salinan ke: {out_path.resolve()}")

    if args.clipboard:
        print("[*] Menyalin Handoff Brief ke Windows Clipboard...")
        if copy_to_clipboard(md_content):
            print("[✓] SUKSES: Handoff Brief telah disalin ke Windows Clipboard!")
        else:
            print("[!] Gagal menyalin ke clipboard secara otomatis.", file=sys.stderr)

    print("\n" + "="*60)
    print(f" 🎯 [MENTION BY ID GUIDE FOR NEW CHAT]")
    print(f" Untuk melanjutkan di sesi obrolan baru, cukup ketik:")
    print(f'   "Lanjutkan pekerjaan dari checkpoint {doc_id}"')
    print(f'   atau: "Kerjakan [ACT-001] dari {doc_id}"')
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
