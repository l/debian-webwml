# Top-level Makefile for the Debian Web pages

LANGUAGES := english arabic armenian bulgarian catalan chinese croatian czech \
             danish dutch esperanto finnish french german greek \
             hungarian indonesian italian japanese korean lithuanian \
             norwegian persian polish portuguese romanian russian slovak slovene \
             spanish swedish turkish ukrainian

LANGUAGES-install := $(addsuffix -install,$(LANGUAGES))
LANGUAGES-clean := $(addsuffix -clean,$(LANGUAGES))

.SUFFIXES: 
.PHONY: install all clean $(LANGUAGES) $(LANGUAGES-install)

all: $(LANGUAGES)

install: $(LANGUAGES-install)
clean: $(LANGUAGES-clean)
	rm -fr locale

$(LANGUAGES-install):
	$(MAKE) -C $(subst -install,,$@) install

$(LANGUAGES-clean):
	$(MAKE) -C $(subst -clean,,$@) clean

$(LANGUAGES):
	$(MAKE) -C $@
