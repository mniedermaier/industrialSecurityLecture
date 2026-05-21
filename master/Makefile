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

.PHONY: all slides exercises solutions labs clean distclean

all: slides exercises solutions labs

slides:
	@for d in $(SECTION_DIRS); do $(MAKE) -C $$d slides || exit 1; done

exercises:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d exercises || exit 1; done

solutions:
	@for d in $(EXERCISE_DIRS); do $(MAKE) -C $$d solutions || exit 1; done

labs:
	$(MAKE) -C labs all

clean:
	@for d in $(SECTION_DIRS) $(EXERCISE_DIRS); do $(MAKE) -C $$d clean; done
	$(MAKE) -C labs clean

distclean:
	@for d in $(SECTION_DIRS) $(EXERCISE_DIRS); do $(MAKE) -C $$d distclean; done
	$(MAKE) -C labs distclean
