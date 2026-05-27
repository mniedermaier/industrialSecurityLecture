# Top-level Makefile. Builds every course directory listed in COURSES.

COURSES := bachelor master

.PHONY: all $(COURSES) slides exercises solutions clean distclean check verify

all: $(COURSES)

bachelor:
	$(MAKE) -C bachelor all

master:
	$(MAKE) -C master all

slides:
	@for c in $(COURSES); do $(MAKE) -C $$c slides || exit 1; done

exercises:
	@for c in $(COURSES); do $(MAKE) -C $$c exercises || exit 1; done

solutions:
	@for c in $(COURSES); do $(MAKE) -C $$c solutions || exit 1; done

clean:
	@for c in $(COURSES); do $(MAKE) -C $$c clean; done

distclean:
	@for c in $(COURSES); do $(MAKE) -C $$c distclean; done

# Build everything, then fail if any LaTeX log reports an Overfull box.
# Use as a CI gate or pre-commit hook.
check: verify

verify: all
	@bad=$$(find $(COURSES) -name '*.log' -exec grep -l '^Overfull' {} \;); \
	if [ -n "$$bad" ]; then \
	  echo "OVERFULL boxes detected in:"; \
	  echo "$$bad" | sed 's/^/  /'; \
	  echo "Details:"; \
	  for f in $$bad; do echo "--- $$f ---"; grep '^Overfull' $$f; done; \
	  exit 1; \
	fi; \
	echo "OK: no overfull boxes"
