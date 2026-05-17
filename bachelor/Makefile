SECTION_DIRS := \
  sections/01-introduction \
  sections/02-ics-fundamentals \
  sections/03-network-architecture \
  sections/04-protocols \
  sections/05-threats \
  sections/06-vulnerabilities \
  sections/07-risk-management \
  sections/08-defense-in-depth \
  sections/09-standards \
  sections/10-incident-response

EXERCISE_DIRS := \
  exercises/01-introduction \
  exercises/02-ics-fundamentals \
  exercises/03-network-architecture \
  exercises/04-protocols \
  exercises/05-threats \
  exercises/06-vulnerabilities \
  exercises/07-risk-management \
  exercises/08-defense-in-depth \
  exercises/09-standards \
  exercises/10-incident-response

.PHONY: all slides notes exercises solutions labs handouts clean distclean

all: slides notes exercises solutions labs handouts

slides:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d slides || exit 1; done

notes:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d notes || exit 1; done

handouts: delivery-schedule.pdf acronyms.pdf

delivery-schedule.pdf: delivery-schedule.tex
	cd $(@D) && latexmk -pdf -interaction=nonstopmode -halt-on-error $(<F)

acronyms.pdf: acronyms.tex
	cd $(@D) && latexmk -pdf -interaction=nonstopmode -halt-on-error $(<F)

exercises:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d exercises || exit 1; done

solutions:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d solutions || exit 1; done

labs:
	$(MAKE) -C labs all

clean:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d clean; done
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d clean; done
	$(MAKE) -C labs clean

distclean:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d distclean; done
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d distclean; done
	$(MAKE) -C labs distclean
	rm -f delivery-schedule.pdf acronyms.pdf
	rm -f delivery-schedule.aux delivery-schedule.log delivery-schedule.fls delivery-schedule.fdb_latexmk delivery-schedule.out
	rm -f acronyms.aux acronyms.log acronyms.fls acronyms.fdb_latexmk acronyms.out
