# Docker aliases and functions — loaded only when docker is present
if (( $+commands[docker] )); then

    # --- aliases and functions ---

    # Formats tab-separated docker fields (ID\tNAMES\tIMAGE\tSTATUS\tPORTS) into a
    # coloured, aligned table.
    #   --image      include the IMAGE column
    #   --all-ports  show all port mappings; default shows only exposed ones
    #                (bound to 0.0.0.0 or [::]), with the header "OPEN PORTS"
    _ds_fmt() {
        local show_image=0 all_ports=0
        for arg in "$@"; do
            [[ "$arg" == "--image"     ]] && show_image=1
            [[ "$arg" == "--all-ports" ]] && all_ports=1
        done
        awk -v show_image="$show_image" -v all_ports="$all_ports" '
BEGIN {
    FS = "\t"
    GREEN  = "\033[32m"; YELLOW = "\033[33m"
    RED    = "\033[31m"; RESET  = "\033[0m"
    n = 0
    w_id = 12; w_name = 5; w_img = 5; w_status = 6
}
NF {
    id[n]         = $1
    name[n]       = $2
    img[n]        = $3
    status_raw[n] = $4
    ports_raw[n]  = $5

    if      ($4 ~ /unhealthy/)              clr[n] = RED
    else if ($4 ~ /healthy/ || $4 ~ /Up /) clr[n] = GREEN
    else if ($4 ~ /[Ee]xit/)               clr[n] = YELLOW
    else                                    clr[n] = ""

    if (length($1) > w_id)     w_id     = length($1)
    if (length($2) > w_name)   w_name   = length($2)
    if (length($4) > w_status) w_status = length($4)
    if (show_image && length($3) > w_img) w_img = length($3)
    n++
}
END {
    ports_hdr = all_ports ? "PORTS" : "BOUND PORTS"
    if (show_image) {
        printf "%-" w_id "s  %-" w_name "s  %-" w_img "s  %-" w_status "s  %s\n",
            "CONTAINER ID", "NAMES", "IMAGE", "STATUS", ports_hdr
        pad_len = w_id + 2 + w_name + 2 + w_img + 2 + w_status + 2
    } else {
        printf "%-" w_id "s  %-" w_name "s  %-" w_status "s  %s\n",
            "CONTAINER ID", "NAMES", "STATUS", ports_hdr
        pad_len = w_id + 2 + w_name + 2 + w_status + 2
    }

    pad = sprintf("%-" pad_len "s", "")

    for (i = 0; i < n; i++) {
        if (show_image)
            row_fmt = "%-" w_id "s  %-" w_name "s  %-" w_img "s  " \
                      clr[i] "%-" w_status "s" (clr[i] != "" ? RESET : "") "  %s\n"
        else
            row_fmt = "%-" w_id "s  %-" w_name "s  " \
                      clr[i] "%-" w_status "s" (clr[i] != "" ? RESET : "") "  %s\n"

        # Split ports and optionally filter to exposed-only (0.0.0.0 or [::])
        delete raw_arr
        delete port_arr
        np_raw = split(ports_raw[i], raw_arr, ", ")
        fp = 0
        for (k = 1; k <= np_raw; k++)
            if (all_ports || raw_arr[k] ~ /:/)
                port_arr[++fp] = raw_arr[k]

        if (show_image)
            printf row_fmt, id[i], name[i], img[i], status_raw[i], (fp > 0 ? port_arr[1] : "")
        else
            printf row_fmt, id[i], name[i], status_raw[i], (fp > 0 ? port_arr[1] : "")

        for (j = 2; j <= fp; j++)
            printf "%s%s\n", pad, port_arr[j]
    }
}
'
    }

    # Fetches raw container data from docker in tab-separated form.
    _ds_data() {
        docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    }

    ds()  {
        local data; data=$(_ds_data)
        [[ "$1" == "--sort" ]] && data=$(echo "$data" | sort -t$'\t' -k2)
        echo "$data" | _ds_fmt
    }

    dse() {
        local data; data=$(_ds_data)
        [[ "$1" == "--sort" ]] && data=$(echo "$data" | sort -t$'\t' -k2)
        echo "$data" | _ds_fmt --image --all-ports
    }

    dss()  { ds  --sort }  # ds,  sorted by name
    dsse() { dse --sort }  # dse, sorted by name
    alias de='docker exec -it'
    alias dl='docker logs'
    alias di='docker inspect'
    alias dS='docker stats'
    alias drm='docker rm `docker ps -q -a`'
    alias drmf='docker rm -f `docker ps -q -a`'
    alias dI='docker images'
    alias drmi='docker rmi `docker images -q`'
    alias dco='docker compose'
    alias dcp='docker compose pull'
    alias dcb='docker compose build'
    alias dcu='docker compose up'
    alias dcd='docker compose down'

    # Generate zsh completion on first use (active from next shell start)
    if [[ ! -f ~/.zsh/completions/_docker ]]; then
        docker completion zsh > ~/.zsh/completions/_docker 2>/dev/null
        # Make it available in this session without re-running compinit
        compdef _docker docker 2>/dev/null
    fi

    # --- volume helpers ---

    # Export a Docker volume to a .tar file
    # Usage: docker_volume_export <volume_name> <target_tar_path>
    docker_volume_export() {
        set -e
        local volume_name="$1"
        local target_tar_path="$2"

        if [[ -z "$volume_name" || -z "$target_tar_path" ]]; then
            print "Usage: docker_volume_export <volume_name> <target_tar_path>"
            return 1
        fi

        print "Exporting Docker volume '$volume_name' to '$target_tar_path'..."

        local target_dir="$(dirname "$target_tar_path")"
        if [[ ! -d "$target_dir" ]]; then
            print "Creating target directory '$target_dir'..."
            mkdir -p "$target_dir"
        fi

        if docker run --rm -v "$volume_name":/volume_data alpine tar -cvf - -C /volume_data . > "$target_tar_path"; then
            print "Export successful."
        else
            print "Export failed."
            return 1
        fi
    }

    # Import a .tar file into a Docker volume
    # Usage: docker_volume_import <source_tar_path> <target_volume_name>
    docker_volume_import() {
        local source_tar_path="$1"
        local target_volume_name="$2"

        if [[ -z "$source_tar_path" || -z "$target_volume_name" ]]; then
            print "Usage: docker_volume_import <source_tar_path> <target_volume_name>"
            return 1
        fi

        if [[ ! -f "$source_tar_path" ]]; then
            print "Error: Source tar file '$source_tar_path' not found."
            return 1
        fi

        print "Importing '$source_tar_path' into Docker volume '$target_volume_name'..."

        if ! docker volume inspect "$target_volume_name" > /dev/null 2>&1; then
            print "Volume '$target_volume_name' not found, creating it..."
            docker volume create "$target_volume_name" || return 1
        fi

        if cat "$source_tar_path" | docker run --rm -i -v "$target_volume_name":/volume_data alpine tar -xvf - -C /volume_data; then
            print "Import successful."
        else
            print "Import failed."
            return 1
        fi
    }

    # Migrate a host directory (bind mount) into a Docker volume via rsync
    # Usage: docker_bind_to_volume <source_host_dir> <target_volume_name>
    docker_bind_to_volume() {
        local source_host_dir="$1"
        local target_volume_name="$2"

        if [[ -z "$source_host_dir" || -z "$target_volume_name" ]]; then
            print "Usage: docker_bind_to_volume <source_host_directory> <target_volume_name>"
            return 1
        fi

        if [[ ! -d "$source_host_dir" ]]; then
            print "Error: Source host directory '$source_host_dir' not found."
            return 1
        fi

        print "Migrating '$source_host_dir' to Docker volume '$target_volume_name'..."

        if ! docker volume inspect "$target_volume_name" > /dev/null 2>&1; then
            print "Volume '$target_volume_name' not found, creating it..."
            docker volume create "$target_volume_name" || return 1
        fi

        if docker run --rm \
            -v "$source_host_dir":/src_data \
            -v "$target_volume_name":/dest_data \
            ubuntu bash -c "rsync -a /src_data/ /dest_data/ && sync" > /dev/null; then
            print "Migration successful."
        else
            print "Migration failed."
            return 1
        fi
    }

    # Check running containers for root processes and docker.sock mounts
    # Usage: docker_check_root [-v|--verbose]   (-v expands host-root PID/CMD lists)
    docker_check_root() {
        local verbose=false
        case "$1" in
            -v|--verbose) verbose=true ;;
        esac

        local -a ok_names undet_names
        local -a warn_names warn_uids warn_counts warn_pids
        local -a sock_names sock_uids sock_counts sock_pids
        local total=0 any_pids=false

        local container_id container_name id_full uid_num uid_label host_pids host_count sock cfg cfg_uid
        for container_id in $(docker ps -q); do
            (( total++ ))
            container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/\///')

            sock=false
            if docker inspect "$container_id" --format '{{json .Mounts}}' | grep -q '/var/run/docker.sock'; then
                sock=true
            fi

            id_full=$(docker exec "$container_id" id 2>/dev/null)
            if [[ -n "$id_full" ]]; then
                uid_num=$(echo "$id_full" | grep -oP 'uid=\K\d+')
                uid_label=${id_full#uid=}       # e.g. "0(root)", "33(www-data)", "990"
                uid_label=${uid_label%% *}
                [[ -z "$uid_label" ]] && uid_label=$uid_num
            else
                # Fallback for minimal images without an `id` binary: use the
                # configured user. This is the declared user, not runtime-verified,
                # so mark it with "?". docker top below stays the root-process truth.
                cfg=$(docker inspect --format '{{.Config.User}}' "$container_id" 2>/dev/null)
                cfg_uid=${cfg%%:*}              # strip ":group" if present
                if [[ -z "$cfg" || "$cfg_uid" == "root" || "$cfg_uid" == "0" ]]; then
                    uid_num=0; uid_label="0(root?)"          # no USER set → defaults to root
                elif [[ "$cfg_uid" == <-> ]]; then
                    uid_num=$cfg_uid; uid_label="${cfg_uid}?"
                else
                    uid_num=""; uid_label="${cfg_uid}?"      # named user, uid unresolved
                fi
            fi

            host_pids=$(docker top "$container_id" -eo uid,pid,cmd 2>/dev/null | awk '$1 == "0" && $1 != "UID" { print $0 }')
            if [[ -n "$host_pids" ]]; then
                host_count=$(echo "$host_pids" | wc -l | tr -d ' ')
                any_pids=true
            else
                host_count=0
            fi

            # Categorize by highest severity (each container appears once)
            if [[ "$sock" == true ]]; then
                sock_names+=("$container_name"); sock_uids+=("$uid_label"); sock_counts+=("$host_count"); sock_pids+=("$host_pids")
            elif [[ "$uid_num" == "0" || "$host_count" -gt 0 ]]; then
                warn_names+=("$container_name"); warn_uids+=("$uid_label"); warn_counts+=("$host_count"); warn_pids+=("$host_pids")
            elif [[ -n "$uid_label" ]]; then
                ok_names+=("$container_name")
            else
                undet_names+=("$container_name")
            fi
        done

        # --- Output ---------------------------------------------------------
        print "━━━ Docker Security Check ━━━━━━━━━━━━━━━━━━━━━━"
        print ""

        if (( ${#ok_names} )); then
            print " ✅ OK (${#ok_names}): ${(j:, :)ok_names}"
            print ""
        fi

        local i n w hr
        if (( ${#warn_names} )); then
            print " ⚠️  Root / host-root:"
            w=0; for n in $warn_names; do (( ${#n} > w )) && w=${#n}; done
            for i in {1..${#warn_names}}; do
                hr=""; (( warn_counts[i] > 0 )) && hr="   host-root×${warn_counts[i]}"
                printf '    %-*s   uid=%s%s\n' "$w" "$warn_names[i]" "$warn_uids[i]" "$hr"
                if [[ "$verbose" == true && -n "$warn_pids[i]" ]]; then
                    echo "$warn_pids[i]" | awk '{pid=$2; $1=""; $2=""; sub(/^ +/,""); printf "        %s  %s\n", pid, $0}'
                fi
            done
            print ""
        fi

        if (( ${#sock_names} )); then
            print " 🚨 docker.sock gemountet:"
            w=0; for n in $sock_names; do (( ${#n} > w )) && w=${#n}; done
            for i in {1..${#sock_names}}; do
                hr=""; (( sock_counts[i] > 0 )) && hr="   host-root×${sock_counts[i]}"
                printf '    %-*s   uid=%s%s\n' "$w" "$sock_names[i]" "$sock_uids[i]" "$hr"
                if [[ "$verbose" == true && -n "$sock_pids[i]" ]]; then
                    echo "$sock_pids[i]" | awk '{pid=$2; $1=""; $2=""; sub(/^ +/,""); printf "        %s  %s\n", pid, $0}'
                fi
            done
            print ""
        fi

        if (( ${#undet_names} )); then
            print " ❓ Unbestimmt (id fehlt): ${(j:, :)undet_names}"
            print ""
        fi

        local summary=" ${total} total · ${#ok_names} ok · ${#warn_names} root · ${#sock_names} sock"
        [[ "$verbose" != true && "$any_pids" == true ]] && summary+="   (-v für PID-Details)"
        print "$summary"
    }

    # Pull and recreate all stacks in /opt/stacks, reload nginx if anything changed
    # Usage: update_stacks [--prune] [--force-recreate] [/custom/stacks/dir]
    update_stacks() {
        local stacks_dir="/opt/stacks"
        local dockge_dir="/opt/dockge"
        local run_prune=false
        local force_recreate_flag=""
        local updates_occurred=false
        local log_file=$(mktemp)

        for arg in "$@"; do
            case $arg in
                --prune)          run_prune=true ;;
                --force-recreate) force_recreate_flag="--force-recreate"; updates_occurred=true
                                  echo "⚠️  Force recreate enabled." ;;
                /*)               [[ -d "$arg" ]] && stacks_dir="$arg" ;;
            esac
        done

        echo "🚀 Updating stacks in: $stacks_dir"
        echo "---------------------------------------------------"

        for stack in "$stacks_dir"/*(/); do
            if [[ -f "$stack/compose.yaml" || -f "$stack/compose.yml" || -f "$stack/docker-compose.yml" ]]; then
                echo "📂 $(basename "$stack")"
                pushd -q "$stack" || continue
                docker compose pull
                docker compose up -d $force_recreate_flag 2>&1 | tee "$log_file"
                grep -qE "(Recreated|Started|Created)" "$log_file" && updates_occurred=true
                popd -q
                echo "---------------------------------------------------"
            fi
        done

        if [[ -d "$dockge_dir" ]]; then
            echo "🦎 Updating Dockge ($dockge_dir)..."
            pushd -q "$dockge_dir" || return
            docker compose pull
            docker compose up -d $force_recreate_flag 2>&1 | tee "$log_file"
            grep -qE "(Recreated|Started|Created)" "$log_file" && updates_occurred=true
            popd -q
            echo "---------------------------------------------------"
        else
            echo "⚠️  /opt/dockge not found, skipping."
            echo "---------------------------------------------------"
        fi

        rm -f "$log_file"

        if [[ "$updates_occurred" == true ]]; then
            echo "🔄 Updates detected — reloading Nginx Proxy Manager..."
            if docker ps --format '{{.Names}}' | grep -q "^npm-proxy$"; then
                docker exec npm-proxy nginx -s reload \
                    && echo "✅ Nginx reloaded." \
                    || echo "❌ Nginx reload failed."
            else
                echo "⚠️  Container 'npm-proxy' not running, reload skipped."
            fi
            echo "---------------------------------------------------"
        else
            echo "💤 No updates detected."
            echo "---------------------------------------------------"
        fi

        if [[ "$run_prune" == true ]]; then
            echo "🧹 Pruning unused images..."
            docker image prune -af
        fi

        echo "✅ Done."
    }

fi
