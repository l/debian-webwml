# Makefile to build HTML + PHP files from WML files
# requires a checkout of webwml/template/debian from the webwml tree!

TEMPLDIR := ../webwml/english/template/debian
DEBTEMPLATES := $(wildcard $(TEMPLDIR)/*.wml) \
                $(wildcard template/*.wml) \
                .wmlrc
TARGETDIR := ../../web

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(subst .wml,.html,$(shell egrep -L '(<\?|::gpgpage)' $(WMLFILES)))
PHPFILES := $(subst .wml,.php,$(shell egrep -l '(<\?|::gpgpage)' $(WMLFILES)))
INCFILES := $(wildcard *.inc)
CSSFILES := $(wildcard $(TEMPLDIR)/../../*.css)
DESTHTMLFILES := $(patsubst %,$(TARGETDIR)/%,$(HTMLFILES))
DESTPHPFILES := $(patsubst %,$(TARGETDIR)/%,$(PHPFILES))
DESTINCFILES := $(patsubst %,$(TARGETDIR)/%,$(INCFILES))
DESTCSSFILES := $(subst $(TEMPLDIR)/../..,$(TARGETDIR),$(CSSFILES))

WML_DEFS := -I $(subst /debian,,$(TEMPLDIR))

all: $(HTMLFILES) $(PHPFILES)

%.html: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

%.php: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

install: $(DESTHTMLFILES) $(DESTPHPFILES) $(DESTINCFILES) $(DESTCSSFILES)

$(DESTHTMLFILES) $(DESTPHPFILES) $(DESTINCFILES): $(TARGETDIR)/%: %
	@test -d $(TARGETDIR) || mkdir -p $(TARGETDIR)
	install -m 644 -p $(@F) $(TARGETDIR)

$(DESTCSSFILES): $(CSSFILES)
	@test -d $(TARGETDIR) || mkdir -p $(TARGETDIR)
	install -m 644 -p $? $(TARGETDIR)

rsync: $(HTMLFILES) $(PHPFILES)
	rsync -e ssh $(HTMLFILES) $(PHPFILES) $(INCFILES) nm.debian.org:/org/nm.debian.org/web

backup:
	rsync -e ssh -r template $(WMLFILES) $(INCFILES) Makefile nm.debian.org:/org/nm.debian.org/wml

clean:
	rm -f $(HTMLFILES) $(PHPFILES)

.SUFFIXES:
