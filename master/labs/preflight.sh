#!/usr/bin/env bash
# Master labs preflight -- verify host-side prerequisites before a session.
#
# Usage:
#   ./preflight.sh             # run all checks; non-zero exit if anything required is missing
#   ./preflight.sh --lab NN    # only check prerequisites for one lab (NN = 01..08)
#
# The script does NOT install anything; it only reports presence / absence
# and prints a per-lab verdict. The Bachelor `bachelor/labs/_stack/`
# services are checked separately because most Master labs assume the
# Bachelor stack is up.

set -u

# --- pretty-printing ------------------------------------------------------
if [[ -t 1 ]]; then
    GREEN=$(printf '\033[32m'); RED=$(printf '\033[31m'); YEL=$(printf '\033[33m'); BOLD=$(printf '\033[1m'); RST=$(printf '\033[0m')
else
    GREEN=""; RED=""; YEL=""; BOLD=""; RST=""
fi
ok()    { echo "  ${GREEN}OK${RST}      $1"; }
miss()  { echo "  ${RED}MISSING${RST} $1"; FAIL=1; }
warn()  { echo "  ${YEL}WARN${RST}    $1"; }
header(){ echo; echo "${BOLD}== Lab $1 -- $2 ==${RST}"; }

# --- single-lab filter ----------------------------------------------------
ONLY=""
if [[ "${1:-}" == "--lab" && -n "${2:-}" ]]; then
    ONLY=$2
fi
run_lab() { [[ -z "$ONLY" || "$1" == "$ONLY" ]]; }

# --- helpers --------------------------------------------------------------
FAIL=0

have_cmd() { command -v "$1" >/dev/null 2>&1; }
check_cmd() {                                     # check_cmd <command> <pretty-name>
    if have_cmd "$1"; then ok "$2 (\`$1\`)"
    else miss "$2 (\`$1\`) -- install via your distro's package manager"; fi
}
check_py_module() {                               # check_py_module <module> <pretty-name>
    if python3 -c "import $1" >/dev/null 2>&1; then ok "$2 (Python module \`$1\`)"
    else miss "$2 (Python module \`$1\`) -- \`pip install $1\`"; fi
}

# --- Bachelor stack health (most Master labs assume it is up) -------------
echo "${BOLD}== Bachelor lab stack (most Master labs depend on it) ==${RST}"
if have_cmd docker; then
    ok "docker"
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx is-openplc; then
        ok "is-openplc container running"
    else
        warn "is-openplc not running -- bring the Bachelor stack up with: cd bachelor/labs/_stack && docker compose up -d"
    fi
else
    miss "docker -- install Docker Engine + Compose plugin"
fi

# --- Lab 01: Firmware RE --------------------------------------------------
if run_lab 01; then
    header 01 "Firmware Reverse Engineering"
    check_cmd binwalk        "binwalk firmware carver"
    check_cmd file           "file (libmagic)"
    check_cmd strings        "strings (binutils)"
    check_cmd nm             "nm (binutils)"
    check_cmd objdump        "objdump (binutils)"
    check_cmd readelf        "readelf (binutils)"
    check_cmd strace         "strace"
    if have_cmd unsquashfs || have_cmd sasquatch; then
        ok "SquashFS extractor (\`unsquashfs\` or \`sasquatch\`)"
    else
        miss "SquashFS extractor -- install \`squashfs-tools\` (unsquashfs) or build \`sasquatch\`"
    fi
    if have_cmd qemu-arm-static || have_cmd qemu-aarch64-static || have_cmd qemu-mips-static; then
        ok "qemu-user-static (at least one architecture present)"
    else
        miss "qemu-user-static -- install \`qemu-user-static\` and \`binfmt-support\`"
    fi
    if have_cmd ghidraRun || [[ -d "${GHIDRA_INSTALL_DIR:-}" ]]; then
        ok "Ghidra (in PATH or via \$GHIDRA_INSTALL_DIR)"
    else
        warn "Ghidra not detected -- required for decompilation step. Install from github.com/NationalSecurityAgency/ghidra/releases and put \`ghidraRun\` in PATH, or set \$GHIDRA_INSTALL_DIR."
    fi
fi

# --- Lab 02: PLC Ladder RE ------------------------------------------------
if run_lab 02; then
    header 02 "PLC Ladder Reverse Engineering"
    check_cmd nm             "nm (binutils)"
    check_cmd objdump        "objdump (binutils)"
    if have_cmd r2 || have_cmd radare2; then
        ok "radare2 (\`r2\`)"
    else
        warn "radare2 not found -- Ghidra is the alternative; either is acceptable."
    fi
    check_cmd python3        "Python 3 (for the \`plcrev\` helper script)"
fi

# --- Lab 03: Advanced Protocols -------------------------------------------
if run_lab 03; then
    header 03 "Advanced ICS Protocols"
    if have_cmd wireshark || have_cmd tshark; then
        ok "Wireshark / tshark"
    else
        miss "Wireshark or tshark -- needed for GOOSE / SV / DLMS / S7comm-plus dissection"
    fi
    check_cmd python3       "Python 3"
    check_py_module scapy   "scapy (incl. \`scapy.contrib.scada.goose\`)"
    if python3 -c "import boofuzz" >/dev/null 2>&1; then
        ok "boofuzz (Python module, for the fuzzing stretch)"
    else
        warn "boofuzz not installed -- only required for the optional fuzzing stretch goal. \`pip install boofuzz\` when you get there."
    fi
fi

# --- Lab 04: Offensive ICS in Authorised Labs -----------------------------
if run_lab 04; then
    header 04 "Offensive ICS in Authorised Labs"
    check_cmd nmap          "nmap"
    check_cmd docker        "docker (everything attacker-side runs inside \`is-student\`)"
    # pymodbus / asyncua live in the is-student container, not on the host.
fi

# --- Lab 05: Secure-by-Design Architectures -------------------------------
if run_lab 05; then
    header 05 "Secure-by-Design Architectures"
    warn "Browser-based design lab. No host tooling required beyond a Markdown / LaTeX editor and a diagram tool (draw.io desktop or excalidraw.com)."
fi

# --- Lab 06: Threat Intelligence for OT -----------------------------------
if run_lab 06; then
    header 06 "Threat Intelligence for OT"
    check_cmd python3       "Python 3"
    check_py_module stix2   "STIX 2.1 toolkit (\`stix2\`)"
fi

# --- Lab 07: Safety / Security Co-Engineering -----------------------------
if run_lab 07; then
    header 07 "Safety / Security Co-Engineering"
    warn "Paper Cyber-HAZOP lab. No host tooling required beyond a Markdown / LaTeX editor."
fi

# --- Lab 08: Research Methods and Seminar Work ----------------------------
if run_lab 08; then
    header 08 "Research Methods and Seminar Work"
    check_cmd python3       "Python 3"
    check_cmd pip           "pip (or python3-pip)"
    check_cmd git           "git (for archiving the artefact + DOI flow)"
    if have_cmd cosign; then
        ok "cosign (optional integrity-signing stretch)"
    else
        warn "cosign not installed -- only needed for the optional integrity-signing stretch."
    fi
fi

# --- verdict --------------------------------------------------------------
echo
if [[ $FAIL -eq 0 ]]; then
    echo "${GREEN}${BOLD}preflight OK${RST} -- nothing load-bearing is missing."
    exit 0
else
    echo "${RED}${BOLD}preflight FAILED${RST} -- install the items marked MISSING above and rerun."
    exit 1
fi
