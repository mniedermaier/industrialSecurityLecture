# Syllabus -- Industrial Security (Master)

Advanced course; assumes the Bachelor course as prerequisite.
Target volume: ~60 hours of lecture + exercise + lab work, eight sections.

## Sections

| #  | Topic                                                            | Pages |
|----|------------------------------------------------------------------|-------|
| 01 | Firmware Reverse Engineering                                      | 19    |
| 02 | PLC Ladder Logic Reverse Engineering                              | 23    |
| 03 | Advanced Industrial Protocols (S7commPlus, GOOSE, MMS, DLMS/COSEM) | 21   |
| 04 | Offensive ICS in Authorised Labs                                  | 20    |
| 05 | Secure-by-Design Architectures                                    | 24    |
| 06 | Threat Intelligence for OT                                        | 24    |
| 07 | Safety / Security Co-Engineering                                  | 21    |
| 08 | Research Methods and Seminar Work                                 | 22    |

Each section ships with: slide deck (PDF), exercise sheet, solution sheet, and a hands-on lab guide.

## Building

```
make -C master        # build everything for the Master course
make verify           # zero-overflow gate from the repo root
```

All sections reuse the shared `template/` and most reuse the Bachelor `bachelor/labs/_stack/` Docker stack.
