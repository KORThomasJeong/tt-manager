#!/bin/bash

# ── colors ──────────────────────────────────────────────
BOLD='\e[1m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
GREEN='\e[1;32m'
DIM='\e[2m'
RESET='\e[0m'

# ── display helpers ──────────────────────────────────────
draw_box_top()    { echo -e "${CYAN}╔══════════════════════════════════╗${RESET}"; }
draw_box_mid()    { echo -e "${CYAN}╠══════════════════════════════════╣${RESET}"; }
draw_box_bottom() { echo -e "${CYAN}╚══════════════════════════════════╝${RESET}"; }
draw_row() {
    local text="$1"
    printf "${CYAN}║${RESET}  %-32s${CYAN}║${RESET}\n" "$text"
}
