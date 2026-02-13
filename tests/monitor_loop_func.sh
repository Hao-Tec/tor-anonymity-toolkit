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
      # Optimization: Cache Real IP to avoid redundant API calls every loop
      if [[ -z "$REAL_IP_CACHE" ]]; then
        REAL_IP_CACHE=$(curl -s --noproxy '*' https://ident.me)
        REAL_IP_CACHE="${REAL_IP_CACHE//[$'\r\n']/}"
      fi
      REAL_IP="$REAL_IP_CACHE"

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
