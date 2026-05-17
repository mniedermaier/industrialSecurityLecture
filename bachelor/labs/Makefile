LAB_DIRS := \
  01-introduction \
  02-ics-fundamentals \
  03-network-architecture \
  04-protocols \
  05-threats \
  06-vulnerabilities \
  07-risk-management \
  08-defense-in-depth \
  09-standards \
  10-incident-response

.PHONY: all clean distclean stack-up stack-down

all:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d all || exit 1; done

clean:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d clean; done

distclean:
	@for d in $(LAB_DIRS); do $(MAKE) -C $$d distclean; done

stack-up:
	cd _stack && docker compose up -d

stack-down:
	cd _stack && docker compose down -v
