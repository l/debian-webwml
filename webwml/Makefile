# Top-level Makefile for the Debian Web pages

LANGUAGES := arabic chinese croatian danish dutch english esperanto finnish \
             french german hungarian italian japanese korean norwegian \
             polish portuguese romanian russian spanish swedish turkish

.SUFFIXES: 
.PHONY: install all ${LANGUAGES}

install:
	for d in ${LANGUAGES}; do $(MAKE) -C $$d install; done

${LANGUAGES}:
	${MAKE} -C $@

all: ${LANGUAGES}

