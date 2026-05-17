SECTION_DIRS  := sections/01-firmware-re
EXERCISE_DIRS := exercises/01-firmware-re
LAB_DIRS      := labs/01-firmware-re

.PHONY: all slides exercises solutions labs clean distclean

all: slides exercises solutions labs

slides:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d slides || exit 1; done

exercises:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d exercises || exit 1; done

solutions:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d solutions || exit 1; done

labs:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d all || exit 1; done

clean:
	@for d in $(SECTION_DIRS) $(EXERCISE_DIRS) $(LAB_DIRS); do $(MAKE) -C $$d clean; done

distclean:
	@for d in $(SECTION_DIRS) $(EXERCISE_DIRS) $(LAB_DIRS); do $(MAKE) -C $$d distclean; done
