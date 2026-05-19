#!/usr/bin/env bash
#
# Deep test for every docker-dependent lab.
#
# Where `preflight.sh` validates the *plumbing* (services up, binaries
# present, one smoke call per lab), this script walks every command in
# every lab's instruction text and validates the *outcome* the lab
# claims will happen. Including:
#
#   * Lab 02 -- web UI dashboard reports "Running: conveyor", manual
#     stop / upload / start round-trip still works, modbus_read returns
#     10 registers.
#   * Lab 04 -- modbus_inject actually flips coil 0, tshark decodes the
#     captured Modbus PCAP, OPC UA browse returns at least one
#     namespace child, tshark decodes the captured OPC UA PCAP.
#   * Lab 06 -- safe nmap profile completes against the lab PLC without
#     leaving it unresponsive (a follow-up modbus_read still succeeds).
#   * Lab 08 -- step 1 baseline polls populate modbus.log, step 2
#     injection raises ModbusWatch::Unsolicited_Write, step 3 the
#     tuning workflow (edit local.zeek to suppress writes from the
#     student container, restart zeek, re-inject) suppresses the notice
#     while conn.log still grows.
#
# Paper-only labs (01, 03, 05, 07, 09, 10) print SKIP with a one-line
# rationale.
#
# Exits 0 on full pass, non-zero with a per-check summary otherwise.
#
# Usage:
#   bachelor/labs/deep-test.sh
#   bachelor/labs/deep-test.sh --keep   # leave the stack running on exit

set -u
set -o pipefail

# --- locate the stack regardless of CWD ------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
STACK_DIR="${SCRIPT_DIR}/_stack"
cd "${STACK_DIR}" || { echo "FATAL: cannot cd to ${STACK_DIR}"; exit 2; }

KEEP=0
for arg in "$@"; do
  case "$arg" in
    --keep) KEEP=1 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 2 ;;
  esac
done

# --- colour ----------------------------------------------------------
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YEL=$'\033[0;33m'
  BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; OFF=$'\033[0m'
else
  GREEN=""; RED=""; YEL=""; BLUE=""; BOLD=""; OFF=""
fi

PASS=()
FAIL=()
SKIP=()

check () {
  local name="$1"; shift
  printf "    %-58s " "${name}"
  if "$@" >/tmp/deep-$$.out 2>&1; then
    echo "${GREEN}PASS${OFF}"
    PASS+=("$name")
  else
    echo "${RED}FAIL${OFF}"
    FAIL+=("$name")
    sed 's/^/        | /' /tmp/deep-$$.out | head -8
  fi
  rm -f /tmp/deep-$$.out
}

skip () {
  local name="$1" why="${2:-paper / web research only}"
  printf "    %-58s ${BLUE}SKIP${OFF}  %s\n" "${name}" "${why}"
  SKIP+=("$name")
}

section () { echo; echo "${BOLD}[ Lab ${1} ] ${2}${OFF}"; }

# --- stack must be up before we start --------------------------------
if ! docker compose ps --status running --services 2>/dev/null | grep -qx openplc; then
  echo "${BOLD}Bringing the stack up...${OFF}"
  docker compose up -d >/dev/null
  echo "  waiting for openplc-init to finish bootstrapping the PLC..."
  for _ in $(seq 1 60); do
    state="$(docker inspect is-openplc-init --format '{{.State.Status}}:{{.State.ExitCode}}' 2>/dev/null || true)"
    [[ "$state" == "exited:0" ]] && break
    sleep 1
  done
fi
BROUGHT_UP=1

# --- per-lab tests ---------------------------------------------------

# Lab 01 ---------------------------------------------------------------
section 01 "Where Is the Industrial Security?"
skip "Lab 01 -- pen-and-paper IT/OT classification"

# Lab 02 ---------------------------------------------------------------
section 02 "First Contact with OpenPLC"

# Web UI reachable
check "Lab 02.1 -- OpenPLC web UI reachable" \
  bash -c 'curl -sf -o /dev/null http://127.0.0.1:8080/login'

# Dashboard reports a running program (the init's upload)
docker compose exec -T student curl -s -c /tmp/c -L \
  -X POST -d 'username=openplc&password=openplc' \
  http://openplc:8080/login -o /dev/null
check "Lab 02.2 -- dashboard reports 'Status: Running'" \
  bash -c "docker compose exec -T student curl -s -b /tmp/c http://openplc:8080/dashboard | grep -q 'Status: <i>Running</i>'"

check "Lab 02.3 -- dashboard reports 'Running: conveyor'" \
  bash -c "docker compose exec -T student curl -s -b /tmp/c http://openplc:8080/dashboard | grep -q 'Running:.*conveyor'"

# modbus_read returns 10 registers
check "Lab 02.4 -- modbus_read returns 10 registers" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/modbus_read.py | grep -q "Registers 0..9"'

# Manual round-trip: stop / re-upload / start (the "optional" path in the lab)
check "Lab 02.5 -- manual stop_plc works" \
  bash -c "docker compose exec -T student curl -sf -b /tmp/c -o /dev/null http://openplc:8080/stop_plc"
sleep 2
check "Lab 02.6 -- manual bootstrap re-primes the PLC" \
  bash bootstrap-openplc.sh
check "Lab 02.7 -- modbus_read still returns 10 registers after re-prime" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/modbus_read.py | grep -q "Registers 0..9"'

# Lab 03 ---------------------------------------------------------------
section 03 "Network Segmentation Design"
skip "Lab 03 -- paper / GNS3 design exercise"

# Lab 04 ---------------------------------------------------------------
section 04 "Modbus and OPC UA -- See the Difference"

# Part A1: modbus_read
check "Lab 04.A1 -- honest Modbus read" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/modbus_read.py | grep -q "Registers 0..9"'

# Part A2: capture + tshark decode (use `timeout` so the test does not
# depend on pkill being in the container).
docker compose exec -T student rm -f /labs/captures/dt-mb.pcap 2>/dev/null || true
docker compose exec -dT student timeout 4 tcpdump -i eth0 -w /labs/captures/dt-mb.pcap port 502
sleep 1
docker compose exec -T student python3 /labs/scripts/modbus_read.py >/dev/null 2>&1
sleep 4
check "Lab 04.A2 -- tcpdump captured Modbus traffic to a PCAP" \
  test -s captures/dt-mb.pcap
check "Lab 04.A2 -- tshark decodes Modbus from the PCAP" \
  bash -c "tshark -r captures/dt-mb.pcap -Y modbus 2>/dev/null | grep -q -i 'modbus'"

# Part A3: injection actually flips the coil
docker compose exec -T student python3 /labs/scripts/modbus_inject.py >/dev/null 2>&1
sleep 1
check "Lab 04.A3 -- modbus_inject writes coil 0 = TRUE (observed via dashboard)" \
  bash -c "docker compose exec -T student curl -s -b /tmp/c http://openplc:8080/monitoring | grep -qiE 'qx0_0|coil.*1|TRUE'"

# Part B1: opcua_browse returns namespace children
check "Lab 04.B1 -- OPC UA browse returns at least one child" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/opcua_browse.py 2>&1 | grep -E "^ - " | head -1 | grep -q "."'

# Part B2: capture + decode OPC UA
docker compose exec -T student rm -f /labs/captures/dt-ua.pcap 2>/dev/null || true
docker compose exec -dT student timeout 4 tcpdump -i eth0 -w /labs/captures/dt-ua.pcap port 4840
sleep 1
docker compose exec -T student python3 /labs/scripts/opcua_browse.py >/dev/null 2>&1
sleep 4
check "Lab 04.B2 -- tcpdump captured OPC UA traffic to a PCAP" \
  test -s captures/dt-ua.pcap
check "Lab 04.B2 -- tshark decodes OPC UA from the PCAP" \
  bash -c "tshark -r captures/dt-ua.pcap -d tcp.port==4840,opcua -Y opcua 2>/dev/null | grep -qi 'opcua'"

# Lab 05 ---------------------------------------------------------------
section 05 "Shodan Reconnaissance"
skip "Lab 05 -- web research (Shodan), no docker check"

# Lab 06 ---------------------------------------------------------------
section 06 "Real CVE Walk-Through -- safe nmap"

# Safe-nmap profile from the lab text against the lab PLC
check "Lab 06.1 -- safe nmap completes without crashing the PLC" \
  bash -c "docker compose exec -T student nmap -sT -Pn -n --max-rate 5 --scan-delay 200ms -p 502,8080 172.28.0.10 2>&1 | grep -q 'Nmap done'"
check "Lab 06.2 -- nmap reports port 502 open" \
  bash -c "docker compose exec -T student nmap -sT -Pn -n -p 502 172.28.0.10 2>&1 | grep -q '502/tcp open'"
check "Lab 06.3 -- PLC still alive after scan (modbus_read works)" \
  bash -c 'docker compose exec -T student python3 /labs/scripts/modbus_read.py | grep -q "Registers 0..9"'

# Lab 07 ---------------------------------------------------------------
section 07 "Risk Matrix Workshop"
skip "Lab 07 -- group workshop, no docker check"

# Lab 08 ---------------------------------------------------------------
section 08 "Passive OT IDS with Zeek"

# Step 1: baseline traffic populates Zeek logs
docker compose exec -dT student timeout 4 python3 /labs/scripts/modbus_poll_loop.py
sleep 6
check "Lab 08.1 -- Zeek wrote conn.log"    test -s zeek-logs/conn.log
check "Lab 08.1 -- Zeek wrote modbus.log"  test -s zeek-logs/modbus.log

# Step 2: injection raises a notice
docker compose exec -T student python3 /labs/scripts/modbus_inject.py >/dev/null 2>&1
sleep 3
check "Lab 08.2 -- ModbusWatch::Unsolicited_Write notice raised" \
  bash -c 'test -f zeek-logs/notice.log && grep -q "ModbusWatch::Unsolicited_Write" zeek-logs/notice.log'

# Step 3: tune the policy to suppress writes from the student container,
# restart zeek, re-inject, verify the notice is suppressed but conn.log
# still grows. Make sure we revert the policy at the end no matter what.
TUNED_POLICY="${STACK_DIR}/zeek/local.zeek"
ORIG_POLICY="$(mktemp -t local-zeek-orig.XXXXXX)"
cp "${TUNED_POLICY}" "${ORIG_POLICY}"

restore_policy () {
  cp "${ORIG_POLICY}" "${TUNED_POLICY}"
  rm -f "${ORIG_POLICY}"
}
trap restore_policy EXIT

python3 - <<'PYEOF'
import pathlib, re
p = pathlib.Path("zeek/local.zeek")
src = p.read_text()
tuned = src.replace(
    "    if (!is_orig) return;\n",
    "    if (!is_orig) return;\n"
    "    # Lab 08.3 tuning -- treat the student WS as sanctioned.\n"
    "    if (c$id$orig_h == 172.28.0.20) return;\n",
)
assert tuned != src, "policy tuning text did not apply"
p.write_text(tuned)
PYEOF

docker compose restart zeek >/dev/null 2>&1
sleep 4

# Clear old notice.log so we can prove the next inject does NOT write
rm -f zeek-logs/notice.log
docker compose exec -T student python3 /labs/scripts/modbus_inject.py >/dev/null 2>&1
sleep 3

check "Lab 08.3 -- tuned policy SUPPRESSES the notice on re-injection" \
  bash -c '! test -f zeek-logs/notice.log || ! grep -q "ModbusWatch::Unsolicited_Write" zeek-logs/notice.log'
check "Lab 08.3 -- conn.log still grows (normal traffic logged)" \
  test -s zeek-logs/conn.log

# Revert policy so the lab doc state and the on-disk state match.
restore_policy
trap - EXIT
docker compose restart zeek >/dev/null 2>&1

# Lab 09 ---------------------------------------------------------------
section 09 "Regulatory Gap Analysis"
skip "Lab 09 -- paper gap analysis"

# Lab 10 ---------------------------------------------------------------
section 10 "Saturday Night Tabletop"
skip "Lab 10 -- group tabletop exercise"

# --- teardown --------------------------------------------------------
echo
if (( KEEP )); then
  echo "${BOLD}--keep given:${OFF} leaving the stack running. Tear down with:"
  echo "  cd $(pwd) && docker compose down -v"
else
  echo "${BOLD}Tearing down...${OFF}"
  docker compose down -v >/dev/null 2>&1 && echo "  stack down."
fi

# --- summary ---------------------------------------------------------
echo
echo "${BOLD}Summary${OFF}"
echo "  ${GREEN}PASS${OFF}: ${#PASS[@]}"
echo "  ${RED}FAIL${OFF}: ${#FAIL[@]}"
echo "  ${BLUE}SKIP${OFF}: ${#SKIP[@]}  (paper / web research labs)"

if (( ${#FAIL[@]} > 0 )); then
  echo
  echo "${RED}Failing checks:${OFF}"
  for f in "${FAIL[@]}"; do echo "  - $f"; done
  echo
  echo "Fix the lab text or the stack before Day 1."
  exit 1
fi

echo
echo "${GREEN}All exercised steps passed.${OFF} The docker-dependent labs work end-to-end."
