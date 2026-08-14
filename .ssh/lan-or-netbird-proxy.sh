#!/bin/sh
# ProxyCommand helper: connect via LAN IP if reachable within ~1.5s, else Netbird IP.
# macOS's nc -w does not reliably bound the initial connect() call, so a
# watchdog process force-kills the probe with SIGKILL (always effective,
# unlike relying on nc's own timeout).
#
# Usage: lan-or-netbird-proxy.sh <lan_ip> <netbird_ip> [port]
#
# in .ssh/config:
# Host raspi-ack
#    HostName raspi-home.int.example.com
#    HostKeyAlias raspi-home
#    ProxyCommand ~/.ssh/lan-or-netbird-proxy.sh 1.2.3.4 raspi-home.int.example.com

lan_ip="$1"
netbird_ip="$2"
port="${3:-22}"

nc -z -w1 "$lan_ip" "$port" 2>/dev/null &
pid=$!
( sleep 1.5; kill -9 "$pid" 2>/dev/null ) 2>/dev/null &
watchdog=$!
wait "$pid" 2>/dev/null
rc=$?
kill "$watchdog" 2>/dev/null

if [ "$rc" -eq 0 ]; then
	exec nc "$lan_ip" "$port"
else
	exec nc "$netbird_ip" "$port"
fi
