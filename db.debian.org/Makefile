# special Makefile
# requires a checkout of webwml/template/debian from the webwml tree!

TEMPLDIR := ../../webwml/english/template/debian
DEBTEMPLATES := $(wildcard $(TEMPLDIR)/*.wml) \
                $(wildcard template/*.wml) \
                .wmlrc
TARGETDIR := /var/www/userdir-ldap

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(subst .wml,.html,$(WMLFILES))
DESTHTMLFILES := $(patsubst %.wml,$(TARGETDIR)/%.html,$(WMLFILES))
OTHERFILES := $(wildcard *.cgi) $(wildcard *.cfg) $(wildcard *.tab)
DESTOTHERFILES := $(patsubst %,$(TARGETDIR)/%,$(OTHERFILES))

WML_DEFS :=

all: $(HTMLFILES)

%.html: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

install: $(DESTHTMLFILES) $(DESTOTHERFILES)

$(DESTHTMLFILES) $(DESTOTHERFILES): $(TARGETDIR)/%: %
	@test -d $(TARGETDIR) || mkdir -p $(TARGETDIR)
	install -m 644 -p $(@F) $(TARGETDIR)

clean:
	rm -f $(HTMLFILES)

.SUFFIXES:
