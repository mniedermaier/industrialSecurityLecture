#!/usr/bin/env bash
#
# Automate the OpenPLC web-UI dance so the Modbus listener is open
# before anyone runs Lab 02.
#
# Without this, OpenPLC starts with no program loaded and port 502 is
# closed -- which is exactly what Lab 02 step 3 fixes manually. This
# script does the same thing over the web UI API:
#
#   1. log in with the default credentials,
#   2. upload bachelor/labs/_stack/scripts/ladder/conveyor.st,
#   3. save and compile the program,
#   4. start the PLC.
#
# Idempotent: re-running it just overwrites the previously-uploaded
# program. Safe to call from CI or from `preflight.sh`.
#
# Usage:
#   bachelor/labs/_stack/bootstrap-openplc.sh          # use defaults
#   bachelor/labs/_stack/bootstrap-openplc.sh --user openplc --pass openplc
#
# Exits 0 on success, non-zero with a diagnostic message otherwise.

set -u
set -o pipefail

# ---- defaults -------------------------------------------------------
HOST="${OPLC_HOST:-127.0.0.1:8080}"
USER="${OPLC_USER:-openplc}"
PASS="${OPLC_PASS:-openplc}"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROGRAM="${SCRIPT_DIR}/scripts/ladder/conveyor.st"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)    HOST="$2"; shift 2 ;;
    --user)    USER="$2"; shift 2 ;;
    --pass)    PASS="$2"; shift 2 ;;
    --program) PROGRAM="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $1"; exit 2 ;;
  esac
done

[[ -f "${PROGRAM}" ]] || { echo "FATAL: program not found: ${PROGRAM}"; exit 2; }
command -v curl >/dev/null || { echo "FATAL: curl is required"; exit 2; }

COOKIES="$(mktemp -t oplc-cookies.XXXXXX)"
TMP_HTML="$(mktemp -t oplc-page.XXXXXX)"
trap 'rm -f "${COOKIES}" "${TMP_HTML}"' EXIT

URL="http://${HOST}"

say () { printf '  %s\n' "$*"; }
die () { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# ---- 1. wait for the web UI to be reachable -------------------------
say "Waiting for OpenPLC web UI at ${URL} ..."
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w "%{http_code}" "${URL}/login" | grep -qx 200; then
    break
  fi
  sleep 1
  if (( i == 30 )); then
    die "OpenPLC did not come up at ${URL} within 30s. Is the container running?"
  fi
done

# ---- 2. log in ------------------------------------------------------
say "Logging in as ${USER} ..."
curl -s -c "${COOKIES}" -L \
  -X POST -d "username=${USER}&password=${PASS}" \
  "${URL}/login" -o /dev/null \
  || die "login request failed"

# A failed login leaves us back on the login page with no session.
# A successful login lets us GET /dashboard.
if ! curl -s -b "${COOKIES}" "${URL}/dashboard" | grep -q "Dashboard"; then
  die "Login failed for user '${USER}'. Check OPLC_USER / OPLC_PASS."
fi

# ---- 3. upload the program ------------------------------------------
say "Uploading $(basename "${PROGRAM}") ..."
curl -s -b "${COOKIES}" -F "file=@${PROGRAM}" \
  "${URL}/upload-program" -o "${TMP_HTML}" \
  || die "upload-program POST failed"

# OpenPLC assigns a random NNNN.st filename and exposes it via two
# hidden inputs in the metadata form. We need both to save.
PROG_FILE="$(grep -oP "value='[0-9]+\.st'" "${TMP_HTML}" | head -1 | cut -d\' -f2)"
EPOCH="$(grep -oP "value='[0-9]+'" "${TMP_HTML}" | grep -v '\.st' | head -1 | cut -d\' -f2)"
[[ -n "${PROG_FILE}" && -n "${EPOCH}" ]] \
  || die "could not parse the uploaded filename / epoch from the response"

# ---- 4. save program metadata (this also triggers compile) ----------
say "Saving program metadata (file=${PROG_FILE}) ..."
curl -s -b "${COOKIES}" -X POST \
  -d "prog_name=conveyor&prog_descr=bootstrap&prog_file=${PROG_FILE}&epoch_time=${EPOCH}" \
  "${URL}/upload-program-action" -o /dev/null \
  || die "upload-program-action failed"

# ---- 5. compile -----------------------------------------------------
say "Compiling ..."
curl -s -b "${COOKIES}" "${URL}/compile-program?file=${PROG_FILE}" -o /dev/null \
  || die "compile-program failed"

# Compile is async server-side; give it a few seconds before starting.
sleep 6

# ---- 6. start the PLC -----------------------------------------------
say "Starting PLC ..."
curl -s -b "${COOKIES}" "${URL}/start_plc" -o /dev/null \
  || die "start_plc failed"

# ---- 7. verify ------------------------------------------------------
sleep 3
if curl -s -b "${COOKIES}" "${URL}/dashboard" | grep -q "Status: <i>Running</i>"; then
  say "OpenPLC is running 'conveyor'. Modbus on 127.0.0.1:502 is open."
else
  die "PLC did not transition to Running. Check the OpenPLC logs."
fi
