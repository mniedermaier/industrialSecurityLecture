# Security Policy

## Scope

This repository ships **teaching material** — slides, exercises, lab sheets, a deliberately-vulnerable Docker lab stack — and a small amount of helper code (Python lab scripts, shell scripts, Makefiles, Dockerfile for the student container).

The Docker stack is **intentionally insecure** so that students can attack it: OpenPLC with default credentials, anonymous OPC UA, an MQTT broker with no auth. Do **not** report these as vulnerabilities — they are pedagogical features.

## What we treat as a security issue

- Credential or secret leak in the repository history.
- A flaw in the helper Python scripts or shell scripts that allows code execution outside the lab containers.
- A flaw in the build system that allows arbitrary execution during `make`.
- A supply-chain risk in the pinned dependencies (`pymodbus[serial]==3.6.9`, `asyncua`, `paho-mqtt`, `eclipse-mosquitto`, `open62541`, `openplc-runtime`, `nginx`, `zeek`).

## Reporting

Please **do not** open a public GitHub issue for these. Instead, email the maintainer directly (commit history has the address) or use the **"Report a vulnerability"** button in the repository's *Security* tab to open a private advisory.

Expect an acknowledgement within 7 days and a fix or mitigation within 30 days for high-severity findings.

## Out of scope

- The default credentials in OpenPLC (`openplc` / `openplc`).
- The lack of TLS on the MQTT broker and OPC UA server.
- The deliberately-vulnerable Modbus exposure on the lab network.
- Anything inside `bachelor/labs/_stack/` that exists for students to exploit.
