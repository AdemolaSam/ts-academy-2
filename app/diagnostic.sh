#!/usr/bin/env bash

set -u

usage() {
    cat <<'EOF'
Usage: diagnostic <command> [arguments]

Commands:
  system            Display system information
  network <host>    Resolve and check connectivity to a host
  disk              Display disk usage
  help              Show this message

Exit codes:
  0  success
  1  operational failure (e.g. host cannot be resolved)
  2  invalid command or missing/invalid argument
EOF
}

cmd_system() {
    echo "================ System Information ========================"
    echo "Hostname : $(hostname)"
    echo "User     : $(whoami)"
    echo "Date     : $(date '+%Y-%m-%d %H:%M:%S %Z')"
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "OS       : ${PRETTY_NAME:-unknown}"
    fi
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"
    echo "CPU      : $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//')"
    echo "CPU count: $(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo unknown)"
    echo
    echo "----- Memory -----"
    free -h 2>/dev/null || echo "Memory information unavailable"
    return 0
}

cmd_network() {
    local host="${1:-}"

    if [[ -z "$host" ]]; then
        echo "Error: 'network' requires a host argument" >&2
        echo "Usage: diagnostic network <host>" >&2
        return 2
    fi

    echo "===== Network Check: $host ====="

    local resolved
    resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -n1)

    if [[ -z "$resolved" ]]; then
        echo "Resolution: FAILED to resolve '$host'" >&2
        return 1
    fi
    echo "Resolution: $host -> $resolved"

    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Ping      : reachable"
    else
        echo "Ping      : no reply (ICMP may be blocked)"
    fi
    return 0
}

cmd_disk() {
    echo "===== Disk Usage ====="
    df -hP
}

main() {
    if [[ $# -eq 0 ]]; then
        echo "Error: no command given" >&2
        usage >&2
        return 2
    fi

    local command="$1"
    shift

    case "$command" in
        system)  cmd_system ;;
        network) cmd_network "$@" ;;
        disk)    cmd_disk ;;
        help|-h|--help) usage ;;
        *)
            echo "Error: unknown command '$command'" >&2
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
exit $?
