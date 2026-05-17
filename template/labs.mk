# Shared Makefile rules for a lab directory.
# Each lab's Makefile does `include ../../../template/labs.mk`.
#
# Output PDF is prefixed with the section directory name:
#   01-introduction-lab.pdf
#   02-ics-fundamentals-lab.pdf
#   ...

SECTION_NAME := $(notdir $(CURDIR))
LATEX        := latexmk
LATEX_FLAGS  := -pdf -interaction=nonstopmode -halt-on-error -file-line-error
LAB_PDF      := $(SECTION_NAME)-lab.pdf

.PHONY: all clean distclean

all: $(LAB_PDF)

$(LAB_PDF): lab.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-lab $<

clean:
	$(LATEX) -c -jobname=$(SECTION_NAME)-lab 2>/dev/null || true
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.synctex.gz *.fls *.fdb_latexmk

distclean: clean
	rm -f $(LAB_PDF)
