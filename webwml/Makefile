# Top-level Makefile for the Debian Web pages

LANGUAGES := english catalan chinese croatian danish dutch esperanto \
             finnish french german greek hungarian italian japanese korean \
             norwegian polish portuguese romanian russian spanish swedish \
             turkish
# existing translations that have been removed due to neglect:
# arabic

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
