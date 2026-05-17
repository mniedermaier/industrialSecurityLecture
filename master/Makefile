SECTIONS := \
  01-firmware-re \
  02-plc-ladder-re \
  03-advanced-protocols \
  04-offensive-ics \
  05-secure-by-design \
  06-threat-intel \
  07-safety-security \
  08-research-methods

SECTION_DIRS  := $(addprefix sections/,$(SECTIONS))
EXERCISE_DIRS := $(addprefix exercises/,$(SECTIONS))
LAB_DIRS      := $(addprefix labs/,$(SECTIONS))

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
