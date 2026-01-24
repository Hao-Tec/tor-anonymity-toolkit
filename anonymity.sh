#!/bin/bash

# Constants
TOR_SERVICE="tor.service"
NEWNYM_TIMER="tor-newnym.timer"
CONTROL_PORT=9051
AUTH_PASSWORD="ACILAB"  # Change this to your actual control port password
TOR_SOCKS="127.0.0.1:9050"

# Colors
if [[ -n "${NO_COLOR:-}" ]]; then
  RED=''
  GREEN=''
  CYAN=''
  YELLOW=''
  RESET=''
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;33m'
  RESET='\033[0m'
fi

# Default Configuration (can be overridden by .anonymity.conf)
AUTH_PASSWORD="${AUTH_PASSWORD:-ACILAB}"
ENABLE_NOTIF="${ENABLE_NOTIF:-0}"  # Set to 1 to enable desktop notifications
TOR_SOCKS="127.0.0.1:9050"
LOGFILE="$HOME/.tor_anonymity.log"

# Optional config override
CONFIG_FILE="$HOME/.anonymity.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo -e "${YELLOW}⚠ No config file found. Creating default ~/.anonymity.conf...${RESET}"

  # Security: Create file with restricted permissions atomically using umask
  (
    umask 077
    cat > "$CONFIG_FILE" <<EOF
# Configuration for anonymity.sh

# Control port password for Tor (used in NEWNYM command)
AUTH_PASSWORD="ACILAB"

# Enable desktop notifications? (1 = yes, 0 = no)
ENABLE_NOTIF=1

# Optional: Choose interface theme (light/dark)
THEME="dark"
EOF
  )
  echo -e "${GREEN}✅ Default config created. You can edit it at ~/.anonymity.conf${RESET}"
fi

echo -e "${CYAN}🔧 Loading config from $CONFIG_FILE...${RESET}"
source "$CONFIG_FILE"

# Runtime overrides (e.g., --debug, --theme=dark)
for arg in "$@"; do
  case "$arg" in
    --debug) DEBUG_MODE=1 ;;
    --theme=light) THEME="light" ;;
    --theme=dark) THEME="dark" ;;
  esac
done

# Theme-aware color definitions
if [[ -n "${NO_COLOR:-}" ]]; then
  # NO_COLOR set, keep colors disabled
  :
elif [[ "$THEME" == "light" ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  YELLOW='\033[0;33m'
  RESET='\033[0m'
else
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  CYAN='\033[1;36m'
  YELLOW='\033[1;33m'
  RESET='\033[0m'
fi

# Ensure user systemd is running (for desktop session)
# Optimization: Use $EUID builtin instead of $(id -u) subshell
export XDG_RUNTIME_DIR="/run/user/${EUID}"

# Log file path
LOGFILE="$HOME/.tor_anonymity.log"

# Security: Ensure log file has restricted permissions
if [[ ! -f "$LOGFILE" ]]; then
  (
    umask 077
    touch "$LOGFILE"
  )
else
  # Ensure existing log file is secure
  current_perms=$(stat -c "%a" "$LOGFILE" 2>/dev/null)
  if [[ "$current_perms" != "600" ]]; then
    chmod 600 "$LOGFILE"
  fi
fi

function send_notification() {
  if [[ "$ENABLE_NOTIF" == "1" ]] && command -v notify-send &>/dev/null; then
    notify-send "ℹ  Tor Anonymity Alert" "$1"
    echo "🔔 Notification sent: $1"
  else
    echo "⚠️ Notification skipped: notify-send unavailable or ENABLE_NOTIF=$ENABLE_NOTIF"
  fi
}

function append_log() {
  local timestamp ip_tor ip_real status
  # Optimization: Use printf builtin (Bash 4.2+) instead of forking 'date'
  printf -v timestamp '%(%Y-%m-%d %H:%M:%S)T' -1
  ip_tor="$1"
  ip_real="$2"
  status="$3"
  echo "$timestamp | Tor IP: $ip_tor | Real IP: $ip_real | Status: $status" >> "$LOGFILE"
}

function debug_log() {
  if [[ $DEBUG_MODE -eq 1 ]]; then
    echo -e "${CYAN}DEBUG:${RESET} $1"
  fi
}

function spinner() {
  local pid=$1
  local spinstr='|/-\'
  # Hide cursor if tput is available
  command -v tput &>/dev/null && tput civis

  while kill -0 "$pid" 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c] " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep 0.1
    printf "\b\b\b\b\b"
  done
  printf "     \b\b\b\b\b"

  # Restore cursor
  command -v tput &>/dev/null && tput cnorm
}

function check_dependencies() {
  local missing=0
  # Optimization: Removed expect and telnet dependencies as they are no longer needed
  for cmd in systemctl curl nc; do
    if ! command -v $cmd &>/dev/null; then
      echo -e "${RED}Error: Required command '$cmd' is not installed.${RESET}"
      echo -e "Please install it using: ${YELLOW}sudo apt install $cmd${RESET}"
      missing=1
    fi
  done
  if [[ $missing -eq 1 ]]; then
    exit 1
  fi
}

function check_tor_status() {
  echo -e "${CYAN}Checking if Tor traffic is active...${RESET}"

  if nc -z -w3 127.0.0.1 9050; then
    echo "Tor SOCKS proxy is reachable at $TOR_SOCKS"

    IP_CHECKERS=(
      "https://ident.me"
      "https://ifconfig.me/ip"
      "https://icanhazip.com"
      "https://checkip.amazonaws.com"
    )

    TOR_IP=""
    for url in "${IP_CHECKERS[@]}"; do
      # Extract hostname for UX feedback
      host="${url#*://}"
      host="${host%%/*}"

      # UX: Show progress (only in interactive mode and not debugging)
      if [[ -t 1 && $DEBUG_MODE -ne 1 ]]; then
         echo -ne "\r${CYAN}   Trying $host...${RESET}\033[K"
      fi

      debug_log "Trying IP checker: $url"
      TOR_IP=$(curl --socks5-hostname 127.0.0.1:9050 -s --max-time 10 "$url")
      TOR_IP="${TOR_IP//[$'\r\n']/}"
      if [[ $TOR_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        debug_log "Success from $url: $TOR_IP"
        # UX: Clear the 'Trying...' line on success
        if [[ -t 1 && $DEBUG_MODE -ne 1 ]]; then
           echo -ne "\r\033[K"
        fi
        break
      else
        debug_log "Failed from $url or invalid IP: '$TOR_IP'"
        TOR_IP=""
      fi
    done

    # UX: Clear any stuck "Trying..." line if all failed
    if [[ -t 1 && $DEBUG_MODE -ne 1 ]]; then
       echo -ne "\r\033[K"
    fi

    if [[ -z $TOR_IP ]]; then
      echo -e "${YELLOW}⚠ Could not fetch a valid Tor IP. All checkers failed or timed out.${RESET}"
    else
      echo "Tor IP: $TOR_IP"
    fi

    debug_log "Fetching real IP without proxy"
    REAL_IP=$(curl -s --max-time 10 --noproxy '*' https://ident.me)
    REAL_IP="${REAL_IP//[$'\r\n']/}"
    echo "Real IP: $REAL_IP"

    if [[ -n "$TOR_IP" && "$TOR_IP" != "$REAL_IP" ]]; then
      STATUS_MSG="Traffic IS routed through Tor."
      echo -e "${GREEN}✅ $STATUS_MSG${RESET}"
    else
      STATUS_MSG="Traffic is NOT routed through Tor."
      echo -e "${RED}⚠ $STATUS_MSG${RESET}"
    fi

    # Logging and notification
    # Optimization: Use bash built-ins instead of awk to avoid extra process forks
    last_line=$(tail -n 1 "$LOGFILE" 2>/dev/null)
    if [[ "$last_line" == *"Tor IP: "* ]]; then
      LAST_IP="${last_line#*Tor IP: }"
      LAST_IP="${LAST_IP%% *}"
    else
      LAST_IP=""
    fi

    if [[ "$TOR_IP" != "$LAST_IP" && -n "$TOR_IP" ]]; then
      append_log "$TOR_IP" "$REAL_IP" "$STATUS_MSG"
      send_notification "✅ Tor IP changed to $TOR_IP"
      debug_log "Tor IP changed from '$LAST_IP' to '$TOR_IP', logged and notification sent."
    else
      append_log "$TOR_IP" "$REAL_IP" "$STATUS_MSG"
      debug_log "Tor IP unchanged, just logged."
    fi

  else
    echo "Tor SOCKS proxy NOT reachable at $TOR_SOCKS"
    echo -e "${RED}❌ Traffic is NOT routed through Tor.${RESET}"
  fi
}

# Used after NEWNYM or one-time checks
function monitor_once() {
  TOR_IP=""
  for url in "https://ident.me" "https://ifconfig.me/ip" "https://icanhazip.com"; do
    TOR_IP=$(curl --socks5-hostname 127.0.0.1:9050 -s --max-time 10 "$url")
    TOR_IP="${TOR_IP//[$'\r\n']/}"
    [[ "$TOR_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && break
    TOR_IP=""
  done

  if [[ -z "$TOR_IP" ]]; then
    MSG="⚠ Could not fetch Tor IP after NEWNYM"
  else
    # Optimization: Parse log using bash built-ins
    last_line=$(tail -n 1 "$LOGFILE" 2>/dev/null)
    if [[ "$last_line" == *"Tor IP: "* ]]; then
      LAST_IP="${last_line#*Tor IP: }"
      LAST_IP="${LAST_IP%% *}"
    else
      LAST_IP=""
    fi
    REAL_IP=$(curl -s --noproxy '*' https://ident.me)
    REAL_IP="${REAL_IP//[$'\r\n']/}"

    if [[ "$TOR_IP" != "$LAST_IP" ]]; then
      MSG="✅ Tor IP changed: $TOR_IP"
    else
      MSG="ℹ️ Tor IP unchanged after NEWNYM: $TOR_IP"
    fi

    append_log "$TOR_IP" "$REAL_IP" "$MSG"
  fi

  echo -e "${CYAN}$MSG${RESET}"
  send_notification "$MSG"
}

# Used for live monitoring when user runs './anonymity.sh monitor'
function monitor_loop() {
  echo -e "${CYAN}🔍 Live Tor IP Monitor. Press Ctrl+C to stop...${RESET}"
  PREV_IP=""
  while true; do
    TOR_IP=""
    for url in "https://ident.me" "https://ifconfig.me/ip" "https://icanhazip.com"; do
      TOR_IP=$(curl --socks5-hostname 127.0.0.1:9050 -s --max-time 10 "$url")
      TOR_IP="${TOR_IP//[$'\r\n']/}"
      [[ "$TOR_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && break
      TOR_IP=""
    done

    if [[ -z "$TOR_IP" ]]; then
      MSG="⚠ Could not fetch Tor IP"
    else
      REAL_IP=$(curl -s --noproxy '*' https://ident.me)
      REAL_IP="${REAL_IP//[$'\r\n']/}"
      if [[ "$TOR_IP" != "$PREV_IP" ]]; then
        MSG="✅ Tor IP changed: $TOR_IP"
      else
        MSG="ℹ️ Tor IP unchanged: $TOR_IP"
      fi
      PREV_IP="$TOR_IP"
      append_log "$TOR_IP" "$REAL_IP" "$MSG"
    fi

    echo "$MSG"
    send_notification "$MSG"
    sleep 60
  done
}

function dashboard() {
  clear
  echo -e "${CYAN}╔══════════════════════════════════════════╗"
  echo -e "║     🔐 ${YELLOW}TOR ANONYMITY DASHBOARD${CYAN} 🔐       ║"
  echo -e "╚══════════════════════════════════════════╝${RESET}"

  echo -e "${GREEN}Last 10 log entries:${RESET}"
  if [[ ! -f "$LOGFILE" || ! -s "$LOGFILE" ]]; then
    echo "No logs found yet. You can start monitoring with '${YELLOW}./anonymity.sh check${RESET}' to generate logs."
  else
    prev_ip=""
    tail -n 10 "$LOGFILE" | while IFS= read -r line; do
      # Optimization: Avoid calling awk/echo 20 times by using bash string manipulation
      if [[ "$line" == *"Tor IP: "* ]]; then
        ip="${line#*Tor IP: }"
        ip="${ip%% *}"
      else
        ip=""
      fi

      if [[ "$ip" != "$prev_ip" ]]; then
        echo -e "${YELLOW}$line${RESET}"
      else
        echo "$line"
      fi
      prev_ip="$ip"
    done
  fi

  echo
  echo -en "${CYAN}Tor service status: ${RESET}"
  if systemctl is-active --quiet $TOR_SERVICE; then
    echo -e "${GREEN}🟢 ON${RESET}"
  else
    echo -e "${RED}🔴 OFF${RESET}"
  fi

  echo -en "${CYAN}NEWNYM timer status: ${RESET}"
if systemctl --user is-active --quiet $NEWNYM_TIMER; then
  echo -e "${GREEN}🟢 ON${RESET}"
else
  echo -e "${RED}🔴 OFF${RESET}"
fi
}

function toggle_tor() {
  if systemctl is-active --quiet $TOR_SERVICE; then
    echo -e "${YELLOW}🟢 Tor ON — turning it OFF...${RESET}"
    # Optimization: Use disable --now (combines stop and disable, faster)
    sudo systemctl disable --now $TOR_SERVICE
    echo -e "${RED}🔴 Tor OFF.${RESET}"
  else
    echo -e "${YELLOW}🔴 Tor OFF — turning it ON...${RESET}"
    sudo systemctl enable --now $TOR_SERVICE
    echo -e "${GREEN}🟢 Tor ON.${RESET}"
  fi
}

function toggle_newnym() {
  if systemctl --user is-active --quiet $NEWNYM_TIMER; then
    echo -e "${YELLOW}🟢 NEWNYM timer ON — turning it OFF...${RESET}"
    # Optimization: Use disable --now (combines stop and disable)
    systemctl --user disable --now $NEWNYM_TIMER
    echo -e "${RED}🔴 NEWNYM timer OFF.${RESET}"
  else
    echo -e "${YELLOW}🔴 NEWNYM timer OFF — turning it ON...${RESET}"
    # Optimization: Removed unnecessary daemon-reexec/reload
    systemctl --user enable --now $NEWNYM_TIMER
    echo -e "${GREEN}🟢 NEWNYM timer ON.${RESET}"
  fi
}

function enable_all() {
  echo -e "${CYAN}Enabling Tor and NEWNYM timer...${RESET}"
  sudo systemctl enable --now $TOR_SERVICE
  systemctl --user enable --now $NEWNYM_TIMER
  echo -e "${GREEN}✅ Both services enabled.${RESET}"
}

function disable_all() {
  echo -e "${CYAN}Disabling Tor and NEWNYM timer...${RESET}"
  # Optimization: Use disable --now
  sudo systemctl disable --now $TOR_SERVICE
  systemctl --user disable --now $NEWNYM_TIMER
  echo -e "${RED}⛔ Both services disabled.${RESET}"
}

function restart_all() {
  echo -e "${YELLOW}🔄 Restarting Tor and NEWNYM timer...${RESET}"
  sudo systemctl restart $TOR_SERVICE
  # Optimization: Removed unnecessary daemon-reexec/reload
  systemctl --user restart $NEWNYM_TIMER
  echo -e "${GREEN}✅ Restart complete.${RESET}"
}

function newnym() {
  if ! systemctl is-active --quiet "$TOR_SERVICE"; then
    echo -e "${RED}Tor is not running. Cannot send NEWNYM.${RESET}"
    return
  fi

  echo -ne "${CYAN}Sending NEWNYM signal to Tor...${RESET}"

  # Optimization: Use nc (netcat) instead of expect+telnet
  # This reduces overhead, startup time, and dependencies.
  (
    # Security: Escape special characters in password to prevent protocol injection
    local SAFE_PWD="${AUTH_PASSWORD//\\/\\\\}"  # Escape backslashes
    SAFE_PWD="${SAFE_PWD//\"/\\\"}"            # Escape double quotes

    # Send commands to Tor Control Port via netcat
    # -w 5 sets a 5 second timeout
    # Use CRLF (\r\n) as per Tor Control Protocol spec
    # Security: Use printf instead of echo -e to handle arbitrary binary data safely
    output=$(printf "AUTHENTICATE \"%s\"\r\nSIGNAL NEWNYM\r\nQUIT\r\n" "$SAFE_PWD" | nc -w 5 localhost $CONTROL_PORT 2>&1)

    # Check if we received the success code "250 OK" specifically for the SIGNAL command.
    # The output will contain multiple "250 OK" lines if successful.
    # Authenticate returns 250 OK, Signal returns 250 OK.
    # Optimization: Use bash pattern matching instead of pipe to grep (avoids fork)
    if [[ "$output" == *"250 OK"*"250 OK"* ]]; then
      exit 0
    else
      # Check if rate limited
      if [[ "$output" == *"550"* ]]; then
        echo "Rate limited" >&2
      fi
      exit 1
    fi
  ) &

  local pid=$!
  spinner $pid
  wait $pid
  local exit_code=$?

  echo "" # New line after spinner

  if [[ $exit_code -eq 0 ]]; then
      echo -e "${GREEN}✅ NEWNYM signal sent successfully!${RESET}"
      monitor_once
      return 0
  else
      echo -e "${RED}❌ Failed to send NEWNYM signal.${RESET}"
      return 1
  fi
}

function status() {
  echo -en "${CYAN}Tor service status: ${RESET}"
  if systemctl is-active --quiet $TOR_SERVICE; then
    echo -e "${GREEN}🟢 ON${RESET}"
  else
    echo -e "${RED}🔴 OFF${RESET}"
  fi

  echo -en "${CYAN}NEWNYM timer status: ${RESET}"
  if systemctl --user is-active --quiet $NEWNYM_TIMER; then
    echo -e "${GREEN}🟢 ON${RESET}"
  else
    echo -e "${RED}🔴 OFF${RESET}"
  fi
}


function show_help() {
  echo -e "${CYAN}Usage: $0 {toggle|toggle-tor|toggle-newnym|status|newnym|enable|disable|restart|check|dashboard|monitor|help|menu}${RESET}"
  echo
  echo -e "${YELLOW}Commands:${RESET}"
  echo "  toggle         Toggle both Tor service and NEWNYM timer"
  echo "  toggle-tor     Toggle only Tor service"
  echo "  toggle-newnym  Toggle only NEWNYM timer"
  echo "  enable         Explicitly enable both Tor and NEWNYM"
  echo "  disable        Explicitly disable both"
  echo "  restart        Restart both services"
  echo "  newnym         Send NEWNYM signal to Tor manually"
  echo "  status         Show current service status"
  echo "  check          Test if traffic is routed through Tor"
  echo "  dashboard      Show last 10 IP logs and service status"
  echo "  menu           Launch interactive selection menu"
  echo "  monitor        Run ephemeral IP monitoring (manual or after NEWNYM)"
  echo "  setup          First-time systemd timer/service setup"
  echo "  help           Show this help message"
  echo
  echo -e "${YELLOW}Optional Flags:${RESET}"
  echo "  --debug        Enable verbose debug output (used with 'check' command)"
}

function interactive_menu() {
  while true; do
    # Get status for header
    if systemctl is-active --quiet "$TOR_SERVICE"; then
      t_stat="${GREEN}ON ${RESET}"
    else
      t_stat="${RED}OFF${RESET}"
    fi

    if systemctl --user is-active --quiet "$NEWNYM_TIMER"; then
      n_stat="${GREEN}ON ${RESET}"
    else
      n_stat="${RED}OFF${RESET}"
    fi

    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗"
    echo -e "║     🔐 ${YELLOW}TOR ANONYMITY CONTROL PANEL${CYAN} 🔐     ║"
    echo -e "╠══════════════════════════════════════════╣"
    echo -e "║   Tor Service: ${t_stat}  |   Auto-Rot: ${n_stat}    ║"
    echo -e "╚══════════════════════════════════════════╝${RESET}"

    # Check for setup
    SERVICE_FILE="$HOME/.config/systemd/user/tor-newnym.service"
    if [[ ! -f "$SERVICE_FILE" ]]; then
      echo -e "${YELLOW}  0) ⚡ Run First-Time Setup (Recommended)${RESET}"
    else
      echo -e "  0) Re-run Setup"
    fi

    echo -e "${GREEN}  1) [t]oggle Tor + NEWNYM"
    echo -e "  2) [s]tatus"
    echo -e "  3) Send [n]ewnym Signal"
    echo -e "  4) [e]nable Tor + NEWNYM"
    echo -e "  5) Disable Tor + NEWNYM (o)"
    echo -e "  6) [r]estart Both Services"
    echo -e "  7) [c]heck if Traffic is via Tor"
    echo -e "  8) [m]onitor Tor IP (Live)"
    echo -e "  9) [d]ashboard"
    echo -e " 10) [h]elp"
    echo -e " 11) [q]uit"
    echo
    echo -e "${CYAN}💡 ProTip:${RESET} Use keys (t, s, n...) for quick access."
    echo
    read -p "$(echo -e "${YELLOW}Choose option [0-11] or 'q' to quit: ${RESET}")" choice

    case $choice in
    0) setup_systemd_files ;;
	1|t|T) toggle_tor; toggle_newnym ;;
	2|s|S) status ;;
	3|n|N) newnym ;;
	4|e|E) enable_all ;;
	5|o|O) disable_all ;;
	6|r|R) restart_all ;;
	7|c|C) check_tor_status ;;
	8|m|M) monitor_loop ;;
    9|d|D) dashboard ;;
    10|h|H) show_help ;;
    11|q|Q|exit) echo -e "${CYAN}Exiting... Stay safe! 🛡${RESET}"; break ;;
	*) echo -e "${RED}Invalid option. Please choose between 1-11 or 'q'.${RESET}" ;;
     esac

    echo -e "\n${CYAN}Press any key to return to the menu...${RESET}"
    read -n 1 -s -r
  done
}

function setup_systemd_files() {
  echo -e "${CYAN}📦 Setting up systemd user service and timer for NEWNYM...${RESET}"

  SYSTEMD_DIR="$HOME/.config/systemd/user"
  mkdir -p "$SYSTEMD_DIR"

  SERVICE_FILE="$SYSTEMD_DIR/tor-newnym.service"
  TIMER_FILE="$SYSTEMD_DIR/tor-newnym.timer"
  SCRIPT_PATH="$(realpath "$0")"

  cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Send NEWNYM signal to Tor to change identity

[Service]
Type=oneshot
Environment=ENABLE_NOTIF=1
ExecStart="$SCRIPT_PATH" newnym
EOF

  cat > "$TIMER_FILE" <<EOF
[Unit]
Description=Run NEWNYM every 10 minutes

[Timer]
OnBootSec=3min
OnUnitActiveSec=10min
Unit=tor-newnym.service

[Install]
WantedBy=timers.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable --now tor-newnym.timer

  echo -e "${GREEN}✅ Setup complete. Timer is now active.${RESET}"
  echo -e "${CYAN}You can check status using:${RESET} ${YELLOW}./anonymity.sh status${RESET}"
}

# Skip dependency check for help
if [[ "$1" != "help" && "$1" != "--help" && "$1" != "-h" ]]; then
  check_dependencies
fi

DEBUG_MODE=0
if [[ "$2" == "--debug" || "$1" == "--debug" ]]; then
  DEBUG_MODE=1
fi

# Handle command-line arguments
case "$1" in
  toggle) toggle_tor; toggle_newnym ;;
  toggle-tor) toggle_tor ;;
  toggle-newnym) toggle_newnym ;;
  enable) enable_all ;;
  disable) disable_all ;;
  restart) restart_all ;;
  newnym) newnym ;;
  status) status ;;
  check) check_tor_status ;;
  monitor) monitor_loop ;;  # ✅ This ensures 'monitor' mode works
  dashboard) dashboard ;;
  help) show_help ;;
  menu|"") interactive_menu ;;
  setup) setup_systemd_files ;;
  *) echo -e "${RED}Unknown command: $1${RESET}"; show_help ;;
esac
