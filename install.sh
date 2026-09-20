#!/usr/bin/env bash
# Universal Bash Installer for 'chat-context-compactor' AI Skill
set -e

REPO_URL="https://github.com/RudyCity/chat-context-compactor.git"
SKILL_NAME="chat-context-compactor"

echo "=========================================================="
echo " 🧠 CHAT CONTEXT COMPACTOR - UNIVERSAL SKILL INSTALLER    "
echo "=========================================================="

if [[ "$1" == "--workspace" ]]; then
    TARGET_DIR="$(pwd)/.agents/skills/$SKILL_NAME"
    echo "[*] Target Mode: Workspace Installation"
else
    TARGET_DIR="$HOME/.gemini/config/skills/$SKILL_NAME"
    echo "[*] Target Mode: Global Configuration (~/.gemini/config/skills/)"
fi

echo "[*] Target Directory: $TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR" ]]; then
    echo "[!] Directory already exists. Pulling latest updates..."
    if [[ -d "$TARGET_DIR/.git" ]]; then
        git -C "$TARGET_DIR" pull origin main
    else
        rm -rf "$TARGET_DIR"
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
else
    echo "[*] Cloning repository from GitHub: $REPO_URL ..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi

if [[ -f "$TARGET_DIR/SKILL.md" ]]; then
    echo ""
    echo "=========================================================="
    echo " [OK] INSTALLATION SUCCESSFUL!"
    echo " Skill 'chat-context-compactor' is ready to use."
    echo "=========================================================="
    echo ""
else
    echo "[ERROR] Verification failed: SKILL.md not found." >&2
    exit 1
fi
