# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/portuguese
SUBS=

include $(WMLBASE)/Make.lang

CTUNTRANSLATED          = untranslated
CTOUTDATED              = outdated

CTWEBFILES := www-$(CTUNTRANSLATED).$(LANGUAGE).html www-$(CTOUTDATED).$(LANGUAGE).html

GENFILES = $(CTWEBFILES)
GENDESTFILES = $(patsubst %.$(LANGUAGE).html,$(HTMLDIR)/%.$(LANGUAGE).html,$(GENFILES))

all:: $(CTWEBFILES)

current_status.pl: FORCE
	:> $@.new
	echo '#  File automatically generated with the following command:' >> $@.new
	echo '#    ../../../check_trans.pl -C ../../.. -t perl portuguese > $@' >> $@.new
	echo '#  DO NOT EDIT!' >> $@.new
	../../../check_trans.pl -C ../../.. -t perl portuguese >> $@.new
	if [ -f $@ ]; then \
		cmp $@ $@.new >/dev/null 2>&1 \
		|| mv $@.new $@; \
	else \
		mv $@.new $@; \
	fi
	-rm -f $@.new >/dev/null 2>&1

FORCE:
	@:

$(CTWEBFILES): webpages.src current_status.pl
	wml $(WMLOPTIONS) \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_TRANS@+$(LANGUAGECAP)nCT_TRANS):www-$(CTUNTRANSLATED).$(LANGUAGE).html@g+w" \
  -o "(UNDEF+($(LANGUAGECAP)-CT_*))+(CT_OUT@+$(LANGUAGECAP)nCT_OUT):www-$(CTOUTDATED).$(LANGUAGE).html@g+w" \
  webpages.src

stats.$(LANGUAGE).html: current_status.pl


