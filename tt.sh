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

# ── mouse setup ──────────────────────────────────────────
setup_mouse() {
    local conf="$HOME/.tmux.conf"
    if ! grep -qxF 'set -g mouse on' "$conf" 2>/dev/null; then
        printf 'set -g mouse on\n' >> "$conf"
    fi
    if [ -n "$TMUX" ]; then
        tmux source-file "$conf"
    fi
}

# ── session data ─────────────────────────────────────────
get_sessions() {
    tmux list-sessions -F "#{session_name} #{session_windows}" 2>/dev/null
}

# ── main list UI ─────────────────────────────────────────
SESSION_NAMES=()

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
        draw_row "${YELLOW}${i})${RESET} $(printf '%-14.14s' "$name") ${DIM}(${win_label})${RESET}"
        i=$(( i + 1 ))
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
    local name="$1" confirm
    printf "\n"
    read -rp "Kill '${name}'? (y/n): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        tmux kill-session -t "$name"
        printf "${RED}Session '%s' killed.${RESET}\n" "$name"
        sleep 0.8
    fi
}

do_rename() {
    local old_name="$1" new_name
    printf "\n"
    read -rp "New name for '${old_name}': " new_name
    if [ -z "$new_name" ]; then
        return 1
    fi
    if tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -qx "$new_name"; then
        printf "${RED}Session '%s' already exists.${RESET}\n" "$new_name"
        sleep 1
        return 1
    fi
    tmux rename-session -t "$old_name" "$new_name"
    printf "${GREEN}Renamed to '%s'.${RESET}\n" "$new_name"
    sleep 0.8
}

new_session() {
    local name yn
    clear
    read -rp "Session name: " name
    if [ -z "$name" ]; then
        return 1
    fi
    if tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -qx "$name"; then
        printf "${YELLOW}Session '%s' already exists.${RESET}\n" "$name"
        read -rp "Attach to it? (y/n): " yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            do_attach "$name"
            return 0
        fi
        return 1
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

    while true; do
        show_list
        printf "\n"
        printf "  ${BOLD}Session: ${CYAN}%s${RESET}\n" "$session_name"
        printf "  ${YELLOW}a)${RESET} attach   ${RED}k)${RESET} kill   ${GREEN}r)${RESET} rename   ${DIM}b) back${RESET}\n"

        local act
        read -rp $'\nAction: ' act
        case "$act" in
            a|A) do_attach "$session_name"; return ;;
            k|K) do_kill "$session_name";   return ;;
            r|R)
                if do_rename "$session_name"; then
                    return
                fi
                ;;
            b|B) return ;;
            *) ;;
        esac
    done
}

# ── main loop ────────────────────────────────────────────
main() {
    while true; do
        local sessions_raw
        sessions_raw=$(get_sessions)

        if [ -z "$sessions_raw" ]; then
            clear
            printf "${YELLOW}No tmux sessions found.${RESET}\n"
            local yn
            read -rp "Create a new session? (y/n): " yn
            if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
                new_session
            fi
            return
        fi

        show_list
        local count=${#SESSION_NAMES[@]}

        local choice
        read -rp $'\nSelect: ' choice
        case "$choice" in
            q|Q) clear; return ;;
            n|N)
                if new_session; then
                    return
                fi
                ;;
            ''|*[!0-9]*) ;;
            *)
                if (( choice >= 1 && choice <= count )); then
                    action_menu "${SESSION_NAMES[$((choice-1))]}"
                fi
                ;;
        esac
    done
}

setup_mouse
main
