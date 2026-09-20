#!/usr/bin/env bash
# Universal Bash Installer untuk Skill 'chat-context-compactor'
set -e

REPO_URL="https://github.com/RudyCity/chat-context-compactor.git"
SKILL_NAME="chat-context-compactor"

echo "=========================================================="
echo " 🧠 CHAT CONTEXT COMPACTOR - UNIVERSAL SKILL INSTALLER    "
echo "=========================================================="

if [[ "$1" == "--workspace" ]]; then
    TARGET_DIR="$(pwd)/.agents/skills/$SKILL_NAME"
    echo "[*] Mode: Workspace Installation"
else
    TARGET_DIR="$HOME/.gemini/config/skills/$SKILL_NAME"
    echo "[*] Mode: Global Configuration (~/.gemini/config/skills/)"
fi

echo "[*] Target Direktori: $TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR" ]]; then
    echo "[!] Direktori sudah ada. Memperbarui berkas..."
    if [[ -d "$TARGET_DIR/.git" ]]; then
        git -C "$TARGET_DIR" pull origin main
    else
        rm -rf "$TARGET_DIR"
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
else
    echo "[*] Mengunduh repository dari GitHub: $REPO_URL ..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi

if [[ -f "$TARGET_DIR/SKILL.md" ]]; then
    echo ""
    echo "=========================================================="
    echo " [OK] INSTALASI BERHASIL!"
    echo " Skill 'chat-context-compactor' siap digunakan."
    echo "=========================================================="
    echo ""
else
    echo "[ERROR] Verifikasi instalasi gagal. SKILL.md tidak ditemukan." >&2
    exit 1
fi
