# This Makefile should need no changes from webwml/english/Bugs/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=Bugs
SUBS=

include $(WMLBASE)/Make.lang


$(HTMLFILES): $(TEMPLDIR)/template.wml otherpages.inc footer.inc

pseudo-packages.$(LANGUAGE).html: $(ENGLISHDIR)/Bugs/pseudo-packages.description \
  $(TEMPLDIR)/template.wml otherpages.inc footer.inc
