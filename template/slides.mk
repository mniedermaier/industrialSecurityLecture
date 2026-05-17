# Shared Makefile rules for a section directory (slides only).
# Each section's Makefile does `include ../../../template/slides.mk`.
#
# Output PDF is prefixed with the section directory name, e.g.
# `01-introduction-slides.pdf`.

SECTION_NAME := $(notdir $(CURDIR))
LATEX        := latexmk
LATEX_FLAGS  := -pdf -interaction=nonstopmode -halt-on-error -file-line-error
SLIDES_PDF   := $(SECTION_NAME)-slides.pdf

.PHONY: all slides clean distclean

all: $(SLIDES_PDF)
slides: $(SLIDES_PDF)

$(SLIDES_PDF): slides.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-slides $<

# Convenience alias.
slides.pdf: $(SLIDES_PDF)

clean:
	$(LATEX) -c -jobname=$(SECTION_NAME)-slides 2>/dev/null || true
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.synctex.gz *.fls *.fdb_latexmk *.bbl *.blg

distclean: clean
	rm -f $(SLIDES_PDF)
