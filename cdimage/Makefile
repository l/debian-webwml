# Top-level Makefile for the Debian Web pages

languages := english

languages-install := $(addsuffix -install,$(languages))

.SUFFIXES: 
.PHONY: install all $(languages) $(languages-install)

all: $(languages)

install: $(languages-install)

$(languages):
	$(MAKE) -C $@

$(languages-install):
	$(MAKE) -C $(subst -install,,$@) install
