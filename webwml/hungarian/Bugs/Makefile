# This Makefile should need no changes from webwml/english/Bugs/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=Bugs
SUBS=

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: $(TEMPLDIR)/template.wml $(ENGLISHDIR)/Bugs/footer.inc \
  $(ENGLISHDIR)/Bugs/pkgreport-opts.inc
Access.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
Developer.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
Reporting.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
server-control.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
server-refcard.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
server-request.$(LANGUAGE).html: $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
pseudo-packages.$(LANGUAGE).html: $(ENGLISHDIR)/Bugs/pseudo-packages.description \
  $(TEMPLDIR)/template.wml otherpages.inc $(ENGLISHDIR)/Bugs/footer.inc
