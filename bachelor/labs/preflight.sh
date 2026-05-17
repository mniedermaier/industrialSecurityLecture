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
BOOTSTRAP=0
for arg in "$@"; do
  case "$arg" in
    --keep)      KEEP=1 ;;
    --pull)      PULL=1 ;;
    --bootstrap) BOOTSTRAP=1 ;;
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
WARN=()

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

# Same as check() but a failure becomes a WARN, not a FAIL. Use for
# steps that depend on a one-time manual setup (e.g.\ OpenPLC needs a
# program uploaded via the web UI before its Modbus listener opens).
warn_check () {
  local name="$1"; shift
  printf "  %-55s " "${name}"
  if "$@" >/tmp/preflight-$$.out 2>&1; then
    echo "${GREEN}PASS${OFF}"
    PASS+=("$name")
  else
    echo "${YEL}WARN${OFF}"
    WARN+=("$name")
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
echo "  waiting 15 s for services to settle..."
sleep 15

# Service-up checks
for svc in openplc opcua mqtt student zeek; do
  check "service ${svc} is Up" \
    bash -c "docker compose ps --status running --services | grep -qx ${svc}"
done

# --- lab-by-lab smoke tests -----------------------------------------
echo
echo "${BOLD}[3/4] Lab smoke tests${OFF}"

# Optional: auto-bootstrap OpenPLC so port 502 is open before any
# Modbus-dependent check runs. Without this the Lab 02 / Zeek checks
# WARN until a lecturer uploads the program manually via the web UI.
if (( BOOTSTRAP )); then
  echo "  --bootstrap given: priming OpenPLC with conveyor.st ..."
  if "${STACK_DIR}/bootstrap-openplc.sh" >/tmp/preflight-bootstrap-$$.out 2>&1; then
    echo "  ${GREEN}bootstrap OK${OFF}"
  else
    echo "  ${YEL}bootstrap failed (continuing with WARN-only checks):${OFF}"
    sed 's/^/      | /' /tmp/preflight-bootstrap-$$.out | head -10
  fi
  rm -f /tmp/preflight-bootstrap-$$.out
fi

# Probe whether OpenPLC has a running program. The Modbus listener on
# port 502 is only bound once a program is uploaded and started via the
# web UI -- that is Lab 02 step 3. Without it, all Modbus-dependent
# checks are expected to fail; we surface this as a WARN, not a FAIL.
if docker compose exec -T student python3 /labs/scripts/modbus_read.py 2>&1 | grep -q "Registers 0..9"; then
  PLC_RUNNING=1
else
  PLC_RUNNING=0
  echo "  ${YEL}note:${OFF} OpenPLC has no running program yet (Lab 02 step 3 still pending);"
  echo "         Modbus-dependent checks below will WARN, not FAIL."
fi

# Lab 02 / 04 / 06 -- Modbus read
warn_check "Lab 02/04/06 -- Modbus read returns 10 registers" \
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
# Only meaningful if the PLC is actually running.
if (( PLC_RUNNING )); then
  docker compose exec -T student python3 /labs/scripts/modbus_read.py >/dev/null 2>&1 || true
  sleep 3
  check "Lab 08 -- Zeek wrote conn.log"               test -f zeek-logs/conn.log
  check "Lab 08 -- Zeek wrote modbus.log (port 502)"  test -f zeek-logs/modbus.log
  docker compose exec -T student python3 /labs/scripts/modbus_inject.py >/dev/null 2>&1 || true
  sleep 3
  check "Lab 08 -- ModbusWatch notice triggered" \
    bash -c 'test -f zeek-logs/notice.log && grep -q "ModbusWatch::Unsolicited_Write" zeek-logs/notice.log'
else
  warn_check "Lab 08 -- Zeek wrote conn.log"              test -f zeek-logs/conn.log
  warn_check "Lab 08 -- Zeek wrote modbus.log (port 502)" test -f zeek-logs/modbus.log
  warn_check "Lab 08 -- ModbusWatch notice triggered" \
    bash -c 'test -f zeek-logs/notice.log && grep -q "ModbusWatch::Unsolicited_Write" zeek-logs/notice.log'
fi

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
echo "  ${YEL}WARN${OFF}: ${#WARN[@]}"
echo "  ${RED}FAIL${OFF}: ${#FAIL[@]}"

if (( ${#WARN[@]} > 0 )); then
  echo
  echo "${YEL}WARN checks (expected unless OpenPLC has a running program):${OFF}"
  for w in "${WARN[@]}"; do echo "  - $w"; done
  echo
  echo "To clear the warnings: bring up the stack, open"
  echo "  http://127.0.0.1:8080 (OpenPLC web UI, default openplc / openplc),"
  echo "upload bachelor/labs/_stack/scripts/ladder/conveyor.st, click Start PLC,"
  echo "then re-run this script with --keep so the upload persists between runs."
fi

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
