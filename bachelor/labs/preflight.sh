#!/usr/bin/env bash
#
# Pre-flight smoke-test for the Bachelor lab stack.
#
# Run this from the repo root (or anywhere) before Day 1 to catch
# broken images, missing services, or environment quirks while you
# still have time to fix them.
#
# Exits 0 on full pass, non-zero with a per-check summary otherwise.
#
# Usage:
#   bachelor/labs/preflight.sh
#   bachelor/labs/preflight.sh --keep      # leave the stack running
#   bachelor/labs/preflight.sh --pull      # docker compose pull first

set -u
set -o pipefail

# --- locate the stack regardless of where we are called from ---------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STACK_DIR="${SCRIPT_DIR}/_stack"
cd "${STACK_DIR}" || { echo "FATAL: cannot cd to ${STACK_DIR}"; exit 2; }

KEEP=0
PULL=0
for arg in "$@"; do
  case "$arg" in
    --keep)      KEEP=1 ;;
    --pull)      PULL=1 ;;
    --bootstrap) ;;  # accepted for back-compat; bootstrap is automatic now.
    -h|--help)
      sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 2 ;;
  esac
done

# --- colour output (skip if not a TTY) -------------------------------
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YEL=$'\033[0;33m'; BOLD=$'\033[1m'; OFF=$'\033[0m'
else
  GREEN=""; RED=""; YEL=""; BOLD=""; OFF=""
fi

PASS=()
FAIL=()

check () {
  local name="$1"; shift
  printf "  %-55s " "${name}"
  if "$@" >/tmp/preflight-$$.out 2>&1; then
    echo "${GREEN}PASS${OFF}"
    PASS+=("$name")
  else
    echo "${RED}FAIL${OFF}"
    FAIL+=("$name")
    sed 's/^/      | /' /tmp/preflight-$$.out | head -10
  fi
  rm -f /tmp/preflight-$$.out
}

# --- prerequisites ---------------------------------------------------
echo "${BOLD}[1/4] Prerequisites${OFF}"
check "docker installed"           command -v docker
check "docker compose v2"          docker compose version
check "host has at least 3 GB free in /var/lib/docker (heuristic)" \
  bash -c 'df -B1G /var/lib/docker 2>/dev/null | awk "NR==2 { exit (\$4 < 3) }"'

if (( ${#FAIL[@]} > 0 )); then
  echo
  echo "${RED}Prerequisites missing -- fix these before running the labs.${OFF}"
  exit 1
fi

# --- bring up the stack ---------------------------------------------
echo
echo "${BOLD}[2/4] Stack startup${OFF}"
if (( PULL )); then
  echo "  pulling images (this can take a few minutes)..."
  docker compose pull >/dev/null 2>&1 || true
fi
check "docker compose up -d"       docker compose up -d
echo "  waiting for openplc-init to finish bootstrapping the PLC..."
# Poll until the one-shot init exits. Cap at 60 s so a stuck pull or
# broken healthcheck surfaces as a FAIL rather than a hang.
INIT_OK=0
for _ in $(seq 1 60); do
  state="$(docker inspect is-openplc-init --format '{{.State.Status}}:{{.State.ExitCode}}' 2>/dev/null || true)"
  case "$state" in
    exited:0) INIT_OK=1; break ;;
    exited:*) break ;;
  esac
  sleep 1
done
check "openplc-init completed (PLC programmed)" \
  bash -c "[ $INIT_OK = 1 ]"

# Service-up checks
for svc in landing openplc opcua mqtt student zeek; do
  check "service ${svc} is Up" \
    bash -c "docker compose ps --status running --services | grep -qx ${svc}"
done

# Landing page sanity (Lab 02 students start here)
check "landing page serves http://127.0.0.1:8000" \
  bash -c 'curl -sf -o /dev/null http://127.0.0.1:8000/'
check "landing page exposes lab PDFs at /labs/" \
  bash -c 'curl -sf -o /dev/null http://127.0.0.1:8000/labs/02-ics-fundamentals/02-ics-fundamentals-lab.pdf'

# --- lab-by-lab smoke tests -----------------------------------------
echo
echo "${BOLD}[3/4] Lab smoke tests${OFF}"

# The PLC was already programmed by the openplc-init sidecar above, so
# Modbus on port 502 must be open by now.
check "Lab 02/04/06 -- Modbus read returns 10 registers" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/modbus_read.py | grep -q "Registers 0..9"'

# Lab 04 -- OPC UA browse
check "Lab 04 -- OPC UA browse connects" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/opcua_browse.py 2>&1 | grep -q "Connected to:"'

# Lab 04 -- tcpdump in the student container
check "Lab 04 -- tcpdump available in student" \
  docker compose exec -T student tcpdump --version

# Lab 06 -- safe nmap from the student container
check "Lab 06 -- nmap available in student" \
  docker compose exec -T student nmap --version

# Lab 08 -- Zeek shares OpenPLC netns and produces a log on Modbus traffic.
docker compose exec -T student python3 /labs/scripts/modbus_read.py >/dev/null 2>&1 || true
sleep 3
check "Lab 08 -- Zeek wrote conn.log"               test -f zeek-logs/conn.log
check "Lab 08 -- Zeek wrote modbus.log (port 502)"  test -f zeek-logs/modbus.log
docker compose exec -T student python3 /labs/scripts/modbus_inject.py >/dev/null 2>&1 || true
sleep 3
check "Lab 08 -- ModbusWatch notice triggered" \
  bash -c 'test -f zeek-logs/notice.log && grep -q "ModbusWatch::Unsolicited_Write" zeek-logs/notice.log'

# --- teardown --------------------------------------------------------
echo
echo "${BOLD}[4/4] Teardown${OFF}"
if (( KEEP )); then
  echo "  --keep given: leaving the stack running. Tear down later with:"
  echo "    cd $(pwd) && docker compose down -v"
else
  docker compose down -v >/dev/null 2>&1 && echo "  stack torn down."
fi

# --- summary ---------------------------------------------------------
echo
echo "${BOLD}Summary${OFF}"
echo "  ${GREEN}PASS${OFF}: ${#PASS[@]}"
echo "  ${RED}FAIL${OFF}: ${#FAIL[@]}"

if (( ${#FAIL[@]} > 0 )); then
  echo
  echo "${RED}Failing checks:${OFF}"
  for f in "${FAIL[@]}"; do echo "  - $f"; done
  echo
  echo "Fix these before Day 1. Re-run this script after each fix."
  exit 1
fi

echo
echo "${GREEN}All required checks passed.${OFF} You are ready to run the course."
