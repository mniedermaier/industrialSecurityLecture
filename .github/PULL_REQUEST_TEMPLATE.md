<!--
Thank you for contributing to the Industrial Security Lecture Series.
Please fill in the sections below. Items in [brackets] are hints, not headings.
-->

## Summary

<!-- One or two sentences. What does this PR change and why? -->

## Type of change

- [ ] Slide content edit (new frame, fixed typo, updated source)
- [ ] Exercise / solution change
- [ ] Lab content / Docker stack change
- [ ] Template / build-system change
- [ ] CI / tooling
- [ ] Documentation only

## Build status

- [ ] `make distclean && make verify` exits 0 locally
- [ ] No new `Overfull \hbox` or `Overfull \vbox` lines in any LaTeX log
- [ ] If labs were touched: `bachelor/labs/preflight.sh` passes locally

## Repo invariants checked

<!-- See CLAUDE.md for the full list. -->

- [ ] Every new ICS/OT term has an IT analogue on first use (audience = IT students)
- [ ] Every new factual claim carries a `\source{...}` block with a verifiable citation
- [ ] No invented URLs; CISA advisories cited by ID + date; IEC standards by number + year
- [ ] TikZ diagrams: arrows don't cross nodes; labels sit clearly off the line; no two nodes share pixels
- [ ] Callout boxes used from the shared template (no per-section redefinitions)

## Screenshots / rendered output

<!-- For slide / lab changes, paste a `pdftoppm` render of the new or changed frame(s). -->

## Notes for reviewer

<!-- Anything unusual? Subjective design choices? Open questions? -->
