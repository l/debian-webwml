# This Makefile should need no changes from webwml/english/devel/wnpp/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/wnpp
SUBS=

include $(WMLBASE)/Make.lang

WNPP_FILES=being_adopted.html being_packaged.html orphaned.html \
	prospective.html requested.html rfa_bymaint.html \
	rfa_bypackage.html withdrawn.html work_needing.html

# There is no wnpp.en.html destination. This will be run every time,
# which is what we want
ifeq ($(LANGUAGE),en)
wnpp.en.html: wnpp.wml
	wml -q wnpp.wml

install::
	install $(WNPP_FILES) $(HTMLDIR)
endif

