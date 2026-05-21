LAB_DIRS := \
  01-firmware-re \
  02-plc-ladder-re \
  03-advanced-protocols \
  04-offensive-ics \
  05-secure-by-design \
  06-threat-intel \
  07-safety-security \
  08-research-methods

.PHONY: all clean distclean

all:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d all || exit 1; done

clean:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d clean; done

distclean:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d distclean; done
