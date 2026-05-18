# Branding theme examples

Drop-in `branding.tex` files that rebrand the entire course in a single
copy. See [`../../BRANDING.md`](../../BRANDING.md) for the full mechanism.

Each theme is named after its palette, not after any organisation. The
placeholder logos are generic "Your Logo" marks in the theme's colours
-- no trademarks anywhere in this folder.

| Theme                                                | Primary         | Accent              | Notes                                                  |
| ---------------------------------------------------- | --------------- | ------------------- | ------------------------------------------------------ |
| [`crimson/`](crimson/branding.tex)                   | `#C30E18` red   | `#3F4444` anthracite | Serious, university-style.                            |
| [`enterprise-navy/`](enterprise-navy/branding.tex)   | `#00205B` navy  | `#0099D8` cobalt    | Clean, large-organisation internal training look.     |
| [`generic-charcoal/`](generic-charcoal/branding.tex) | `#2C3E50` charcoal | `#1ABC9C` teal   | Neutral, brand-agnostic; good default for pilots.     |

Each folder ships a placeholder `logo.pdf` plus the `logo-source.tex`
that produced it -- standalone TikZ, transparent background, no
trademarks. Use as-is for internal pilots; if you have your own
licensed logo, drop it over the `logo.pdf` in the theme folder.

## Use it

```bash
# from the repo root:
cp branding/examples/<theme>/branding.tex branding.tex

# the branding.tex points the build at the theme's own logo
# (branding/examples/<theme>/logo.pdf). If you have your own logo,
# just overwrite that file:
# cp /path/to/your/logo.pdf branding/examples/<theme>/logo.pdf

make
```

The repo's default branding (navy + amber, generic hexagon logo) lives
in `branding.tex` at the repo root; replacing that file is the entire
rebrand surface.

## Adding your own theme

Copy one of the existing themes as a starting point:

```bash
mkdir -p branding/examples/my-theme
cp branding/examples/generic-charcoal/branding.tex branding/examples/my-theme/branding.tex
cp branding/examples/generic-charcoal/logo-source.tex branding/examples/my-theme/logo-source.tex
$EDITOR branding/examples/my-theme/branding.tex      # edit the two hex codes
$EDITOR branding/examples/my-theme/logo-source.tex   # adjust colours / text
( cd branding/examples/my-theme && pdflatex logo-source.tex && mv logo-source.pdf logo.pdf && rm -f *.aux *.log )
```

Then activate with `cp branding/examples/my-theme/branding.tex branding.tex && make`.

## What not to commit

Do not commit logos or wordmarks you do not have explicit redistribution
rights for. Most corporate brand centres restrict their wordmarks to
in-house use; the safe pattern is to keep a placeholder in the repo and
drop the real asset in locally on the machine that builds for that
audience.
