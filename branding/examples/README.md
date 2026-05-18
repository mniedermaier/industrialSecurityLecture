# Branding theme examples

Drop-in `branding.tex` files that rebrand the entire course in a single
copy. See [`../../BRANDING.md`](../../BRANDING.md) for the full mechanism.

| Theme                                              | Primary  | Accent   | Placeholder logo                | Suited to                                       |
| -------------------------------------------------- | -------- | -------- | ------------------------------- | ----------------------------------------------- |
| [`tha/`](tha/branding.tex)                         | `#C30E18` red    | `#3F4444` anthracite | `tha/logo.pdf` ("TH Augsburg")  | Technische Hochschule Augsburg                  |
| [`airbus/`](airbus/branding.tex)                   | `#00205B` navy   | `#0099D8` cobalt     | `airbus/logo.pdf` ("AIRBUS")    | Airbus internal training                        |
| [`generic-charcoal/`](generic-charcoal/branding.tex) | `#2C3E50` charcoal | `#1ABC9C` teal | `generic-charcoal/logo.pdf` (hex + "Your Logo") | Pilots, no strong corporate identity            |

Each theme folder ships its own placeholder logo plus the
`logo-source.tex` that produced it -- text-only, transparent
background, in the brand colours but **never the official trademark
wordmark**. Use them as-is for an internal pilot; replace
`logo.pdf` with the real licensed asset before any public release.

## Use it

```bash
# from the repo root:
cp branding/examples/<theme>/branding.tex branding.tex

# the branding.tex points the build at the theme's own logo
# (branding/examples/<theme>/logo.pdf). If you have the real licensed
# wordmark, just overwrite that file:
# cp /path/to/your/real-logo.pdf branding/examples/<theme>/logo.pdf

make
```

The repo's default branding (navy + amber, "Industrial Security" hex
logo) is what ships in `branding.tex` at the repo root; replacing that
file is the entire rebrand surface.

## Important: colour codes are approximations

These hex codes are reasonable approximations meant for quick previews
and internal pilots. Before any **public-facing** use of a corporate
identity (TH Augsburg, Airbus, etc.), verify the exact values against
the organisation's current Corporate Design / Brand & Identity guide
and confirm you are licensed to use the logo and trademarks.

## Adding your own

Copy one of the existing themes as a starting point:

```bash
mkdir -p branding/examples/my-org
cp branding/examples/generic-charcoal/branding.tex branding/examples/my-org/branding.tex
$EDITOR branding/examples/my-org/branding.tex
```

Edit the two `\definecolor` lines and the `\courseAuthor` /
`\courseInstitute` lines, then activate with `cp`. PRs that add new
example themes (with a placeholder logo, never a copyrighted one)
are welcome.
