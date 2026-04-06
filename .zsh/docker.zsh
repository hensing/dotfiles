# Docker aliases and functions — loaded only when docker is present
if (( $+commands[docker] )); then

    # --- aliases and functions ---

    # Formats tab-separated docker fields (ID\tNAMES\tIMAGE\tSTATUS\tPORTS) into a
    # coloured, aligned table. Pass --image to include the IMAGE column.
    _ds_fmt() {
        local show_image=0
        [[ "${1}" == "--image" ]] && show_image=1
        awk -v show_image="$show_image" '
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
    if (show_image) {
        printf "%-" w_id "s  %-" w_name "s  %-" w_img "s  %-" w_status "s  %s\n",
            "CONTAINER ID", "NAMES", "IMAGE", "STATUS", "PORTS"
        pad_len = w_id + 2 + w_name + 2 + w_img + 2 + w_status + 2
    } else {
        printf "%-" w_id "s  %-" w_name "s  %-" w_status "s  %s\n",
            "CONTAINER ID", "NAMES", "STATUS", "PORTS"
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

        delete port_arr
        np = split(ports_raw[i], port_arr, ", ")

        if (show_image)
            printf row_fmt, id[i], name[i], img[i], status_raw[i], (np > 0 ? port_arr[1] : "")
        else
            printf row_fmt, id[i], name[i], status_raw[i], (np > 0 ? port_arr[1] : "")

        for (j = 2; j <= np; j++)
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

    dsi() {
        local data; data=$(_ds_data)
        [[ "$1" == "--sort" ]] && data=$(echo "$data" | sort -t$'\t' -k2)
        echo "$data" | _ds_fmt --image
    }

    dss()  { ds  --sort }  # ds,  sorted by name
    dssi() { dsi --sort }  # dsi, sorted by name
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
    docker_check_root() {
        echo "--- Docker Container Security Check ---"

        for container_id in $(docker ps -q); do
            local container_name STATUS_ICON DOCKER_SOCK_MOUNTED container_id_full container_uid HOST_ROOT_PIDS
            container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/\///')
            STATUS_ICON="✅"
            DOCKER_SOCK_MOUNTED=false

            if docker inspect "$container_id" --format '{{json .Mounts}}' | grep -q '/var/run/docker.sock'; then
                STATUS_ICON="⚠️"
                DOCKER_SOCK_MOUNTED=true
            fi

            container_id_full=$(docker exec "$container_id" id 2>/dev/null)
            container_uid=$(echo "$container_id_full" | grep -oP 'uid=\K\d+')
            HOST_ROOT_PIDS=$(docker top "$container_id" -eo uid,pid,cmd 2>/dev/null | awk '$1 == "0" && $1 != "UID" { print $0 }')

            [[ -n "$HOST_ROOT_PIDS" ]] && STATUS_ICON="⚠️"

            if [[ -z "$container_uid" ]]; then
                echo "⚠️  $container_name (${container_id:0:12}): UNDETERMINED (id tool missing)"
            elif [[ "$container_uid" -eq 0 ]]; then
                echo "⚠️  $container_name (${container_id:0:12}): ROOT (UID 0)!"
            else
                echo "$STATUS_ICON $container_name (${container_id:0:12}): $container_id_full"
            fi

            [[ "$DOCKER_SOCK_MOUNTED" == true ]] && echo "   -> 🚨 DOCKER_SOCK MOUNTED!"
            if [[ -n "$HOST_ROOT_PIDS" ]]; then
                echo "   -> 🚨 Host-root processes (UID/PID/CMD):"
                echo "$HOST_ROOT_PIDS" | sed 's/^/      * /'
            fi
        done

        echo "--- End of Check ---"
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
