# This Makefile should need no changes from webwml/english/security/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.

WMLBASE=..
CUR_DIR=events
SUBS=1998 1999 2000 2001

include $(WMLBASE)/Make.lang


#do not modify the following line(s)
index.$(LANGUAGE).html: index.wml $(wildcard 1998/*.wml) $(wildcard 1999/*.wml) \
     $(ENGLISHSRCDIR)/events/index.include \
     $(wildcard $(ENGLISHSRCDIR)/events/1998/*.wml) \
	 $(wildcard $(ENGLISHSRCDIR)/events/1999/*.wml) \
     $(TEMPLDIR)/template.wml $(TEMPLDIR)/footer.wml $(TEMPLDIR)/languages.wml
