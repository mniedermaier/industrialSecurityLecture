# Corporate / Institutional Branding

Rebranding the entire course (slides, notes, exercises, labs) takes
under a minute and touches **two files**.

## The two files

| File                  | What it controls                                                            |
| --------------------- | --------------------------------------------------------------------------- |
| `branding/logo.pdf`   | The logo printed on every title page and the slide footer.                  |
| `branding.tex`        | Logo path, author / institute lines, brand colours.                         |

`branding.tex` is loaded automatically by the slides, exercise, and lab
preambles. You never need to edit any preamble file.

## Drop-in rebrand

1. **Replace the logo.** Put your corporate PDF/PNG/JPG at
   `branding/logo.pdf` (or `.png` / `.jpg`; pick one). PDF is sharpest.
   Aim for a roughly square asset; the deck scales it to 2 cm on the
   title slide and 1.5 cm in the footer.
2. **(Optional) change the brand colours** in `branding.tex`:
   ```latex
   \definecolor{slideAccent}{HTML}{1F4E79}     % primary
   \definecolor{slideSecondary}{HTML}{E08E0B}  % accent
   ```
   Both expect 6-digit hex codes. Keep enough contrast against white
   text in the title bar.
3. **(Optional) override author / institute:**
   ```latex
   \renewcommand{\courseAuthor}{Jane Doe}
   \renewcommand{\courseInstitute}{ACME Industrial Cyber Security Group}
   ```
4. **Rebuild:** `make` at the repo root. Everything picks up the new
   branding automatically.

## What stays untouched

The TikZ asset palette (`isOT`, `isPLC`, `isAttack`, etc.) used inside
diagrams is deliberately separate from the brand palette -- those
colours are pedagogical, not decorative. Don't change them just to
match a corporate identity, or the colour-coding across the deck will
stop being consistent.

## Fallback

If `branding.tex` is missing or you delete one of its lines, the
relevant default in `template/slides-preamble.tex`,
`template/exercise-preamble.tex`, or `template/lab-preamble.tex`
applies automatically. Nothing breaks.

## Quick test

After a rebrand, verify with:
```sh
make distclean && make
```
Open any section's `*-slides.pdf` -- the first page is the title page,
and that's where the new logo and colours land most visibly.
