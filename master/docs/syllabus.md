# Syllabus -- Industrial Security (Master, pilot)

Advanced course; assumes the Bachelor course as prerequisite.

## Sections (current state)

| # | Topic | Status |
|---|-------|--------|
| 01 | Firmware Reverse Engineering              | available |
| 02 | PLC Ladder Logic Reverse Engineering       | available |
| 03 | Advanced Industrial Protocols (S7commPlus, GOOSE, MMS, DLMS/COSEM) | available |
| 04 | Offensive ICS in Authorised Labs           | available |
| 05 | Secure-by-design architectures for greenfield plants | planned |
| 06 | Threat intelligence for OT (PIPEDREAM, Volt Typhoon) | planned |
| 07 | Formal safety / security co-engineering    | planned |
| 08 | Research methods and seminar work          | planned |

Each available section ships with: slide deck (PDF), exercise sheet, solution sheet, and a hands-on lab guide.

## Building

```
make -C master         # build the four available pilots
make verify            # zero-overflow gate from the repo root
```

Sections 01--04 reuse the same `template/` and Docker lab stack as the Bachelor course.
