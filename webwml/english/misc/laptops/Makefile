# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../..
CUR_DIR=misc/laptops
SUBS=

GETTEXTFILES += ports.mo

include $(WMLBASE)/Make.lang

$(HTMLFILES): $(ENGLISHSRCDIR)/misc/laptops/menu.inc \
  $(TEMPLDIR)/submenu.wml $(TEMPLDIR)/template.wml $(GETTEXTDEP)
