# This Makefile should need no changes from webwml/english/po/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=po

include $(WMLBASE)/Make.lang

LOCALEROOT = $(WMLBASE)/../locale

DOMAINS = templates ports bugs

POTFILES = $(addprefix $(ENGLISHDIR)/po/,$(addsuffix .pot,$(DOMAINS)))
MOFILES = $(addsuffix .mo,$(DOMAINS))

TEMPLATE_FILES  = $(wildcard $(TEMPLDIR)/*.wml $(TEMPLDIR)/*/*.wml) $(TEMPLDIR)/countries.def
PORTS_FILES     = $(ENGLISHDIR)/ports/menu.defs $(ENGLISHDIR)/ports/mips/cpu.data $(wildcard $(ENGLISHDIR)/ports/*/menu.inc)
BUGS_FILES     = $(ENGLISHDIR)/Bugs/pkgreport-opts.inc

ifeq "$(LANGUAGE)" "en"
all:: $(POTFILES)
else
all:: $(MOFILES)
install:: install-mo
endif

$(ENGLISHDIR)/po/templates.pot: $(TEMPLATE_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(TEMPLATE_FILES) > $@

$(ENGLISHDIR)/po/ports.pot: $(PORTS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(PORTS_FILES) > $@

$(ENGLISHDIR)/po/bugs.pot: $(BUGS_FILES)
	$(ENGLISHDIR)/po/wmlxgettext.pl -p $(WMLBASE)/../= $(BUGS_FILES) > $@

%.mo: %.$(LANGUAGE).po
	msgfmt --statistics -o $@ $*.$(LANGUAGE).po

init-po:
	for d in $(DOMAINS); do \
	  cp $(ENGLISHDIR)/po/$$d.pot $$d.$(LANGUAGE).po; \
	done

update-po:
	for d in $(DOMAINS); do \
	  msgmerge -q $$d.$(LANGUAGE).po $(ENGLISHDIR)/po/$$d.pot -o $$d.$(LANGUAGE).po.new && mv $$d.$(LANGUAGE).po.new $$d.$(LANGUAGE).po; \
	done

install-mo: $(MOFILES)
	[ -d $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES ] || mkdir -p $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES
	for d in $(DOMAINS); do \
          if [ -f $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo ]; then \
            cmp $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo >/dev/null 2>&1 \
            || cp -f $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo; \
          else \
            cp -f $$d.mo $(LOCALEROOT)/$(LANGUAGE)/LC_MESSAGES/$$d.mo; \
          fi; \
        done

clean::
	-rm -f *.pot *.mo

