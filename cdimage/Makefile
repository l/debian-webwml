# Top-level Makefile for the Debian Web pages

languages := english

languages-install := $(addsuffix -install,$(languages))

.SUFFIXES: 
.PHONY: install all $(languages) $(languages-install)

install: $(languages-install)

all: $(languages)

$(languages-install):
	$(MAKE) -C $(subst -install,,$@) install

$(languages):
	$(MAKE) -C $@
