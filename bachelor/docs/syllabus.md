# Syllabus -- Industrial Security (Bachelor)

A ~40 hour Bachelor-level introduction to Industrial Control System (ICS) and Operational Technology (OT) security.

## Course aims

By the end of the course, students can:

1. Explain how industrial control systems differ from corporate IT.
2. Identify the main components of an ICS (PLC, RTU, DCS, SCADA, HMI, Historian, SIS) and how they interact.
3. Design and critique a Purdue-style network architecture with an Industrial DMZ.
4. Recognise the security properties (or absence) of common industrial protocols.
5. Reason about industrial-specific threats and apply the MITRE ATT&CK for ICS knowledge base.
6. Apply CVSS in an OT context, run a safe vulnerability assessment, and produce a risk register.
7. Apply Cyber-HAZOP and CCE-style thinking to design defenses.
8. Specify defense-in-depth controls and a secure remote access pattern.
9. Navigate IEC 62443, NIST CSF / 800-82, and the main regulations (NIS2, KRITIS, NERC CIP).
10. Build a basic OT incident response capability, including tabletop exercises and forensic basics.

## Sections

| #  | Topic                                  | Exercises | Lab        |
|----|----------------------------------------|-----------|------------|
| 01 | Introduction to Industrial Security    | yes       | -          |
| 02 | ICS and SCADA Fundamentals             | yes       | Lab 01     |
| 03 | Industrial Network Architectures       | yes       | Lab 03     |
| 04 | Industrial Protocols                   | yes       | Lab 02, 04 |
| 05 | Threat Landscape                       | yes       | Lab 05     |
| 06 | Vulnerabilities and Assessment         | yes       | -          |
| 07 | Risk Management                        | yes       | -          |
| 08 | Defense in Depth                       | yes       | Lab 06     |
| 09 | Standards, Compliance, and Governance  | yes       | -          |
| 10 | Incident Response and Recovery         | yes       | -          |

Each section has a slide deck (PDF), an exercise sheet (PDF), and a solution sheet (PDF). Together they total roughly 40 hours of lecture, supervised exercises, and hands-on lab work.

## Assessment (suggested)

- 40 % -- written exam (closed book, 90 minutes), covering all sections.
- 30 % -- lab reports (best 4 of 6).
- 30 % -- group capstone (Section 10 follow-on or an instructor-defined site assessment).

Instructors are free to re-weight.

## Required prior knowledge

- Computer networking basics (IP, TCP, UDP, firewalls).
- Basic operating-system knowledge (Linux command line).
- Light programming experience (Python preferred).

## Recommended reading

- Knapp \& Langill, *Industrial Network Security*, 2nd ed.
- Macaulay \& Singer, *Cybersecurity for Industrial Control Systems*.
- Bodungen et al., *Hacking Exposed: Industrial Control Systems*.
- NIST SP 800-82 Rev. 3.
- IEC 62443 standard series (institutional access).
- CISA ICS-CERT advisory archive.
- Dragos annual Year-in-Review reports.

## Tooling

- LaTeX (TeX Live) for slide / exercise compilation.
- VirtualBox / VMware / KVM for lab VMs.
- GNS3 or EVE-NG for network labs.
- OpenPLC, pymodbus, Wireshark, nmap (lab use only).
- Malcolm, Zeek, or Suricata for IDS labs.

## Companion: Master course

A follow-on Master-level course is planned under `master/`. It will assume this course as prerequisite and dive into offensive ICS techniques, firmware reverse engineering, secure-by-design architectures, and research projects.
