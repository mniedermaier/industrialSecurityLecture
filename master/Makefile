SECTION_DIRS  := \
  sections/01-firmware-re \
  sections/02-plc-ladder-re \
  sections/03-advanced-protocols \
  sections/04-offensive-ics

EXERCISE_DIRS := \
  exercises/01-firmware-re \
  exercises/02-plc-ladder-re \
  exercises/03-advanced-protocols \
  exercises/04-offensive-ics

LAB_DIRS := \
  labs/01-firmware-re \
  labs/02-plc-ladder-re \
  labs/03-advanced-protocols \
  labs/04-offensive-ics

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
