# Master labs

The Master labs are deeper, multi-hour exercises (3–4 h each typical, 5–6 h
for the bigger ones) that assume the student has already done the Bachelor
course or its equivalent. Each lab is:

- `NN-topic/lab.tex` → `NN-topic-lab.pdf` — the student handout.
- `NN-topic/lab-solutions.tex` → `NN-topic-lab-solutions.pdf` — model
  answers + grading rubric.
- `Makefile` — calls the shared `template/lab.mk` rules.

Unlike the Bachelor labs, the Master labs **do not ship their own Docker
stack**. Most reuse the Bachelor `bachelor/labs/_stack/` services
(`is-openplc`, `is-opcua`, `is-mqtt`, `is-zeek`, `is-student`) and add
host-side tooling on top. The decision was deliberate: at Master level the
student is expected to install, version-pin, and reason about their
analysis tools themselves.

## Before you start a Master lab

1. **Bring up the Bachelor stack** (most Master labs assume it is
   running). From the repo root:
   ```bash
   cd bachelor/labs/_stack && docker compose up -d
   ```
   Confirm with `docker ps` that `is-openplc`, `is-opcua`, `is-mqtt`,
   `is-zeek`, `is-student` are all healthy.

2. **Run the Master preflight** (this directory):
   ```bash
   ./preflight.sh
   ```
   It checks the host-side prerequisites listed below, prints a one-line
   verdict per lab (OK / MISSING `<tool>`), and exits non-zero if anything
   load-bearing is absent.

3. **Read the lab PDF**. Each Master lab opens with a `goalbox` stating
   what you will produce and a `notebox` listing the assumed prior
   knowledge.

## Per-lab prerequisites

| Lab | What you need beyond the Bachelor stack |
|-----|-----------------------------------------|
| 01 Firmware RE | `binwalk`, `squashfs-tools` (`unsquashfs` / `sasquatch`), `qemu-user-static` (for `qemu-arm-static`), `binutils` (`strings`, `nm`, `objdump`, `file`, `readelf`), `strace`. **Ghidra ≥ 10.x** for the decompilation step. A firmware sample of your own (the lab gives lawful-acquisition guidance: vendor portal, your own device read-out, or the OpenWrt build for a known router family). |
| 02 PLC Ladder RE | The OpenPLC container from the Bachelor stack is the target; you read its artefacts (`POUS.c`, `LOCATED_VARIABLES.h`, `openplc` ELF) via `docker cp` or a bind mount. Host needs: `gdb`, `nm`, `objdump`, `radare2` *or* Ghidra, optionally Python 3 for the `plcrev` helper script you write. |
| 03 Advanced Protocols | Wireshark ≥ 4.x with the `goose`/`sv`/`dlms`/`s7comm-plus` dissectors enabled (default in modern builds). Python 3 with `scapy` (and `scapy.contrib.scada.goose`). Optional: `boofuzz` for the fuzzing stretch. Sample PCAPs from `automayt/ICS-pcap` on GitHub. |
| 04 Offensive ICS | `nmap`, Python 3 with `pymodbus` and `asyncua`. Everything attacker-side runs from inside the `is-student` container, which already has the lot — so on the host you only need `docker` and a shell. |
| 05 Secure-by-Design | A browser. The lab is a written design exercise (zones, conduits, SL-T derivation) that produces an architecture diagram and a vendor SDL contract pack. Optional: `draw.io` desktop or `excalidraw.com` for the diagram. |
| 06 Threat Intelligence | Python 3 with the `stix2` package. The lab also walks the MITRE ATT&CK Navigator (browser) and a Dragos / CISA advisory PDF — no install needed there. |
| 07 Safety/Security | Paper-only: the lab is a guided Cyber-HAZOP / SECOP table on a worked heat-exchanger node. Markdown editor or LaTeX, that's it. |
| 08 Research Methods | Python 3, `pip`, `git`. The lab builds a reproducible artefact (Docker or Nix container, pinned deps, README, archived DOI). Optional: `cosign` for the integrity-signing stretch. |

## Tooling notes

- **Ghidra** is required for §01 and recommended for §02. Install from
  `https://github.com/NationalSecurityAgency/ghidra/releases`. The repo
  does not bundle Ghidra (Apache 2.0, but ~400 MB).
- **Wireshark dissectors** — the GOOSE / Sampled Values / DLMS / S7comm /
  S7comm-plus dissectors are all upstream in Wireshark ≥ 4.0. Make sure
  IEC 61850 dissection is enabled in *Edit → Preferences → Protocols*.
- **PCAPs** — §03 uses a small set of public PCAPs from the
  `automayt/ICS-pcap` GitHub repository; clone it once and point the lab
  at the local path.
- **`scapy.contrib.scada.goose`** — not shipped in stock scapy 2.5; the
  §03 spoofing step needs either a vendored `goose.py` helper or the
  community port (`load_contrib('scada.goose')` only works if you have
  it installed separately). The shipped `is-master-extras` container
  carries scapy and `scapy.contrib.scada.iec104`; the GOOSE spoof is the
  one step you may have to hand-craft or fetch upstream.

## Want everything in a container instead of on the host?

The shared Bachelor lab stack now ships an opt-in **`is-master-extras`**
service that carries every host-side tool listed above (except Ghidra,
which is a ~400 MB graphical app). Bring it up with:

```bash
cd bachelor/labs/_stack && docker compose --profile master up -d
```

Then drop in:

```bash
docker compose exec master-extras bash
```

The container has the `master/labs/` tree mounted read-only at
`/labs/master`, the shared captures directory at `/labs/captures`, and a
named volume at `/labs/firmware` so firmware samples you drop in for
§01 survive container restarts. On the network it sits at
`172.28.0.30` and can reach every Bachelor service (OpenPLC, OPC UA,
MQTT, Zeek) at the same IPs the student container sees.

## What this directory does not include

- A bundled firmware image for §01 — license-clean firmware that is also
  pedagogically interesting is hard to ship. The lab walks you through
  lawful acquisition instead (vendor portal, your own device read-out,
  or an OpenWrt build for a known router family).

If that would meaningfully help your delivery it is tracked on the
repository roadmap and patches are welcome.
