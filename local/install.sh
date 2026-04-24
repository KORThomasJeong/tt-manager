#!/usr/bin/env bash
set -e

INSTALL_DIR="${HOME}/.local/bin"
BIN_NAME="tt"

# ── colors ───────────────────────────────────────────────
G=$'\e[1;32m'; Y=$'\e[1;33m'; R=$'\e[1;31m'; C=$'\e[1;36m'; D=$'\e[0m'

echo "${C}tt-manager 로컬 설치${D}"
echo "──────────────────────────────"

# ── check deps ───────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
    echo "${R}✗ tmux가 설치되어 있지 않습니다.${D}"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  macOS:         brew install tmux"
    exit 1
fi

# ── locate script dir ─────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_FILE="${SCRIPT_DIR}/tt-manager.zip"

if [ ! -f "$ZIP_FILE" ]; then
    echo "${R}✗ tt-manager.zip을 찾을 수 없습니다: ${ZIP_FILE}${D}"
    exit 1
fi

# ── extract & install ─────────────────────────────────────
mkdir -p "$INSTALL_DIR"
DEST="${INSTALL_DIR}/${BIN_NAME}"

if command -v unzip &>/dev/null; then
    unzip -oq "$ZIP_FILE" tt.sh -d "$INSTALL_DIR"
    mv "${INSTALL_DIR}/tt.sh" "$DEST"
elif command -v python3 &>/dev/null; then
    python3 -c "
import zipfile, os
z = zipfile.ZipFile('${ZIP_FILE}')
data = z.read('tt.sh')
z.close()
with open('${DEST}', 'wb') as f:
    f.write(data)
"
else
    echo "${R}✗ unzip 또는 python3가 필요합니다.${D}"
    exit 1
fi

chmod +x "$DEST"
echo "${G}✓ 설치 완료:${D} ${DEST}"

# ── PATH check ───────────────────────────────────────────
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "${Y}⚠ ${INSTALL_DIR}이 PATH에 없습니다.${D}"
    echo "  아래 줄을 ~/.bashrc 또는 ~/.zshrc에 추가하세요:"
    echo ""
    echo "  ${C}export PATH=\"\$HOME/.local/bin:\$PATH\"${D}"
    echo ""
    echo "  이후 적용:"
    echo "  ${C}source ~/.bashrc${D}  또는  ${C}source ~/.zshrc${D}"
else
    echo ""
    echo "  실행: ${C}tt${D}"
fi
