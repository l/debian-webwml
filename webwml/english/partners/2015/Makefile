# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=partners/2015
SUBS=images

GETTEXTFILES += partners.mo


include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/partners/partners.def \
			$(ENGLISHSRCDIR)/partners/2015/partners.data \
                        $(ENGLISHSRCDIR)/partners/2015/images/*.gif \
                        $(ENGLISHSRCDIR)/partners/2015/images/*.png \
                        $(ENGLISHSRCDIR)/partners/2015/images/*.jpg \
			$(GETTEXTDEP)


