# Top-level Makefile for the Debian Web pages

LANGUAGES := english arabic catalan chinese croatian czech danish dutch \
             esperanto finnish french german greek hungarian indonesian \
             italian japanese korean lithuanian norwegian polish portuguese \
             romanian russian slovene spanish swedish turkish

LANGUAGES-install := $(addsuffix -install,$(LANGUAGES))
LANGUAGES-clean := $(addsuffix -clean,$(LANGUAGES))

.SUFFIXES: 
.PHONY: install all clean $(LANGUAGES) $(LANGUAGES-install)

all: $(LANGUAGES)

install: $(LANGUAGES-install)
clean: $(LANGUAGES-clean)

$(LANGUAGES-install):
	$(MAKE) -C $(subst -install,,$@) install

$(LANGUAGES-clean):
	$(MAKE) -C $(subst -clean,,$@) clean

$(LANGUAGES):
	$(MAKE) -C $@
