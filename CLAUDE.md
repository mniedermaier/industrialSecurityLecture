# Project rules for Claude

This file pins down constraints that must hold across the repo. Treat them as load-bearing — break them and the build is wrong.

## Build invariants

- **No overflow.** Slides, exercise sheets, lab sheets must build with **zero** `Overfull \hbox` or `Overfull \vbox` warnings, horizontal or vertical. Treat any overflow as a build failure, not a cosmetic warning.
- Every section deck must compile to a PDF (`make` from repo root succeeds for every course).
- Section dividers, learning-objectives frames, and the closing frame come from the shared template — do not redefine them per-section.
- The CI gate is `make verify` (top-level). It must exit 0.

## Build verification

`make verify` builds the whole repo and fails the moment any LaTeX log contains a line starting with `Overfull`. Run it before every commit that touches `.tex` or template files.

```
make distclean && make verify
```

A clean run prints `OK: no overfull boxes` and exits 0. Anything else is a defect that must be fixed, not ignored.

## Visual QA

After a clean build, render slides with `pdftoppm -r 100 -png …` and inspect for:
- Text or graphics colliding with the title bar, footer, or slide edges.
- TikZ labels sitting on top of nodes/arrows.
- Content clipped at any margin.
- Inside a `tikzpicture`: no text overlay on top of an arrow line, no label sitting on top of another node, no text bleeding out of its containing box. Edge labels should sit clearly above/below the line (use explicit `above`/`below` + small `yshift`), never *on* the line. Two nodes must never share pixels.
- Verbatim/listing blocks must fit inside the code frame: no line of code or comment may touch or run past the right rule.

For larger reviews spawn parallel agents — one per section — and feed them every PNG with explicit defect criteria. Agents return concise lists you can act on.

## Typography

- Primary text family is **IBM Plex Sans** (`plex-sans`); code is **IBM Plex Mono** (`plex-mono`). Math stays in Latin Modern (lmodern via amsmath default).
- `\familydefault` is `\sfdefault`. Do not switch to serif inside body text.
- Microtype is on with tracking, kerning, and protrusion. Do not disable it.

## Layout rules

- Slide canvas is 16 cm × 9 cm. Content area is ~12.8 cm wide. Anything wider than ~110 mm overflows.
- TikZ pictures wider than the canvas must be scaled (`scale=0.8, transform shape`) or restructured.
- Long titles must wrap. Never let a title push past `0.85\paperwidth`.
- Callout boxes (`notebox`, `importantbox`, `warningbox`/`warnbox`, `tipbox`, `defbox`, `takeawaybox`) come from `template/slides-preamble.tex` — do not redefine them. They carry a subtle drop shadow by default.
- Callout titles that contain commas must be brace-protected: `\begin{notebox}{Natanz, 2010}` works because the template wraps `#1` in `{}`. If you redefine callouts, preserve this brace.

## TikZ rules (strict)

- **Arrows never cross nodes.** An arrow from A to B must take a clear path: use `to[bend left]`, intermediate coordinates, or `|-` / `-|` only when you have *verified* the path does not enter or graze any other node. If the cleanest path crosses a node, redesign the layout.
- **Edge labels sit clearly off the line.** Use `node[above, font=\tiny, yshift=1mm]{…}` or `sloped, above` — never let a label intersect the arrow stroke. White-background fill (`fill=white, inner sep=1pt`) is the standard pattern when an arrow must pass under a label.
- **No two nodes share pixels.** If two nodes are close enough to touch, increase `node distance` or add explicit positioning. Anchor positions (`.east`, `.west`, `.north`, `.south`) make connections deterministic.
- **Always test the rendered output.** After editing a TikZ picture, rebuild, render the slide to PNG (`pdftoppm -r 100 -png -f N -l N file.pdf /tmp/check`), and look at it. Do not trust the source — trust the pixels.
- **Prefer simple flows.** A left-to-right or top-to-bottom chain beats a wrap-around path. If a diagram needs a closed loop, separate the return path so it does not overlay the forward path.

## Source attribution

- Every slide that states a non-trivial fact (incident, statistic, standard reference, vendor advisory, methodology) **must carry a source**. Use the `\source{…}` macro at the bottom of the frame.
- Sources must be checked. If you cannot verify a source on the web or in a printed reference, do not cite it. Prefer:
  - **CISA / vendor PSIRT advisories** (cite the advisory ID and date: e.g. `CISA AA22-103A, 13 Apr 2022`).
  - **Standards bodies** (IEC / ISO / IEEE / NIST / FIRST), cited with the standard number + year.
  - **Peer-reviewed papers, formal reports** (Symantec/Dragos/Mandiant/SANS), cited with author + title + year.
  - **Regulations**, cited with their formal identifier (Directive (EU) 2022/2555).
- Inline-source style:
  ```
  \source{N.\ Falliere et al., \emph{W32.Stuxnet Dossier}, Symantec, 2011 \textbar{} D.\ Albright et al., ISIS, 2010.}
  ```
- Do **not** invent URLs. If a source needs a URL, paste only one you have actually seen (use `\url{…}` so hyperref handles escaping).

## Structure rules

- Slide source lives in `<course>/sections/NN-topic/slides.tex`.
- Exercise + solution source lives in `<course>/exercises/NN-topic/`.
- Labs live in `<course>/labs/NN-topic/`. The shared Docker stack lives in `<course>/labs/_stack/`.
- Shared template lives under `template/` and is reused by Bachelor, Master, and any future level.
- Each per-leaf directory has a one-line `Makefile` that includes the matching `template/*.mk`.

## When in doubt

Prefer narrower diagrams, smaller fonts, or splitting a slide over letting content spill off the page. Overflow is never acceptable.
