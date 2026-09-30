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

# VictoriaMetrics on pouchmaster, reached through its public Caddy front, so
# pushes no longer need the VPN / netbird mesh. Caddy only forwards POSTs to the
# write/import paths that carry the X-Metrics-Gate header (queries stay
# VPN-only); its secret is `keyring_helper vicmetrics`.
# RESTIC_METRICS_URL overrides the base URL (no trailing slash), e.g.
# http://100.64.131.43:8428 to go straight to VictoriaMetrics over netbird.
# RESTIC_METRICS_HOST[/_PORT] still selects that direct URL: pouchmaster's
# restic-verify.service (ansible roles/restic-verify) sets it to its own
# netbird_ip and has no vicmetrics keyring entry.
if [ -z "${RESTIC_METRICS_URL:-}" ] && [ -n "${RESTIC_METRICS_HOST:-}" ]; then
    RESTIC_METRICS_URL="http://${RESTIC_METRICS_HOST}:${RESTIC_METRICS_PORT:-8428}"
fi
RESTIC_METRICS_URL="${RESTIC_METRICS_URL:-https://metrics.dickten.info}"

# metrics_curl <curl args...>
#
# curl with the X-Metrics-Gate header added. The header goes in through a curl
# config on stdin (-K -), so the secret never shows up in argv / ps -- callers
# must not pass stdin data of their own. Only an https URL (the gate) reads
# the secret: a direct http://<netbird_ip>:8428 doesn't need it, and hosts like
# pouchmaster have no vicmetrics entry -- keyring_helper would prompt to create
# one on a tty. If the secret can't be read, the request goes out without it
# (a 403 at the gate).
metrics_curl() {
    local secret=""
    case "$RESTIC_METRICS_URL" in
        https://*) secret="$(keyring_helper vicmetrics </dev/null 2>/dev/null)" || secret="" ;;
    esac
    if [ -n "$secret" ]; then
        printf 'header = "X-Metrics-Gate: %s"\n' "$secret" | curl -K - "$@"
    else
        curl "$@"
    fi
}

# metrics_preflight <what>
#
# Probes the ingress with an empty POST to /api/v1/import: VictoriaMetrics
# answers 204 and stores nothing. /health can't be used -- the public gate is
# push-only (POST to write/import paths; everything else is a 403, see
# pouchmaster's Caddyfile in the ansible repo) -- and this also proves the gate
# secret is accepted. If unreachable (offline, gate secret missing/wrong),
# warns that this run's result won't reach Grafana and, when run
# interactively, asks whether to proceed anyway.
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
    if command -v curl >/dev/null 2>&1 \
       && ! metrics_curl -fsS --connect-timeout 3 -m 5 -o /dev/null \
            -X POST --data-binary '' "${RESTIC_METRICS_URL}/api/v1/import" 2>/dev/null
    then
        echo "!!! metrics host ${RESTIC_METRICS_URL} unreachable -- offline, or gate secret (keyring_helper vicmetrics) missing/wrong?" >&2
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
