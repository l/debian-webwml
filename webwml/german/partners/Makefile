# This Makefile should need no changes from webwml/english/partners/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=partners
SUBS=images

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/partners/index.include

# there is no reason to translate the file partners-form.txt 
# so don't modify the following
ifeq ($(LANGUAGE),en)
$(HTMLDIR)/partners-form.txt: partners-form.txt
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/partners-form.txt
endif
