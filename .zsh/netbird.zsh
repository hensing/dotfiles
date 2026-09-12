# Netbird status helper — loaded only when netbird is present
if (( $+commands[netbird] )); then

    # Parses `netbird status -d` (read from stdin) into tab-separated per-peer
    # rows: hostname \t ip \t status \t connection-type \t handshake-age \t quantum-resistance
    _ns_data() {
        awk '
            /^ [^ ]+\.[^ ]+:$/ {
                if (host != "") printf "%s\t%s\t%s\t%s\t%s\t%s\n", host, ip, status, conn, hs, qr
                host = $0
                sub(/^ /, "", host); sub(/:$/, "", host)
                ip = ""; status = ""; conn = ""; hs = ""; qr = ""
                next
            }
            /^Events:/ { exit }
            $1 == "NetBird" && $2 == "IP:"        { ip = $3 }
            $1 == "Status:"                        { status = $2 }
            $1 == "Connection" && $2 == "type:"    { conn = $3 }
            $1 == "Quantum" && $2 == "resistance:" { qr = $3 }
            /Last WireGuard handshake:/ {
                hs = $0
                sub(/.*Last WireGuard handshake: */, "", hs)
            }
            END { if (host != "") printf "%s\t%s\t%s\t%s\t%s\t%s\n", host, ip, status, conn, hs, qr }
        '
    }

    # Computes icon/sort-rank per row, sorts (ok > stale > connecting > sleeping
    # > unknown, then alphabetically), then aligns into a table.
    _ns_fmt() {
        awk -F'\t' '
            # Handles both "3 seconds ago" and compound "1 minute, 58 seconds ago"
            function hs_secs(s,   parts, kv, i, np, total) {
                if (s !~ / ago$/) return -1
                sub(/ ago$/, "", s)
                np = split(s, parts, ", ")
                total = 0
                for (i = 1; i <= np; i++) {
                    split(parts[i], kv, " ")
                    if (kv[2] ~ /^second/) total += kv[1]
                    else if (kv[2] ~ /^minute/) total += kv[1] * 60
                    else if (kv[2] ~ /^hour/)   total += kv[1] * 3600
                    else if (kv[2] ~ /^day/)    total += kv[1] * 86400
                }
                return total
            }
            {
                host = $1; ip = $2; status = $3; conn = $4; hs = $5; qr = $6
                sub(/\..*$/, "", host)
                connshort = (conn == "P2P") ? "P2P" : (conn == "Relayed") ? "Relay" : "-"
                qricon = (qr == "true") ? "🔐" : "🔓"
                secs = hs_secs(hs)
                if (status == "Connected") {
                    if (secs < 0)         { icon = "🚀"; rank = 2 }  # connected, handshake not seen yet
                    else if (secs <= 180) { icon = "✅"; rank = 0 }
                    else                  { icon = "⚠️"; rank = 1 }
                } else if (status == "Idle" || status == "Disconnected" || status == "Connecting") {
                    icon = "💤"; rank = 3
                } else {
                    icon = "❓"; rank = 4
                }
                printf "%d\t%s\t%s\t%s\t%s\t%s\n", rank, host, icon, ip, connshort, qricon
            }
        ' | sort -t $'\t' -k1,1n -k2,2 | awk -F'\t' '
            {
                icon[NR] = $3; host[NR] = $2; ip[NR] = $4; conn[NR] = $5; qr[NR] = $6
                if (length($2) > w_host) w_host = length($2)
                if (length($4) > w_ip)   w_ip   = length($4)
                n++
            }
            END {
                for (i = 1; i <= n; i++)
                    printf "%s %-*s  %-*s  %-5s  %s\n", icon[i], w_host, host[i], w_ip, ip[i], conn[i], qr[i]
            }
        '
    }

    ns() {
        local raw peers nsstat
        raw=$(netbird status -d)

        echo "$raw" | _ns_data | _ns_fmt

        peers=$(echo "$raw" | awk -F': ' '/^Peers count:/ { print $2 }')
        nsstat=$(echo "$raw" | awk '
            /^Nameservers:/ { f = 1; next }
            f && /is Available/   { ok++; tot++ }
            f && /is Unavailable/ { tot++ }
            /^FQDN:/ { f = 0 }
            END { print (tot > 0 ? ok "/" tot : "n/a") }
        ')

        echo ""
        echo "Peers: ${peers}   Nameservers: ${nsstat}"
    }

fi
