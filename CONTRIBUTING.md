# Contributing

Patches and reports are welcome. This guide is short — the load-bearing rules are in [`CLAUDE.md`](CLAUDE.md).

## Before you open a PR

1. **Build locally.** `make distclean && make verify` must exit 0. CI runs the same check; a green log is the floor.
2. **Read `CLAUDE.md`.** It lists the invariants the build enforces: no overfull boxes, typography rules, TikZ rules (arrows don't cross nodes, labels off the line, no two nodes share pixels), source-citation policy.
3. **Audience is IT students.** Every new ICS/OT term needs an IT analogue on first use (e.g. "PLC = ruggedised embedded controller with a hard real-time loop", "Modbus = tiny key/value store at fixed 16-bit offsets"). If you can't think of one, the term is probably too deep for the Bachelor.
4. **Cite everything non-trivial.** Use `\source{...}` on any slide that states a fact (incident, statistic, standard, vendor advisory). Cite:
   - CISA advisories by ID + date (e.g. `CISA AA22-103A, 13 Apr 2022`)
   - IEC / ISO / NIST standards by number + year (e.g. `IEC 62443-3-3:2013`)
   - Peer-reviewed papers and formal reports (Symantec, Dragos, Mandiant, SANS) by author + title + year
   - Regulations by formal identifier (e.g. `Directive (EU) 2022/2555`)
   - **No invented URLs.** Use `\url{...}` only for URLs you have personally verified.

## Workflow

```bash
git checkout -b your-topic
# edit
make distclean && make verify
git commit -m "section 04: clarify MBAP header decoding"
git push -u origin your-topic
# open PR
```

The PR template lists the checks the maintainers will look for.

## Adding a new section / lab

A new section is six files plus one directory:

```
bachelor/sections/NN-topic/
├── Makefile          # one-liner: include ../../../template/slides.mk
└── slides.tex        # see any existing section for the boilerplate

bachelor/exercises/NN-topic/
├── Makefile          # include ../../../template/exercises.mk
├── exercises.tex
└── solutions.tex

bachelor/labs/NN-topic/
├── Makefile          # include ../../../template/labs.mk
└── lab.tex
```

The shared `template/*.mk` files do the heavy lifting; the per-leaf Makefile is one line.

## Coding style for lab Python helpers

- Python 3.10+. `pymodbus[serial] == 3.6.9`, `asyncua`, `paho-mqtt` are pre-installed in the `student` container.
- One responsibility per script. Hard-code the lab IPs (`172.28.0.10` etc.) — the student container is on the `is-lab` bridge.
- Print human-readable output on stdout. If you must error, print a one-line cause then `sys.exit(1)`.

## Reporting issues

See `.github/ISSUE_TEMPLATE/`. Bug reports and content corrections have dedicated forms.
