#!/bin/bash

# ── colors ───────────────────────────────────────────────
CYAN=$'\e[1;36m'
YELLOW=$'\e[1;33m'
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
RESET=$'\e[0m'

# ── display helpers ──────────────────────────────────────
draw_box_top()    { printf "${CYAN}╔══════════════════════════════════╗${RESET}\n"; }
draw_box_mid()    { printf "${CYAN}╠══════════════════════════════════╣${RESET}\n"; }
draw_box_bottom() { printf "${CYAN}╚══════════════════════════════════╝${RESET}\n"; }

draw_row() {
    local text="$1"
    local plain
    plain=$(printf '%s' "$text" | sed 's/\x1b\[[0-9;]*[mK]//g')
    local vlen=${#plain}
    local pad=$(( 32 - vlen ))
    (( pad < 0 )) && pad=0
    printf "${CYAN}║${RESET}  %s%*s${CYAN}║${RESET}\n" "$text" "$pad" ""
}

# ── session data ─────────────────────────────────────────
get_sessions() {
    tmux list-sessions -F "#{session_name} #{session_windows}" 2>/dev/null
}

# ── main list UI ─────────────────────────────────────────
show_list() {
    clear
    draw_box_top
    draw_row "${BOLD}tmux sessions${RESET}"
    draw_box_mid

    local i=1
    SESSION_NAMES=()
    while IFS= read -r line; do
        local name windows win_label
        name=$(awk '{print $1}' <<< "$line")
        windows=$(awk '{print $2}' <<< "$line")
        [ "$windows" -eq 1 ] && win_label="1 window" || win_label="${windows} windows"
        SESSION_NAMES+=("$name")
        draw_row "${YELLOW}${i})${RESET} $(printf '%-14s' "$name") ${DIM}(${win_label})${RESET}"
        (( i++ ))
    done < <(get_sessions)

    draw_box_mid
    draw_row "${GREEN}n)${RESET} new session"
    draw_row "${DIM}q) quit${RESET}"
    draw_box_bottom
}

# ── actions ──────────────────────────────────────────────
do_attach() {
    local name="$1"
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$name"
    else
        tmux attach-session -t "$name"
    fi
}

do_kill() {
    local name="$1"
    printf "\n"
    read -rp "Kill '${name}'? (y/n): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        tmux kill-session -t "$name"
        printf "${RED}Session '%s' killed.${RESET}\n" "$name"
        sleep 0.8
        main
    else
        action_menu "$name"
    fi
}

do_rename() {
    local old_name="$1"
    printf "\n"
    read -rp "New name for '${old_name}': " new_name
    if [ -z "$new_name" ]; then
        action_menu "$old_name"
        return
    fi
    if tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -qx "$new_name"; then
        printf "${RED}Session '%s' already exists.${RESET}\n" "$new_name"
        sleep 1
        action_menu "$old_name"
        return
    fi
    tmux rename-session -t "$old_name" "$new_name"
    printf "${GREEN}Renamed to '%s'.${RESET}\n" "$new_name"
    sleep 0.8
    main
}

new_session() {
    clear
    read -rp "Session name: " name
    if [ -z "$name" ]; then
        main
        return
    fi
    if tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -qx "$name"; then
        printf "${YELLOW}Session '%s' already exists.${RESET}\n" "$name"
        read -rp "Attach to it? (y/n): " yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            do_attach "$name"
        else
            main
        fi
        return
    fi
    if [ -n "$TMUX" ]; then
        tmux new-session -d -s "$name"
        tmux switch-client -t "$name"
    else
        tmux new-session -s "$name"
    fi
}

# ── action menu ──────────────────────────────────────────
action_menu() {
    local session_name="$1"
    show_list
    printf "\n"
    printf "  ${BOLD}Session: ${CYAN}%s${RESET}\n" "$session_name"
    printf "  ${YELLOW}a)${RESET} attach   ${RED}k)${RESET} kill   ${GREEN}r)${RESET} rename   ${DIM}b) back${RESET}\n"

    while true; do
        read -rp $'\nAction: ' act
        case "$act" in
            a|A) do_attach "$session_name"; return ;;
            k|K) do_kill   "$session_name"; return ;;
            r|R) do_rename "$session_name"; return ;;
            b|B) main;                      return ;;
            *)   continue ;;
        esac
    done
}

# ── main loop ────────────────────────────────────────────
main() {
    local sessions_raw
    sessions_raw=$(get_sessions)

    if [ -z "$sessions_raw" ]; then
        clear
        printf "${YELLOW}No tmux sessions found.${RESET}\n"
        read -rp "Create a new session? (y/n): " yn
        [ "$yn" = "y" ] || [ "$yn" = "Y" ] && new_session
        return
    fi

    show_list
    local count=${#SESSION_NAMES[@]}

    while true; do
        read -rp $'\nSelect: ' choice
        case "$choice" in
            q|Q) clear; return ;;
            n|N) new_session; return ;;
            ''|*[!0-9]*) continue ;;
        esac
        if (( choice >= 1 && choice <= count )); then
            action_menu "${SESSION_NAMES[$((choice-1))]}"
            return
        fi
    done
}

main
