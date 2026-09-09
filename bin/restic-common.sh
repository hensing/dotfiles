# Shared helpers for the restic/pcloud backup scripts (backup_photos,
# restic-verify-data). Not executable -- source it:
#   . "$(dirname "$0")/restic-common.sh"

# Grep pattern used everywhere in this codebase to detect a damaged/truncated
# pcloud repo from restic check output. restic's own exit code has been
# observed to miss real pack truncation on the pcloud link (2026-08-13,
# 2026-08-29), which is why this text-based check exists as a redundant
# safety net alongside the exit code -- keep both, and keep this pattern
# consistent everywhere it's used.
#
# Still relevant on the native sftp transport (restic-verify-data, backup_photos):
# an interrupted sftp write should fail the pack via restic's temp-name+rename,
# but a dropped transfer over the spotty USA->EU link could still leave a short
# pack, and check's exit code has under-reported that before.
RESTIC_DAMAGED_PATTERN='unexpected file size|repository contains errors|repository is damaged|damaged pack file'

# metrics_preflight <what> [vm_host] [vm_port]
#
# Probes the VictoriaMetrics host's /health endpoint. If unreachable (not on
# the VPN / netbird mesh), warns that this run's result won't reach Grafana
# and, when run interactively, asks whether to proceed anyway.
# RESTIC_METRICS_ASSUME_YES=1 skips the prompt; non-interactive (cron) always
# proceeds after warning -- the metrics push is best-effort regardless.
#
# Returns 0 to proceed, 1 if the user explicitly declined. Callers decide
# what "declined" means for them: a top-level script may just abort, while a
# sub-call (like restic-verify-data, invoked from backup_photos) should use a
# distinct exit code so its caller doesn't mistake "skipped, no signal" for
# "ran and failed".
metrics_preflight() {
    local what="$1"
    local vm_host="${2:-${RESTIC_METRICS_HOST:-100.64.131.43}}"
    local vm_port="${3:-${RESTIC_METRICS_PORT:-8428}}"
    if command -v curl >/dev/null 2>&1 \
       && ! curl -fsS --connect-timeout 3 -m 5 -o /dev/null \
            "http://${vm_host}:${vm_port}/health" 2>/dev/null
    then
        echo "!!! metrics host ${vm_host}:${vm_port} unreachable -- VPN / netbird down?" >&2
        echo "    The ${what} will still run, but this run won't be recorded in Grafana." >&2
        if [ -t 0 ] && [ -z "${RESTIC_METRICS_ASSUME_YES:-}" ]; then
            printf "    Proceed anyway? [y/N] " >&2
            read -r _ans
            case "${_ans:-}" in
                [yY]|[yY][eE][sS]) ;;
                *) echo "    aborted." >&2; return 1 ;;
            esac
        fi
    fi
    return 0
}
