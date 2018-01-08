# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=partners/2018
SUBS=images
GETTEXTFILES += partners.mo

include $(WMLBASE)/Make.lang

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/template.wml \
                        $(ENGLISHSRCDIR)/partners/2018/partners.data \
                        $(ENGLISHSRCDIR)/partners/partners.def \
                        $(ENGLISHSRCDIR)/partners/2018/images/*.png \
                        $(ENGLISHSRCDIR)/partners/2018/images/*.jpg \
                        $(GETTEXTDEP)

