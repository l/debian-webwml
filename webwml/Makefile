# Top-level Makefile for the Debian Web pages

LANGUAGES := arabic chinese croatian danish dutch english esperanto finnish \
             french german hungarian italian japanese korean norwegian \
             polish portuguese romanian russian spanish swedish turkish
LANGUAGES-install := $(addsuffix -install,${LANGUAGES})

.SUFFIXES: 
.PHONY: install all ${LANGUAGES} ${LANGUAGES-install}

install: ${LANGUAGES-install}

all: ${LANGUAGES}

${LANGUAGES-install}:
	${MAKE} -C $(subst -install,,$@) install

${LANGUAGES}:
	${MAKE} -C $@
