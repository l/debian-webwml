# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/french
SUBS=dico

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
	:> $@.new
	echo '#  File automatically generated with the following command:' >> $@.new
	echo '#    ../../../check_trans.pl -C ../../.. -t perl french > $@' >> $@.new
	echo '#  DO NOT EDIT!' >> $@.new
	../../../check_trans.pl -C ../../.. -t perl french >> $@.new
	if [ -f $@ ]; then \
		cmp $@ $@.new >/dev/null 2>&1 \
		|| mv $@.new $@; \
	else \
		mv $@.new $@; \
	fi
	-rm -f $@.new >/dev/null 2>&1

FORCE:
	@:

$(CTDOCFILES): docpages.src documents-bd.pl doccurrent_status.pl ltcp.pl
	wml $(WMLOPTIONS) \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_TRANS@+$(LANGUAGECAP)nCT_TRANS):doc-$(CTUNTRANSLATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OUT@+$(LANGUAGECAP)nCT_OUT):doc-$(CTOUTDATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_CHECK@+$(LANGUAGECAP)nCT_CHECK):doc-$(CTUNCHECKED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_WIP@+$(LANGUAGECAP)nCT_WIP):doc-$(CTBEINGREVISED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_FUTURE@+$(LANGUAGECAP)nCT_FUTURE):doc-$(CTUNAVAILABLE).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OK@+$(LANGUAGECAP)nCT_OK):doc-$(CTUPTODATE).$(LANGUAGE).html@g+w" \
  docpages.src

$(CTWEBFILES): webpages.src current_status.pl check_trans.status ltcp.pl
	wml $(WMLOPTIONS) \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_TRANS@+$(LANGUAGECAP)nCT_TRANS):www-$(CTUNTRANSLATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OUT@+$(LANGUAGECAP)nCT_OUT):www-$(CTOUTDATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_CHECK@+$(LANGUAGECAP)nCT_CHECK):www-$(CTUNCHECKED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_WIP@+$(LANGUAGECAP)nCT_WIP):www-$(CTBEINGREVISED).$(LANGUAGE).html@g+w" \
  webpages.src

stats.$(LANGUAGE).html: documents-bd.pl doccurrent_status.pl current_status.pl check_trans.status ltcp.pl

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

