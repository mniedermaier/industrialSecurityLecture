# Industrial Security Lecture Series

Teaching material for Industrial Control System (ICS) and Operational Technology (OT) security, organised as a multi-level programme:

- **`bachelor/`** — introductory course (≈ 40 h). Available now.
- **`master/`** — advanced course (pilot section available: Firmware Reverse Engineering). More sections to follow; uses the same shared template.

Both courses share `template/` so styles, colours, TikZ symbols, and the logo stay consistent across the programme.

## Repository layout

```
.
├── template/                # Shared LaTeX preamble, TikZ styles, Makefile fragments
│   ├── slides-preamble.tex
│   ├── exercise-preamble.tex
│   ├── tikz-styles.tex
│   ├── slides.mk            # Make rules for slide decks
│   ├── exercises.mk         # Make rules for exercise / solution sheets
│   ├── logo.pdf             # Drop-in logo (replace with your own)
│   └── logo-source.tex      # Builds the placeholder logo
├── bachelor/
│   ├── sections/            # Slide decks only
│   │   └── NN-topic/
│   │       ├── slides.tex   → NN-topic-slides.pdf
│   │       └── Makefile
│   ├── exercises/           # Exercise + solution sheets, one folder per section
│   │   └── NN-topic/
│   │       ├── exercises.tex → NN-topic-exercises.pdf
│   │       ├── solutions.tex → NN-topic-solutions.pdf
│   │       └── Makefile
│   ├── labs/                # All hands-on labs run from one Docker stack
│   │   ├── docker-compose.yml
│   │   ├── lab-01..06-*.md
│   │   ├── scripts/         # Lab Python scripts + ladder code
│   │   ├── student/         # Dockerfile for the student container
│   │   ├── mqtt/, zeek/     # Service configs
│   │   └── README.md
│   ├── docs/syllabus.md
│   └── Makefile
├── master/                  # Master course (pilot section available)
│   └── README.md
├── Makefile                 # Top-level build (delegates to each course)
└── README.md
```

## Building the PDFs

Requirements: TeX Live with `latexmk`, `pdflatex`, plus `beamer`, `tikz`, `listings`, `booktabs`, `tcolorbox`, `colortbl`, `hyperref`.

```bash
make                    # build slides + exercises + solutions for every course
make slides             # only slide decks
make exercises          # only exercise sheets
make solutions          # only solution sheets
make clean              # remove LaTeX intermediates
make distclean          # also remove PDFs
make verify             # build everything, fail if any LaTeX log shows Overfull
make -C bachelor slides # only bachelor course slides
make -C bachelor/sections/03-network-architecture   # build one section
```

Output PDFs are named with the section prefix, e.g.\
`bachelor/sections/03-network-architecture/03-network-architecture-slides.pdf`.

## Running the labs

```bash
cd bachelor/labs
docker compose up -d           # OpenPLC, OPC UA, MQTT, student, Zeek
docker compose exec student bash
# then run the lab scripts in /labs/scripts/
docker compose down -v         # tear down
```

See `bachelor/labs/README.md` for the network layout and per-lab instructions.

## Customising

- **Logo:** drop a `logo.pdf`, `logo.png`, or `logo.jpg` into `template/` (replacing the placeholder). Every title page, divider, and closing slide picks it up.
- **Course title / author / institute:** each `slides.tex` declares them. To change once for the whole course, edit them in each section, or `sed -i 's/.../.../' bachelor/sections/*/slides.tex`.
- **Colour palette:** edit `template/tikz-styles.tex` (`isOT`, `isAccent`, `isAttack`, etc.) and `template/slides-preamble.tex` (`slideAccent`, `slideSecondary`).

## Bachelor course outline

| #  | Section                                | Hands-on lab |
|----|----------------------------------------|--------------|
| 01 | Introduction to Industrial Security    | —            |
| 02 | ICS and SCADA Fundamentals             | Lab 01       |
| 03 | Industrial Network Architectures       | Lab 03       |
| 04 | Industrial Protocols                   | Labs 02, 04  |
| 05 | Threat Landscape                       | Lab 05       |
| 06 | Vulnerabilities and Assessment         | —            |
| 07 | Risk Management                        | —            |
| 08 | Defense in Depth                       | Lab 06       |
| 09 | Standards, Compliance, Governance      | —            |
| 10 | Incident Response and Recovery        | —            |

See `bachelor/docs/syllabus.md` for the full programme.

## License

Course material released under CC BY-SA 4.0; code samples (lab scripts, Docker config, Makefiles) under MIT.
