# Industrial Security — Master Course (placeholder)

This directory is reserved for the advanced (Master-level) course in the Industrial Security lecture series. Once content is added, it will follow the same layout as `../bachelor/` and reuse the shared `../template/` so that styling and TikZ symbols remain consistent across courses.

## Planned topics (draft)

- Deep dive into industrial protocol internals (S7commPlus, GOOSE, MMS, DLMS/COSEM)
- Reverse engineering of PLC firmware and ladder code
- Offensive techniques against ICS in authorised lab environments
- Secure-by-design architectures for greenfield plants
- Threat intelligence for OT (Dragos, MITRE ATT&CK for ICS, INCONTROLLER/PIPEDREAM)
- Formal safety vs. security co-engineering
- Research methods and seminar work

## Adding content

When you start writing this course:

1. Create the same directory layout used by `bachelor/`: `sections/`, `labs/`, `docs/`, `Makefile`.
2. Reuse `../template/slides-preamble.tex` and `../template/tikz-styles.tex` from each slide deck (`\input{../../../template/slides-preamble.tex}`).
3. Add `master` to the `COURSES` variable in the top-level `Makefile`.

The shared template is intentionally course-agnostic and only requires that each deck defines `\courseTitle`, `\courseSubtitle`, `\sectionNumber`, and `\sectionTitle` before loading.
