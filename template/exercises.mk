# Shared Makefile rules for an exercise directory.
# Each exercise's Makefile does `include ../../../template/exercises.mk`.
#
# Output PDFs are prefixed with the directory name, e.g.
# `01-introduction-exercises.pdf` and `01-introduction-solutions.pdf`.

SECTION_NAME  := $(notdir $(CURDIR))
LATEX         := latexmk
LATEX_FLAGS   := -pdf -interaction=nonstopmode -halt-on-error -file-line-error
EXERCISES_PDF := $(SECTION_NAME)-exercises.pdf
SOLUTIONS_PDF := $(SECTION_NAME)-solutions.pdf

.PHONY: all exercises solutions clean distclean

all: $(EXERCISES_PDF) $(SOLUTIONS_PDF)
exercises: $(EXERCISES_PDF)
solutions: $(SOLUTIONS_PDF)

$(EXERCISES_PDF): exercises.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-exercises $<

$(SOLUTIONS_PDF): solutions.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-solutions $<

clean:
	$(LATEX) -c -jobname=$(SECTION_NAME)-exercises 2>/dev/null || true
	$(LATEX) -c -jobname=$(SECTION_NAME)-solutions 2>/dev/null || true
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.synctex.gz *.fls *.fdb_latexmk *.bbl *.blg

distclean: clean
	rm -f $(EXERCISES_PDF) $(SOLUTIONS_PDF)
