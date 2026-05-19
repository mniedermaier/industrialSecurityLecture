<div align="center">

# Industrial Security Lecture Series

**A complete, classroom-ready university course on Industrial Control System (ICS) and Operational Technology (OT) cybersecurity — slides, labs, exercises, and a one-command Docker lab stack.**

[![Build](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/build.yml/badge.svg)](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/build.yml)
[![Lab stack](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/lab-stack.yml/badge.svg)](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/lab-stack.yml)
[![Release](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/release.yml/badge.svg)](https://github.com/mniedermaier/industrialSecurityLecture/actions/workflows/release.yml)
[![Content CC BY-SA 4.0](https://img.shields.io/badge/content-CC--BY--SA--4.0-blue.svg)](LICENSE-CONTENT)
[![Code MIT](https://img.shields.io/badge/code-MIT-green.svg)](LICENSE)
[![LaTeX](https://img.shields.io/badge/built%20with-LaTeX-008080.svg)](https://www.latex-project.org/)
[![Docker](https://img.shields.io/badge/labs-Docker%20Compose-2496ED.svg)](https://docs.docker.com/compose/)

</div>

---

> Built for **IT students** with no electrical-engineering background. Every OT concept is anchored to an IT analogue (PLC ≈ embedded controller with a hard real-time loop, Modbus ≈ tiny KV store at 16-bit offsets, scan cycle ≈ event loop, historian ≈ time-series DB). You can run the lab plant on a laptop.

## Table of contents

- [Why this exists](#why-this-exists)
- [What you get](#what-you-get)
- [Quick start](#quick-start)
- [Course outline](#course-outline)
- [Lab stack architecture](#lab-stack-architecture)
- [Repository layout](#repository-layout)
- [Build targets](#build-targets)
- [Customising / rebranding](#customising--rebranding)
- [Continuous integration](#continuous-integration)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Why this exists

OT cybersecurity sits awkwardly between two worlds. IT-trained students don't know what a PLC is; control engineers don't know what a CVE is; the textbooks assume one and skip the other. This course is the bridge. It is:

- **Heavily IT-flavoured.** Every ICS concept is introduced with an IT analogue so an SRE, web-app engineer, or pen-tester can follow without a primer on relay logic.
- **Hands-on.** Ten labs, all running locally on a single `docker compose up -d`. OpenPLC, OPC UA, MQTT, Zeek, and a "student" container with everything pre-installed.
- **Anchored to the standards practitioners actually cite.** IEC 62443 is the spine — every section ties back to specific parts (1-1 concepts, 2-1 program, 3-2 risk/zones, 3-3 FRs 1–7, 4-1 SDL, 4-2 components).
- **Rebrandable in two minutes.** Drop your logo in `branding/`, edit two hex codes in `branding.tex`, re-run `make`. Done.
- **Free.** Course material is CC BY-SA 4.0; code (Dockerfiles, Python helpers, Make rules) is MIT.

## What you get

<table>
<tr>
<th>Course content</th><th>Per-section artefacts</th><th>Course-wide handouts</th>
</tr>
<tr>
<td valign="top">

10 Bachelor sections covering:

- Introduction & threat picture
- ICS & SCADA fundamentals
- Network architectures (Purdue)
- Industrial protocols
- Threats & case studies
- Vulnerabilities & assessment
- Risk management
- Defense in depth
- Standards & compliance
- Incident response

</td>
<td valign="top">

For every section:

- `slides.pdf` — projector deck (≈ 19–22 frames per section, ~200 frames total)
- `notes.pdf` — slide-on-left + speaker-notes-on-right
- `exercises.pdf` — 8–10 scenario-driven exercises
- `solutions.pdf` — model answers + grader rubric
- `lab.pdf` — 60–135 min hands-on exercise (260–561 lines each)

</td>
<td valign="top">

- `delivery-schedule.pdf` — 5-day per-slot timetable
- `acronyms.pdf` — ~120 OT/IT/security acronyms
- `cheatsheets.pdf` — 4-page quick ref: Modbus, OPC UA, CVSS-for-OT, NIS2/CRA timelines

</td>
</tr>
</table>

## Quick start

### Build the PDFs

```bash
# Prerequisites: TeX Live (any modern distro) + latexmk + GNU Make + Python 3
git clone https://github.com/mniedermaier/industrialSecurityLecture.git
cd industrialSecurityLecture
make verify          # builds every PDF; fails if any LaTeX log has 'Overfull'
```

A green `make verify` means every slide, exercise, lab, and handout has compiled cleanly and nothing overflows a page.

### Bring up the lab stack

```bash
cd bachelor/labs/_stack
docker compose up -d                     # OpenPLC + OPC UA + MQTT + Zeek + student
docker compose exec student bash         # drop into the student VM-equivalent

# Smoke test from inside the student container:
python3 /labs/scripts/modbus_read.py
# → Registers 0..9: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

Open the lab landing page at <http://127.0.0.1:8000> — brand-consistent overview of all 10 labs, deep-linking to the PDFs, with a quick-reference strip (Modbus function codes, addressing, one-liners) and a troubleshooting cheat sheet.

### Tear it all down

```bash
docker compose down -v   # also drops captured PCAPs
```

## Course outline

| #  | Section                                | IEC 62443 anchor                       | Lab                                          | Lab time     |
|----|----------------------------------------|----------------------------------------|----------------------------------------------|--------------|
| 01 | Introduction to Industrial Security    | 1-1 concepts                           | Orientation + first Modbus read              | 60–90 min    |
| 02 | ICS & SCADA Fundamentals               | 1-2 glossary, 4-2 components           | Control-loop end-to-end on OpenPLC           | 60–90 min    |
| 03 | Industrial Network Architectures       | 3-2 zones & conduits, 3-3 SR 5         | Purdue mapping + firewall ruleset            | 75–90 min    |
| 04 | Industrial Protocols                   | 3-3 FR 1–7, 4-2 CRs                    | Modbus + OPC UA + MQTT side-by-side          | 90–120 min   |
| 05 | Threat Landscape & Case Studies        | 1-1 threat actors, 3-3 SL 1–4          | Reproduce a Stuxnet-shape, detect in Zeek    | 90–120 min   |
| 06 | Vulnerabilities & Assessment           | 4-1 SDL, 2-3 patch mgmt                | CISA advisory walk + CVSS for OT             | 75–105 min   |
| 07 | Risk Management                        | 3-2 risk methodology, 2-1 program      | Cyber-PHA on the lab plant                   | 60–90 min    |
| 08 | Defense in Depth                       | 3-3 FR 1–7 (Foundational Requirements) | Zeek tuning against simulated attacks        | 105–135 min  |
| 09 | Standards, Compliance, Governance      | 62443 certification + NIS2 + CRA       | IEC 62443-3-2 zoning walkthrough             | 75–105 min   |
| 10 | Incident Response & Recovery           | 2-1 IR program, 3-3 SR 6               | Tabletop + Zeek-log forensics                | 90–120 min   |

Day-by-day pacing is in `bachelor/handouts/delivery-schedule.pdf`.

## Lab stack architecture

All 10 Bachelor labs run on **one** Docker Compose stack — no cloud account, no licence dance, no PLC hardware. The whole plant fits on a laptop.

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Host (your laptop)                                                     │
│                                                                         │
│    Browser ── http://127.0.0.1:8000 ─► landing  (nginx, lab overview)   │
│    Browser ── http://127.0.0.1:8080 ─► openplc   (web UI)               │
│    tshark / Wireshark on .pcap files in bachelor/labs/_stack/captures/  │
│                                                                         │
│  ┌────────────── Docker network is-lab (172.28.0.0/16) ──────────────┐  │
│  │                                                                   │  │
│  │   openplc (172.28.0.10)  ──Modbus/502── student (172.28.0.20)     │  │
│  │      └── runs conveyor.st ladder logic                            │  │
│  │      └── zeek shares its netns ──► passive IDS on every packet    │  │
│  │                                                                   │  │
│  │   opcua   (172.28.0.11) :4840   open62541 example server          │  │
│  │   mqtt    (172.28.0.12) :1883   Mosquitto broker                  │  │
│  │   landing (172.28.0.5)  :80     brand-consistent overview         │  │
│  │   student (172.28.0.20)         debian + pymodbus + asyncua +     │  │
│  │                                  paho-mqtt + tshark + nmap        │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

Auto-bootstrap: the one-shot `openplc-init` sidecar waits for OpenPLC to report healthy, then uploads `scripts/ladder/conveyor.st` and starts the PLC. By the time `docker compose up -d` returns, Modbus on port 502 is live — no manual web-UI clicking required.

**Before Day 1**, run `bachelor/labs/preflight.sh` to verify every service starts and the smoke tests pass:

```bash
bachelor/labs/preflight.sh           # default: build, test, tear down
bachelor/labs/preflight.sh --pull    # refresh images first
bachelor/labs/preflight.sh --keep    # leave the stack running afterwards
```

## Repository layout

```
.
├── README.md                  ← you are here
├── BRANDING.md                ← rebrand the whole course in two minutes
├── CLAUDE.md                  ← repo invariants (no overfull, typography, ...)
├── LICENSE                    ← MIT (code)
├── LICENSE-CONTENT            ← CC BY-SA 4.0 (slides, labs, exercises)
├── Makefile                   ← top-level build entry point
│
├── .github/
│   ├── workflows/             ← CI/CD: build, release, lab-stack smoke test
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── branding.tex               ← user-editable: logo path + colours + author
├── branding/
│   └── logo.pdf               ← drop your logo here
│
├── template/                  ← shared LaTeX preamble + TikZ styles + Make rules
│   ├── slides-preamble.tex
│   ├── exercise-preamble.tex
│   ├── lab-preamble.tex
│   ├── tikz-styles.tex
│   └── *.mk
│
├── bachelor/                  ← introductory course (~40 h, course-ready)
│   ├── Makefile
│   ├── handouts/              ← delivery-schedule, acronyms, cheatsheets
│   ├── sections/NN-topic/     ← slides.tex → slides.pdf + notes.pdf
│   ├── exercises/NN-topic/    ← exercises.tex + solutions.tex
│   └── labs/
│       ├── preflight.sh       ← smoke-test the docker stack
│       ├── deep-test.sh       ← per-lab regression run
│       ├── _stack/            ← docker-compose.yml + scripts/ + zeek/ + mqtt/
│       └── NN-topic/lab.tex
│
└── master/                    ← advanced course (~60 h, lecture-ready)
    ├── README.md
    ├── sections/, exercises/, labs/
    └── Makefile
```

## Build targets

```bash
# Everything
make                       # builds slides, notes, exercises, solutions, labs, handouts
make verify                # build + fail if any LaTeX log contains 'Overfull'
make clean                 # remove LaTeX intermediates
make distclean             # also remove PDFs

# By artefact class
make slides                # slide decks only (both courses)
make exercises             # exercise sheets only
make solutions             # solution sheets only

# By course
make -C bachelor           # everything in the Bachelor
make -C bachelor slides    # Bachelor slides only
make -C bachelor labs      # Bachelor labs only
make -C bachelor handouts  # delivery-schedule + acronyms + cheatsheets

# A single section / lab
make -C bachelor/sections/03-network-architecture
make -C bachelor/labs/04-protocols
```

`make verify` is the CI gate. It builds everything, then greps every LaTeX log for `^Overfull` and exits non-zero if any line matches. No silent overflow.

## Customising / rebranding

The course is designed to be **rebranded for your institution in two minutes** — no LaTeX surgery required.

1. Drop your logo at `branding/logo.pdf` (or `.png` / `.jpg`).
2. Edit `branding.tex` — four lines for the brand colours and the author/institute:

   ```latex
   \definecolor{slideAccent}{HTML}{00205B}      % primary
   \definecolor{slideSecondary}{HTML}{00A0DC}   % accent
   \renewcommand{\courseAuthor}{Lecture Notes}
   \renewcommand{\courseInstitute}{Department of Computer Science}
   ```

3. Re-run `make`. The new logo, colours, and footer roll out across every PDF.

Full instructions in [`BRANDING.md`](BRANDING.md). Example brand themes live in `branding/examples/`.

## Continuous integration

The repository ships three GitHub Actions workflows:

| Workflow            | Trigger                                  | What it does |
|---------------------|------------------------------------------|--------------|
| `build.yml`         | every push / PR to `main`                | Build all PDFs in a TeX Live container; run `make verify`; upload artefacts |
| `release.yml`       | git tag `v*`                             | Build PDFs; attach them to a GitHub Release |
| `lab-stack.yml`     | weekly + manual                          | `docker compose up -d`; run preflight; tear down |

Workflow definitions live in `.github/workflows/`. They use the official [`xu-cheng/latex-action`](https://github.com/xu-cheng/latex-action) so contributors don't need TeX Live locally to verify their changes will pass CI.

## Contributing

Patches and reports are welcome. Before opening a PR:

1. Run `make distclean && make verify` locally. The CI runs the same check; a clean log is the floor.
2. Read [`CLAUDE.md`](CLAUDE.md) — it lists the **load-bearing invariants** of the repo: no overfull boxes, typography rules, TikZ rules (arrows don't cross nodes, labels sit clearly off the line, no two nodes share pixels), source-citation policy (CISA advisories cited by ID + date, IEC standards by number + year, no invented URLs).
3. Keep the IT-student lens. Every new ICS/OT term needs an IT analogue on first use.
4. If you add a new lab or section, include a `\source{...}` block and `\note{...}` speaker notes.

Issue templates and a PR template live in `.github/`.

## Roadmap

- [x] Bachelor: 10 sections (slides + notes), 10 labs, 10 exercise+solution pairs, 3 handouts
- [x] One-command Docker lab stack with auto-bootstrap
- [x] IEC 62443 anchor frame in every section
- [x] IT-student-friendly glossary frame and inline IT analogues throughout
- [x] CI/CD: build + verify on every PR; PDF artefacts on tagged release
- [ ] Master: complete the remaining 4 sections + lab exercises
- [ ] Translations: DE (and EN if you write in another language)
- [ ] OPC UA secure-mode lab variant (currently anonymous + None)
- [ ] Add a S7 / EtherNet/IP lab using `snap7` and `pycomm3`
- [ ] Per-section flashcards (Anki deck export)

## License

Dual-licensed with a clean split between course content and code:

- **Course material** (slides, speaker notes, exercises, solutions, lab sheets, schedule, acronyms, cheat-sheets, and the LaTeX templates that produce them) is licensed under **CC BY-SA 4.0**. See [`LICENSE-CONTENT`](LICENSE-CONTENT).
- **Code and configuration** (lab Python helpers, Docker stack, shell scripts, Makefiles, landing-page HTML/CSS) is licensed under the **MIT License**. See [`LICENSE`](LICENSE).

Third-party material quoted inside the slides (logos, screenshots, CISA advisories, vendor documentation) remains the property of its respective owners and is used under fair use for educational purposes.

## Acknowledgements

This course stands on the shoulders of the people, tools, and reports that built the ICS-security field:

- **OpenPLC** (Thiago Alves et al.) — the soft PLC that makes the lab plant run on a laptop.
- **open62541** — the open-source OPC UA reference implementation.
- **Zeek** + **ICSNPP** (CISA / Idaho National Laboratory) — passive industrial-protocol analysers that turn a packet stream into structured logs.
- **Dragos** annual *Year in Review*, **Mandiant** *M-Trends*, and **ENISA** *Threat Landscape* — the case-study spine of Section 05.
- **CISA ICS advisories** — the running operational feed every defender should read weekly.
- **IEC 62443** (ISA / IEC TC 65) — the standard family that anchors the entire course.
- The **SANS ICS team** (Mike Assante, Rob Lee, Tim Conway) — the ICS Cyber Kill Chain and ICS515.
- Books we lean on: Knapp & Langill *Industrial Network Security*; Bodungen et al. *Hacking Exposed: ICS*; Bochman & Freeman *Countering Cyber Sabotage* (CCE); Zetter *Countdown to Zero Day*.

---

<div align="center">

**Made for the next generation of OT defenders.**

If this course helped you, drop a ⭐ and let us know how you use it.

</div>
