# This Makefile should need no changes from webwml/english/devel/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=vote
SUBS=1999 

include $(WMLBASE)/Make.lang


# Do Not modify the following line
%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/basic.wml $(TEMPLDIR)/votebar.wml $(TEMPLDIR)/languages.wml $(TEMPLDIR)/footer.wml
	$(WML) $(<F)
