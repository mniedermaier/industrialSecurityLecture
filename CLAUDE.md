# Project rules for Claude

This file pins down constraints that must hold across the repo. Treat them as load-bearing — break them and the build is wrong.

## Build invariants

- **No overflow.** Slides and exercise sheets must build with **zero** `Overfull \hbox` or `Overfull \vbox` warnings, horizontal or vertical. Treat any overflow as a build failure, not a cosmetic warning.
- Every section deck must compile to a PDF (`make` from repo root succeeds for every section).
- Section dividers, learning-objectives frames, and the closing frame come from the shared template — do not redefine them per-section.

## Build verification

When changing slide source, after running `make` (or `latexmk`), grep the per-section build logs for `Overfull \\` and fix every match. The repo's intent is that:

```
make clean && make 2>&1 | grep -E "^Overfull \\\\(h|v)box"
```

returns **no output**. Add it as the last step of any work that touches `slides.tex` or the templates.

## Visual QA

After a clean build, render slides with `pdftoppm -r 80 -png …` and inspect for:
- Text or graphics colliding with the title bar, footer, or slide edges.
- TikZ labels sitting on top of nodes/arrows.
- Content clipped at any margin.
- Inside a `tikzpicture`: no text overlay on top of an arrow line, no label sitting on top of another node, no text bleeding out of its containing box. Edge labels should sit clearly above/below the line (use explicit `above`/`below` + small `yshift`), never *on* the line. Two nodes must never share pixels.
- Verbatim/listing blocks must fit inside the code frame: no line of code or comment may touch or run past the right rule.

Fix issues before committing.

## Layout rules

- Slide canvas is 16 cm × 9 cm. Content area is ~12.8 cm wide. Anything wider than ~110 mm overflows.
- TikZ pictures wider than the canvas must be scaled (`scale=0.8, transform shape`) or restructured.
- Long titles must wrap. Never let a title push past `0.85\paperwidth`.
- Callout boxes (`notebox`, `importantbox`, `warningbox`, `tipbox`, `defbox`, `takeawaybox`) come from `template/slides-preamble.tex` — do not redefine them.
- Callout titles that contain commas must be brace-protected: `\begin{notebox}{Natanz, 2010}` works because the template now wraps `#1` in `{}`. If you redefine callouts, preserve this brace.

## TikZ rules (strict)

- **Arrows never cross nodes.** An arrow from A to B must take a clear path: use `to[bend left]`, intermediate coordinates, or `|-` / `-|` only when you have *verified* the path does not enter or graze any other node. If the cleanest path crosses a node, redesign the layout.
- **Edge labels sit clearly off the line.** Use `node[above, font=\tiny, yshift=1mm]{…}` or `sloped, above` — never let a label intersect the arrow stroke.
- **No two nodes share pixels.** If two nodes are close enough to touch, increase `node distance` or add explicit positioning. Anchor positions (`.east`, `.west`, `.north`, `.south`) make connections deterministic.
- **Always test the rendered output.** After editing a TikZ picture, rebuild, render the slide to PNG (`pdftoppm -r 90 -png -f N -l N file.pdf /tmp/check`), and look at it. Do not trust the source — trust the pixels.
- **Prefer simple flows.** A left-to-right or top-to-bottom chain beats a wrap-around path. If a diagram needs a closed loop, separate the return path so it does not overlay the forward path.

## Structure rules

- Slide source lives in `bachelor/sections/NN-topic/slides.tex`.
- Exercise + solution source lives in `bachelor/exercises/NN-topic/`.
- Labs are a single Docker Compose stack under `bachelor/labs/`.
- Shared template lives under `template/` and is reused by Bachelor and (later) Master.

## When in doubt

Prefer narrower diagrams, smaller fonts, or splitting a slide over letting content spill off the page. Overflow is never acceptable.
