# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=devel
SUBS=website join misc wnpp todo \
 debian-jr debian-med debian-desktop debian-lex \
 debian-nonprofit debian-installer debian-accessibility buildd \
 debian-volatile

include $(WMLBASE)/Make.lang

people.$(LANGUAGE).html: people.wml $(TEMPLDIR)/template.wml \
 $(ENGLISHSRCDIR)/devel/people.names
index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml
