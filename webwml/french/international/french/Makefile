# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/french
SUBS=

include $(WMLBASE)/Make.lang

CTDOCFILES := a-relire.$(LANGUAGE).html a-reviser.$(LANGUAGE).html en-cours.$(LANGUAGE).html a-traduire.$(LANGUAGE).html non-disponible.$(LANGUAGE).html ok.$(LANGUAGE).html

CTWEBFILES := www-a-relire.$(LANGUAGE).html www-a-reviser.$(LANGUAGE).html www-en-cours.$(LANGUAGE).html www-a-traduire.$(LANGUAGE).html

GENFILES = $(CTDOCFILES) $(CTWEBFILES)
GENDESTFILES = $(patsubst %.$(LANGUAGE).html,$(HTMLDIR)/%.$(LANGUAGE).html,$(GENFILES))

all:: $(CTDOCFILES) $(CTWEBFILES)

check_trans.status: FORCE
	perl create_status.pl > check_trans.status.new
	if [ -f check_trans.status ]; then \
		cmp check_trans.status check_trans.status.new >/dev/null 2>&1 \
		|| mv check_trans.status.new check_trans.status; \
	else \
		mv check_trans.status.new check_trans.status; \
	fi

FORCE:
	@:

$(CTDOCFILES): docpages.src documents-bd.pl doccurrent_status.pl
	wml -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_TRANS:a-traduire.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_OUT:a-reviser.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_CHECK:a-relire.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_WIP:en-cours.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_FUTURE:non-disponible.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_OK:ok.$(LANGUAGE).html@g+w" \
  docpages.src

$(CTWEBFILES): webpages.src webcurrent_status.pl check_trans.status
	wml -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_TRANS:www-a-traduire.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_OUT:www-a-reviser.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_CHECK:www-a-relire.$(LANGUAGE).html@g+w" \
  -o "(UNDEF+$(LANGUAGECAP)-CT_*)+CT_WIP:www-en-cours.$(LANGUAGE).html@g+w" \
  webpages.src

stats.$(LANGUAGE).html: documents-bd.pl doccurrent_status.pl webcurrent_status.pl check_trans.status

# ask to install the debian-l10-french-faq files

DLFFDIR := debian-l10n-french-faq.html
DLFFSOURCE := $(wildcard $(DLFFDIR)/*.html)
DLFFDESTFILES := $(patsubst %,$(HTMLDIR)/%,$(DLFFSOURCE))
DLFFDESTDIR := $(HTMLDIR)/$(DLFFDIR)

install::
	test -d $(DLFFDESTDIR) || mkdir -p -m g+w $(DLFFDESTDIR)
install:: $(DLFFDESTFILES) $(GENDESTFILES)

$(DLFFDESTFILES): $(DLFFSOURCE)
	install -m664 $(DLFFDIR)/$(@F) $(DLFFDESTDIR)

