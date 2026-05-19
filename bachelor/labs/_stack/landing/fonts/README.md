# Bundled fonts

The landing page bundles **IBM Plex Sans** and **IBM Plex Mono** locally so the page works fully offline — no Google Fonts CDN required.

| File                      | Family         | Weight | Size  |
|---------------------------|----------------|--------|-------|
| `IBMPlexSans-400.woff2`   | IBM Plex Sans  | 400    | ~45 KB |
| `IBMPlexSans-500.woff2`   | IBM Plex Sans  | 500    | ~45 KB |
| `IBMPlexSans-600.woff2`   | IBM Plex Sans  | 600    | ~45 KB |
| `IBMPlexSans-700.woff2`   | IBM Plex Sans  | 700    | ~45 KB |
| `IBMPlexMono-400.woff2`   | IBM Plex Mono  | 400    | ~14 KB |
| `IBMPlexMono-600.woff2`   | IBM Plex Mono  | 600    | ~15 KB |

Total: ~210 KB. Only the latin subset is shipped (sufficient for the English landing page).

## License

IBM Plex is licensed under the **SIL Open Font License Version 1.1** (OFL-1.1). The full text is in [`LICENSE-OFL.txt`](LICENSE-OFL.txt). The OFL explicitly permits bundling and redistribution of the font files as part of a software project, on three conditions, which this distribution honours:

1. The original copyright and license notice are preserved (see `LICENSE-OFL.txt`).
2. The fonts themselves are not sold as a standalone product.
3. The Reserved Font Name "Plex" is not used in derivative font names.

Source: <https://github.com/IBM/plex>. The WOFF2 files in this directory are the latin subset of the upstream WOFF2 builds served by Google Fonts; subsetting was performed by Google and the resulting files are still licensed under OFL-1.1.

## How they are wired up

The page's `style.css` declares each weight with a local `@font-face` block, e.g.

```css
@font-face {
  font-family: "IBM Plex Sans";
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url("fonts/IBMPlexSans-400.woff2") format("woff2");
}
```

`index.html` no longer fetches anything from `fonts.googleapis.com` or `fonts.gstatic.com`.
