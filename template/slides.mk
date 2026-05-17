# Shared Makefile rules for a section directory (slides + speaker notes).
# Each section's Makefile does `include ../../../template/slides.mk`.
#
# Output PDFs are prefixed with the section directory name:
#   NN-topic-slides.pdf   clean slides for projection
#   NN-topic-notes.pdf    slide-on-left, notes-on-right for the lecturer

SECTION_NAME := $(notdir $(CURDIR))
LATEX        := latexmk
LATEX_FLAGS  := -pdf -interaction=nonstopmode -halt-on-error -file-line-error
SLIDES_PDF   := $(SECTION_NAME)-slides.pdf
NOTES_PDF    := $(SECTION_NAME)-notes.pdf

.PHONY: all slides notes clean distclean

all: $(SLIDES_PDF) $(NOTES_PDF)
slides: $(SLIDES_PDF)
notes: $(NOTES_PDF)

$(SLIDES_PDF): slides.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-slides $<

$(NOTES_PDF): slides.tex
	$(LATEX) $(LATEX_FLAGS) -jobname=$(SECTION_NAME)-notes \
	  -usepretex='\def\notesmode{1}' $<

# Convenience aliases.
slides.pdf: $(SLIDES_PDF)
notes.pdf: $(NOTES_PDF)

clean:
	$(LATEX) -c -jobname=$(SECTION_NAME)-slides 2>/dev/null || true
	$(LATEX) -c -jobname=$(SECTION_NAME)-notes  2>/dev/null || true
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb *.synctex.gz *.fls *.fdb_latexmk *.bbl *.blg

distclean: clean
	rm -f $(SLIDES_PDF) $(NOTES_PDF)
