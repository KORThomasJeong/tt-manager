#!/usr/bin/env bash
set -e

RAW_URL="https://raw.githubusercontent.com/KORThomasJeong/tt-manager/main/tt.sh"
INSTALL_DIR="${HOME}/.local/bin"
BIN_NAME="tt"

# ── colors ───────────────────────────────────────────────
G=$'\e[1;32m'; Y=$'\e[1;33m'; R=$'\e[1;31m'; C=$'\e[1;36m'; D=$'\e[0m'

echo "${C}tt-manager installer${D}"
echo "──────────────────────────────"

# ── check deps ───────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
    echo "${R}✗ tmux가 설치되어 있지 않습니다.${D}"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  macOS:         brew install tmux"
    exit 1
fi

if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    echo "${R}✗ curl 또는 wget이 필요합니다.${D}"
    exit 1
fi

# ── download ──────────────────────────────────────────────
mkdir -p "$INSTALL_DIR"
DEST="${INSTALL_DIR}/${BIN_NAME}"

echo "${Y}▸ 다운로드 중...${D} ${RAW_URL}"
if command -v curl &>/dev/null; then
    curl -fsSL "$RAW_URL" -o "$DEST"
else
    wget -qO "$DEST" "$RAW_URL"
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
