# Labs -- Industrial Security (Bachelor)

One lab per section, numbered identically to the slides and exercises. Practical labs that need infrastructure all share **one Docker stack** under `_stack/`.

## Layout

```
labs/
├── _stack/                      # shared infra: docker-compose, scripts, container configs
│   ├── docker-compose.yml
│   ├── scripts/                 # ladder code + python helpers
│   ├── student/Dockerfile
│   ├── mqtt/, zeek/
│   ├── captures/                # PCAPs land here
│   └── zeek-logs/               # IDS logs land here
├── 01-introduction/             # → 01-introduction-lab.pdf
├── 02-ics-fundamentals/
├── 03-network-architecture/
├── 04-protocols/
├── 05-threats/
├── 06-vulnerabilities/
├── 07-risk-management/
├── 08-defense-in-depth/
├── 09-standards/
├── 10-incident-response/
└── Makefile                     # builds every lab PDF, drives the stack
```

Each `NN-topic/` directory contains `lab.tex` and a `Makefile` and produces `NN-topic-lab.pdf`.

## Build the lab sheets (PDFs)

```bash
make -C bachelor/labs              # build every NN-topic-lab.pdf
make -C bachelor/labs/04-protocols # one lab
```

## Run the shared Docker stack (for hands-on labs)

```bash
cd bachelor/labs/_stack
docker compose up -d            # OpenPLC, OPC UA, MQTT, student, Zeek
docker compose exec student bash
# then run scripts inside /labs/scripts/
docker compose down -v          # tear down
```

Or, from anywhere in the repo:

```bash
make -C bachelor/labs stack-up
make -C bachelor/labs stack-down
```

## What each lab covers

| # | Theme | Hands-on? |
|---|-------|-----------|
| 01 | Where is the industrial security? (spotter walk) | observation only |
| 02 | First contact with OpenPLC | Docker stack |
| 03 | Network segmentation (paper / GNS3) | paper or VM |
| 04 | Modbus and OPC UA -- see the difference | Docker stack |
| 05 | Shodan reconnaissance (browser only) | browser |
| 06 | Real CVE walk-through | browser + writing |
| 07 | Risk matrix workshop | group exercise |
| 08 | Passive OT IDS with Zeek | Docker stack |
| 09 | Regulatory gap analysis | writing |
| 10 | Saturday-night tabletop | group exercise |

## Safety

- All scripts in `_stack/scripts/` are hardcoded to the lab subnet `172.28.0.0/16`. Do not change the addresses.
- Never run lab scripts against real industrial devices without explicit written authorisation.
- Treat all collected data (PCAPs, screenshots) as sensitive even when generated against your own equipment.
