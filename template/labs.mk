# Shared Makefile rules for a lab directory.
# Each lab's Makefile does `include ../../../template/labs.mk`.
#
# Output PDFs are prefixed with the section directory name:
#   NN-topic-lab.pdf
#   NN-topic-lab-solutions.pdf   (only if lab-solutions.tex is present)

SECTION_NAME := $(notdir $(CURDIR))
LATEX        := latexmk
LATEX_FLAGS  := -pdf -interaction=nonstopmode -halt-on-error -file-line-error
LAB_PDF      := $(SECTION_NAME)-lab.pdf
SOL_PDF      := $(SECTION_NAME)-lab-solutions.pdf

# Only build the solution sheet if its source actually exists in this
# lab directory; paper-only labs may not have one yet.
SOL_TARGET := $(if $(wildcard lab-solutions.tex),$(SOL_PDF),)

.PHONY: all clean distclean

all: $(LAB_PDF) $(SOL_TARGET)

$(LAB_PDF): lab.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-lab $<

$(SOL_PDF): lab-solutions.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-lab-solutions $<

clean:
	$(LATEX) -c -jobname=$(SECTION_NAME)-lab           2>/dev/null || true
	$(LATEX) -c -jobname=$(SECTION_NAME)-lab-solutions 2>/dev/null || true
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.synctex.gz *.fls *.fdb_latexmk

distclean: clean
	rm -f $(LAB_PDF) $(SOL_PDF)
