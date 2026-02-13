function append_log() {
  local timestamp ip_tor ip_real status
  # Optimization: Use printf builtin (Bash 4.2+) instead of forking 'date'
  printf -v timestamp '%(%Y-%m-%d %H:%M:%S)T' -1
  ip_tor="$1"
  ip_real="$2"
  status="$3"
  echo "$timestamp | Tor IP: $ip_tor | Real IP: $ip_real | Status: $status" >> "$LOGFILE"
}
function send_notification() {
  if [[ "$ENABLE_NOTIF" == "1" ]] && command -v notify-send &>/dev/null; then
    notify-send "ℹ  Tor Anonymity Alert" "$1"
    echo "🔔 Notification sent: $1"
  else
    echo "⚠️ Notification skipped: notify-send unavailable or ENABLE_NOTIF=$ENABLE_NOTIF"
  fi
}
function monitor_loop() {
  echo -e "${CYAN}🔍 Live Tor IP Monitor. Press Ctrl+C to stop...${RESET}"
  PREV_IP=""
  CACHED_REAL_IP=""
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
      # Optimization: Cache Real IP to avoid redundant requests
      if [[ -z "$CACHED_REAL_IP" ]]; then
        CACHED_REAL_IP=$(curl -s --noproxy '*' https://ident.me)
        CACHED_REAL_IP="${CACHED_REAL_IP//[$'\r\n']/}"
      fi
      REAL_IP="$CACHED_REAL_IP"

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
