#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
CONFIG_FILE="/home/bestsithineu/Documents/gitProjects/caelestia/vpn/vpn-apps.yaml"
RG="${RG:-rg}"

# Use iptables-legacy if available (better compatibility on Arch)
if command -v iptables-legacy >/dev/null 2>&1; then
    IPTABLES="iptables-legacy"
    IP6TABLES="ip6tables-legacy"
else
    IPTABLES="iptables"
    IP6TABLES="ip6tables"
fi

# Load config from YAML directly into global variables
[[ -f "$CONFIG_FILE" ]] || { echo "Missing config file: $CONFIG_FILE"; exit 1; }

# Extract values using grep/sed (handle indented YAML)
WGCONF=$(grep "config_path:" "$CONFIG_FILE" | sed 's/.*config_path: *"\?\([^"]*\)"\?.*/\1/')
NS=$(grep "namespace:" "$CONFIG_FILE" | sed 's/.*namespace: *"\?\([^"]*\)"\?.*/\1/')
WGIF=$(grep "interface_name:" "$CONFIG_FILE" | sed 's/.*interface_name: *"\?\([^"]*\)"\?.*/\1/')
SUBNET_CIDR=$(grep "subnet:" "$CONFIG_FILE" | sed 's/.*subnet: *"\?\([^"]*\)"\?.*/\1/')
HOST_VETH_IP=$(grep "host_ip:" "$CONFIG_FILE" | sed 's/.*host_ip: *"\?\([^"]*\)"\?.*/\1/')
NS_VETH_IP=$(grep "namespace_ip:" "$CONFIG_FILE" | sed 's/.*namespace_ip: *"\?\([^"]*\)"\?.*/\1/')
VPN_DNS_V4=$(grep "dns_primary:" "$CONFIG_FILE" | sed 's/.*dns_primary: *"\?\([^"]*\)"\?.*/\1/')
FALLBACK_DNS_V4=$(grep "dns_fallback:" "$CONFIG_FILE" | sed 's/.*dns_fallback: *"\?\([^"]*\)"\?.*/\1/')

# Set defaults if empty
NS="${NS:-mullvadns}"
WGIF="${WGIF:-$(basename "$WGCONF" .conf)}"
SUBNET_CIDR="${SUBNET_CIDR:-10.200.200.0/24}"
HOST_VETH_IP="${HOST_VETH_IP:-10.200.200.1/24}"
NS_VETH_IP="${NS_VETH_IP:-10.200.200.2/24}"
VPN_DNS_V4="${VPN_DNS_V4:-100.64.0.55}"
FALLBACK_DNS_V4="${FALLBACK_DNS_V4:-1.1.1.1}"

# Set remaining variables
HOST_VETH="veth-host-mv"
NS_VETH="veth-ns-mv"
NETNS_ETC="/etc/netns/${NS}"
USER_NAME="${SUDO_USER:-$USER}"
SUDOERS_FILE="/etc/sudoers.d/99-${NS}-exec"

# Debug output
echo "Config loaded: NS=$NS, SUBNET_CIDR=$SUBNET_CIDR, WGCONF=$WGCONF"

# Parse apps array from YAML
mapfile -t apps < <(grep -A 10 "^apps:" "$CONFIG_FILE" | grep "^  - " | sed 's/^  - //')

require_root() { if [[ $EUID -ne 0 ]]; then echo "Run as root (sudo)"; exit 1; fi; }

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }


wan_if() { 
  # Find the default route interface that's not a VPN interface
  ip route show default | grep -v 'wg[0-9]' | head -1 | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'
}

endpoint_ip_port() {
  # Pull Endpoint host:port from WGCONF with ripgrep (fallback to grep/awk)
  local hostport host port ip
  if command -v "$RG" >/dev/null 2>&1; then
    hostport=$("$RG" -no '^\s*Endpoint\s*=\s*(\S+)' -r '$1' "$WGCONF" | head -n1 || true)
  else
    hostport=$(grep -m1 -E '^\s*Endpoint\s*=' "$WGCONF" | awk -F= '{gsub(/ /,"",$2); print $2}' || true)
  fi
  [[ -n "$hostport" ]] || { echo "Could not find Endpoint in $WGCONF"; exit 1; }
  host=${hostport%:*}; port=${hostport##*:}
  if [[ "$host" =~ ^[0-9.]+$ ]]; then ip="$host"; else ip=$(getent ahostsv4 "$host" | awk '{print $1; exit}'); fi
  echo "$ip:$port"
}

install_shim() {
  local app="$1"
  cat >/usr/local/bin/"$app" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
NS="mullvadns"
REAL="/usr/bin/$(basename "$0")"
# Fast path: if namespace + WireGuard iface are up, run inside; else run normally.
ns_up() {
  ip netns list 2>/dev/null | grep -qw "$NS" || return 1
  ip netns exec "$NS" ip link show 2>/dev/null | grep -qw "$(basename /etc/wireguard/mullvadns.conf .conf)" || return 1
  return 0
}
if ns_up; then
  # Join netns as root then drop to invoking user inside the ns before exec
  ME_UID=$(id -u)
  ME_GID=$(id -g)
  exec sudo -n ip netns exec "$NS" setpriv --reuid="$ME_UID" --regid="$ME_GID" --init-groups -- "$REAL" "$@"
else
  exec "$REAL" "$@"
fi
EOF
  chmod +x /usr/local/bin/"$app"
}

patch_desktop() {
  # Ensure .desktop Exec uses the bare name so our shim in /usr/local/bin is used
  local src dst name pattern
  name="$1"
  case "$name" in
    firefox) src="/usr/share/applications/firefox.desktop" ;;
    google-chrome-stable) src="/usr/share/applications/google-chrome.desktop" ;;
    discord) src="/usr/share/applications/discord.desktop" ;;
    *) return 0 ;;
  esac
  [[ -f "$src" ]] || return 0
  mkdir -p "/home/$USER_NAME/.local/share/applications"
  dst="/home/$USER_NAME/.local/share/applications/$(basename "$src")"
  cp "$src" "$dst"
  # Replace absolute /usr/bin/... with bare command
  sed -i -E "s#Exec=/usr/bin/(firefox)([[:space:]].*)?#Exec=firefox\\2#g" "$dst" || true
  sed -i -E "s#Exec=/usr/bin/(google-chrome-stable)([[:space:]].*)?#Exec=google-chrome-stable\\2#g" "$dst" || true
  sed -i -E "s#Exec=/usr/bin/(discord)([[:space:]].*)?#Exec=discord\\2#g" "$dst" || true
  chown "$USER_NAME":"$USER_NAME" "$dst"
  update-desktop-database "/home/$USER_NAME/.local/share/applications" >/dev/null 2>&1 || true
}

create_netns_base() {
  ip netns add "$NS" 2>/dev/null || true
  mkdir -p "$NETNS_ETC"
  cat >"${NETNS_ETC}/resolv.conf" <<EOF
nameserver ${VPN_DNS_V4}
nameserver ${FALLBACK_DNS_V4}
options edns0
EOF
}

setup_veth_nat() {
  local wan
  wan=$(wan_if)
  echo "DEBUG: WAN interface detected as: '$wan'"
  echo "DEBUG: SUBNET_CIDR: '$SUBNET_CIDR'"
  [[ -n "$wan" ]] || { echo "WAN not detected"; exit 1; }
  ip link add "$HOST_VETH" type veth peer name "$NS_VETH" 2>/dev/null || true
  ip link set "$NS_VETH" netns "$NS" 2>/dev/null || true
  ip addr add "$HOST_VETH_IP" dev "$HOST_VETH" 2>/dev/null || true
  ip link set "$HOST_VETH" up
  ip netns exec "$NS" ip addr add "$NS_VETH_IP" dev "$NS_VETH" 2>/dev/null || true
  ip netns exec "$NS" ip link set lo up
  ip netns exec "$NS" ip link set "$NS_VETH" up
  ip netns exec "$NS" ip route add default via "${HOST_VETH_IP%/*}" 2>/dev/null || true
  sysctl -w net.ipv4.ip_forward=1 >/dev/null

  # Load required kernel modules
  modprobe xt_MASQUERADE 2>/dev/null || true
  modprobe xt_conntrack 2>/dev/null || true
  
  # Use nftables instead of iptables for better Arch compatibility
  echo "Setting up NAT with nftables..."
  
  # Create table if it doesn't exist
  nft add table ip nat 2>/dev/null || true
  nft add table ip filter 2>/dev/null || true
  
  # Add chains if they don't exist
  nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; } 2>/dev/null || true
  nft add chain ip filter forward { type filter hook forward priority 0 \; } 2>/dev/null || true
  
  # Add NAT rule
  nft add rule ip nat postrouting ip saddr "$SUBNET_CIDR" oifname "$wan" masquerade 2>/dev/null || true
  
  # Add forwarding rules
  nft add rule ip filter forward iifname "$HOST_VETH" oifname "$wan" accept 2>/dev/null || true
  nft add rule ip filter forward iifname "$wan" oifname "$HOST_VETH" ct state established,related accept 2>/dev/null || true
}

setup_ns_killswitch() {
  local ep ip port
  ep=$(endpoint_ip_port); ip=${ep%:*}; port=${ep##*:}

  ip netns exec "$NS" $IPTABLES -F || true
  ip netns exec "$NS" $IPTABLES -P OUTPUT DROP
  ip netns exec "$NS" $IPTABLES -P INPUT DROP
  ip netns exec "$NS" $IPTABLES -P FORWARD DROP
  ip netns exec "$NS" $IPTABLES -A OUTPUT -o lo -j ACCEPT
  ip netns exec "$NS" $IPTABLES -A INPUT  -i lo -j ACCEPT
  ip netns exec "$NS" $IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  ip netns exec "$NS" $IPTABLES -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  ip netns exec "$NS" $IPTABLES -A OUTPUT -p udp -d "$ip" --dport "$port" -j ACCEPT
  ip netns exec "$NS" $IPTABLES -A OUTPUT -o "$WGIF" -j ACCEPT

  ip netns exec "$NS" $IP6TABLES -F || true
  ip netns exec "$NS" $IP6TABLES -P OUTPUT DROP
  ip netns exec "$NS" $IP6TABLES -P INPUT DROP
  ip netns exec "$NS" $IP6TABLES -P FORWARD DROP
  ip netns exec "$NS" $IP6TABLES -A OUTPUT -o lo -j ACCEPT
  ip netns exec "$NS" $IP6TABLES -A INPUT  -i lo -j ACCEPT
  ip netns exec "$NS" $IP6TABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  ip netns exec "$NS" $IP6TABLES -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
}

wg_up()  { ip netns exec "$NS" wg-quick up "$WGCONF"; }
wg_down(){ ip netns exec "$NS" wg-quick down "$WGCONF" || true; }

install_sudoers() {
  # Allow USER_NAME to run ip netns exec mullvadns ... without password
  # (Required so GUI launches don't prompt; we drop back to the user via setpriv)
  echo "${USER_NAME} ALL=(root) NOPASSWD: /usr/bin/ip netns exec ${NS} *" > "$SUDOERS_FILE"
  chmod 440 "$SUDOERS_FILE"
  visudo -c >/dev/null
}

uninstall_sudoers() { rm -f "$SUDOERS_FILE"; }

cleanup_all() {
  local wan; wan=$(wan_if || true)
  wg_down
  
  # Clean up nftables rules
  nft flush table ip nat 2>/dev/null || true
  nft flush table ip filter 2>/dev/null || true
  
  ip link del "$HOST_VETH" 2>/dev/null || true
  ip netns del "$NS" 2>/dev/null || true
  rm -rf "$NETNS_ETC" 2>/dev/null || true
}

status() {
  echo "=== netns ==="; ip netns list | grep -F "$NS" || echo "(absent)"
  echo "=== wg ==="; ip netns exec "$NS" wg show 2>/dev/null || echo "(wg down)"
  echo "=== routes ==="; ip netns exec "$NS" ip route 2>/dev/null || true
}

cmd_install() {
  require_root
  need ip; need wg-quick; need $IPTABLES; need setpriv
  [[ -f "$WGCONF" ]] || { echo "Missing $WGCONF"; exit 1; }
  for a in "${apps[@]}"; do install_shim "$a"; done
  for a in "${apps[@]}"; do patch_desktop "$a"; done
  install_sudoers
  echo "Installed shims + sudoers. Next: '$0 start'"
}

cmd_start() {
  require_root
  [[ -f "$WGCONF" ]] || { echo "Missing $WGCONF"; exit 1; }
  create_netns_base
  setup_veth_nat
  setup_ns_killswitch
  wg_up
  echo "VPN namespace started. Launch firefox/chrome/discord as usual."
}

cmd_stop()  { require_root; cleanup_all; echo "Stopped & cleaned."; }
cmd_status(){ require_root; status; }

cmd_uninstall() {
  require_root
  for a in "${apps[@]}"; do rm -f /usr/local/bin/"$a"; done
  uninstall_sudoers
  cleanup_all
  echo "Uninstalled shims + netns."
}

case "${1:-}" in
  install)   cmd_install ;;
  start)     cmd_start ;;
  stop)      cmd_stop ;;
  status)    cmd_status ;;
  uninstall) cmd_uninstall ;;
  *)
    cat <<EOF
Usage:
  sudo $0 install    # install shims, sudoers, patch .desktop
  sudo $0 start      # create netns, bring WireGuard up with killswitch
  sudo $0 status
  sudo $0 stop
  sudo $0 uninstall  # remove shims, sudoers, netns

Run apps normally (click icon or 'firefox', 'google-chrome-stable', 'discord').
They auto-use Mullvad if the VPN namespace is up, else use normal internet.
EOF
    ;;
esac
