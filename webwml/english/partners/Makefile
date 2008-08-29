# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=partners
SUBS=images

include $(WMLBASE)/Make.lang


index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/partners/index.include \
                        $(ENGLISHSRCDIR)/partners/images/*

# there is no reason to translate the file partners-form.txt 
# so don't modify the following
ifeq "$(LANGUAGE)" "en"
$(HTMLDIR)/partners-form.txt: partners-form.txt
	install -m 664 -p $< $(HTMLDIR)

install:: $(HTMLDIR)/partners-form.txt
endif
