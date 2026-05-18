# Industrial Security Lecture Series

Teaching material for Industrial Control System (ICS) and Operational
Technology (OT) security, organised as a multi-level programme:

- **`bachelor/`** — introductory course (~ 40 h, 5 days). Course-ready.
- **`master/`** — advanced course (~ 60 h, 8 sections). Lecture-ready;
  exercises and labs are lighter than the Bachelor.

Both courses share `template/` so styles, colours, TikZ symbols, and
the logo stay consistent across the programme.

---

## Quick start

```bash
# 1. Clone and build everything (TeX Live + latexmk required).
make verify           # builds all PDFs and fails if any overfull box appears

# 2. (Optional) rebrand for your organisation -- see BRANDING.md
#    Drop your logo at branding/logo.pdf, edit two hex codes in
#    branding.tex, then `make`.

# 3. Smoke-test the lab stack before Day 1 (Docker required).
bachelor/labs/preflight.sh
```

A green `make verify` and a green preflight = the course is ready to run.

---

## What you get per Bachelor section

Each `bachelor/sections/NN-topic/` folder builds **two** PDFs:

| File                          | Purpose                                                  |
|-------------------------------|----------------------------------------------------------|
| `NN-topic-slides.pdf`         | Projector-clean slides for the room.                     |
| `NN-topic-notes.pdf`          | Slide-on-left + speaker-notes-on-right, lecturer copy.   |

Each `bachelor/exercises/NN-topic/` folder builds:

| File                          | Purpose                                                  |
|-------------------------------|----------------------------------------------------------|
| `NN-topic-exercises.pdf`      | 8--10 scenario-driven exercises, no answers.             |
| `NN-topic-solutions.pdf`      | Model answers with grader rubric hints.                  |

Each `bachelor/labs/NN-topic/` folder builds:

| File                          | Purpose                                                  |
|-------------------------------|----------------------------------------------------------|
| `NN-topic-lab.pdf`            | 30--90 min hands-on lab sheet for the room.              |

Course-wide handouts live at `bachelor/handouts/`:

| File                          | Purpose                                                  |
|-------------------------------|----------------------------------------------------------|
| `delivery-schedule.pdf`       | 5-day per-slot schedule for the lecturer.                |
| `acronyms.pdf`                | ~120 OT/IT/security acronyms; student handout.           |
| `cheatsheets.pdf`             | 4-page quick reference: Modbus, OPC UA, CVSS, NIS2/CRA.  |

---

## Repository layout

```
.
├── README.md                   ← you are here
├── BRANDING.md                 ← single-file rebrand instructions
├── CLAUDE.md                   ← repo invariants (no overfull, typography, ...)
├── branding.tex                ← user-editable: logo path + colours + author
├── branding/
│   └── logo.pdf                ← drop your corporate logo here
├── Makefile                    ← top-level: builds every course
├── template/                   ← shared LaTeX preamble, TikZ styles, make rules
│   ├── slides-preamble.tex
│   ├── slides.mk
│   ├── exercise-preamble.tex
│   ├── exercises.mk
│   ├── lab-preamble.tex
│   ├── labs.mk
│   ├── tikz-styles.tex
│   ├── logo.pdf                ← fallback only (branding/logo.pdf wins)
│   └── logo-source.tex
├── bachelor/
│   ├── Makefile
│   ├── handouts/               ← course-wide PDFs (lecturer + student)
│   │   ├── delivery-schedule.{tex,pdf}
│   │   ├── acronyms.{tex,pdf}
│   │   └── cheatsheets.{tex,pdf}
│   ├── sections/NN-topic/      ← slides.tex → -slides.pdf + -notes.pdf
│   ├── exercises/NN-topic/     ← exercises.tex + solutions.tex
│   └── labs/
│       ├── preflight.sh        ← smoke-test the docker stack
│       ├── _stack/             ← docker-compose.yml + scripts/ + zeek/ + mqtt/
│       └── NN-topic/lab.tex    ← per-lab sheet
└── master/
    ├── Makefile
    ├── sections/, exercises/, labs/
    └── README.md
```

---

## Make targets

```bash
make                      # builds everything: slides, notes, exercises, solutions, labs, handouts
make verify               # build + fail if any LaTeX log contains "Overfull"
make slides               # only slide decks (both courses)
make exercises            # only exercise sheets
make solutions            # only solution sheets
make clean                # remove LaTeX intermediates
make distclean            # also remove PDFs

# Bachelor course alone:
make -C bachelor          # everything in the Bachelor (slides, notes, exercises, labs, handouts)
make -C bachelor slides   # slides only
make -C bachelor notes    # notes-alongside PDFs only
make -C bachelor handouts # delivery-schedule.pdf + acronyms.pdf
make -C bachelor labs     # lab sheets only

# A single section:
make -C bachelor/sections/03-network-architecture
make -C bachelor/sections/03-network-architecture notes
```

---

## Lab stack (Docker)

All 10 Bachelor labs share one stack:

```bash
cd bachelor/labs/_stack
docker compose up -d           # OpenPLC, OPC UA, MQTT, Zeek, student
docker compose exec student bash
docker compose down -v         # tear down (drops captured PCAPs)
```

Services:

| Service     | Image                              | Address              | Used by lab(s) |
|-------------|------------------------------------|----------------------|----------------|
| `landing`   | nginx:1.27-alpine                  | 127.0.0.1:8000       | start here     |
| `openplc`   | atripathy86/openplc-runtime        | 172.28.0.10:502/8080 | 02, 04, 06, 08 |
| `opcua`     | open62541/open62541                | 172.28.0.11:4840     | 04             |
| `mqtt`      | eclipse-mosquitto:2                | 172.28.0.12:1883     | side-quest     |
| `student`   | built locally (Debian + tools)     | 172.28.0.20          | every lab      |
| `zeek`      | zeek/zeek (shares openplc netns)   | sees 172.28.0.10     | 08             |

Once the stack is up, the **lab landing page** at
<http://127.0.0.1:8000> is the canonical entry point for students:
brand-consistent overview of all 10 labs (each card deep-links to the
matching PDF), the 5 services, the helper scripts, a quick reference
(Modbus function codes, frame anatomy, addresses, one-liners), and a
troubleshooting strip for the three things that always go wrong.

**Before Day 1:** run `bachelor/labs/preflight.sh` to verify every
service starts and the smoke-tests pass. Flags:

- `--pull` to refresh images first
- `--keep` to leave the stack running afterwards (useful while you
  upload the OpenPLC `conveyor.st` program through the web UI; that
  upload persists, so subsequent runs clear the Modbus-related warnings)

---

## Bachelor course outline

| #  | Section                                | Slides | Lab                |
|----|----------------------------------------|--------|--------------------|
| 01 | Introduction to Industrial Security    | 21     | Lab 01 (paper)     |
| 02 | ICS and SCADA Fundamentals             | 21     | Lab 02 (OpenPLC)   |
| 03 | Industrial Network Architectures       | 21     | Lab 03 (design)    |
| 04 | Industrial Protocols                   | 21     | Lab 04 (Modbus + OPC UA) |
| 05 | Threat Landscape + Case Studies        | 30     | Lab 05 (Shodan)    |
| 06 | Vulnerabilities and Assessment         | 21     | Lab 06 (CVE walk)  |
| 07 | Risk Management                        | 21     | Lab 07 (workshop)  |
| 08 | Defense in Depth                       | 21     | Lab 08 (Zeek IDS)  |
| 09 | Standards, Compliance, Governance      | 21     | Lab 09 (gap analysis) |
| 10 | Incident Response and Recovery         | 21     | Lab 10 (tabletop)  |

Day-by-day pacing is in `bachelor/delivery-schedule.pdf`.

---

## Customising

- **Logo + brand colours + author / institute:** see `BRANDING.md`
  -- a two-file change rebrands the entire course.
- **Pedagogical TikZ palette** (`isOT`, `isPLC`, `isAttack`, ...) lives
  in `template/tikz-styles.tex`. Leave these alone unless you have a
  reason -- they keep the slide imagery internally consistent.
- **Repo invariants** (no overfull boxes, typography rules, TikZ
  rules, source-citation policy) are in `CLAUDE.md`. The CI gate is
  `make verify`.

---

## License

Dual-licensed, with a clean split between course content and code:

- **Course material** (slides, speaker notes, exercises, solutions,
  lab sheets, schedule, acronyms, cheat-sheets, and the LaTeX
  templates that produce them) is licensed under
  **CC BY-SA 4.0**. See [`LICENSE-CONTENT`](LICENSE-CONTENT).
- **Code and configuration** (lab Python helpers, Docker stack, shell
  scripts, Makefiles, landing page HTML/CSS) is licensed under the
  **MIT License**. See [`LICENSE`](LICENSE).

Both license files list the exact paths covered. Third-party material
quoted inside the slides (logos, screenshots, CISA advisories, vendor
documentation) remains the property of its respective owners and is
used under fair use for educational purposes.
