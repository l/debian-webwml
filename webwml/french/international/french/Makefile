# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/french
SUBS=

include $(WMLBASE)/Make.lang

CTUNAVAILABLE           = unavailable
CTUNTRANSLATED          = untranslated
CTBEINGTRANSLATED       = beingtranslated
CTOUTDATED              = outdated
CTUPTODATE              = uptodate
CTUNCHECKED             = unchecked
CTBEINGREVISED          = beingrevised
CTOBSOLETE              = obsolete
CTUNKNOWN               = unknown

CTDOCFILES := doc-$(CTUNCHECKED).$(LANGUAGE).html doc-$(CTOUTDATED).$(LANGUAGE).html doc-$(CTBEINGREVISED).$(LANGUAGE).html doc-$(CTUNTRANSLATED).$(LANGUAGE).html doc-$(CTUNAVAILABLE).$(LANGUAGE).html doc-$(CTUPTODATE).$(LANGUAGE).html

CTWEBFILES := www-$(CTUNCHECKED).$(LANGUAGE).html www-$(CTOUTDATED).$(LANGUAGE).html www-$(CTBEINGREVISED).$(LANGUAGE).html www-$(CTUNTRANSLATED).$(LANGUAGE).html

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
	-rm -f check_trans.status.new >/dev/null 2>&1

FORCE:
	@:

$(CTDOCFILES): docpages.src documents-bd.pl doccurrent_status.pl
	wml $(WMLOPTIONS) \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_TRANS@+$(LANGUAGECAP)nCT_TRANS):doc-$(CTUNTRANSLATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OUT@+$(LANGUAGECAP)nCT_OUT):doc-$(CTOUTDATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_CHECK@+$(LANGUAGECAP)nCT_CHECK):doc-$(CTUNCHECKED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_WIP@+$(LANGUAGECAP)nCT_WIP):doc-$(CTBEINGREVISED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_FUTURE@+$(LANGUAGECAP)nCT_FUTURE):doc-$(CTUNAVAILABLE).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OK@+$(LANGUAGECAP)nCT_OK):doc-$(CTUPTODATE).$(LANGUAGE).html@g+w" \
  docpages.src

$(CTWEBFILES): webpages.src current_status.pl check_trans.status
	wml $(WMLOPTIONS) \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_TRANS@+$(LANGUAGECAP)nCT_TRANS):www-$(CTUNTRANSLATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OUT@+$(LANGUAGECAP)nCT_OUT):www-$(CTOUTDATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_CHECK@+$(LANGUAGECAP)nCT_CHECK):www-$(CTUNCHECKED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_WIP@+$(LANGUAGECAP)nCT_WIP):www-$(CTBEINGREVISED).$(LANGUAGE).html@g+w" \
  webpages.src

stats.$(LANGUAGE).html: documents-bd.pl doccurrent_status.pl current_status.pl check_trans.status

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

