WMLBASE=../..
CUR_DIR=international/french
SUBS=dico

include $(WMLBASE)/Make.lang

DLFFDIR := debian-l10n-french-faq.html
DLFFSOURCE := $(wildcard $(DLFFDIR)/*.html)
DLFFDESTFILES := $(patsubst %,$(HTMLDIR)/%,$(DLFFSOURCE))
DLFFDESTDIR := $(HTMLDIR)/$(DLFFDIR)

install:: $(DLFFDESTFILES)

$(DLFFDESTFILES): $(DLFFSOURCE)
	@test -d $(DLFFDESTDIR) || mkdir -p -m g+w $(DLFFDESTDIR)
	install -m664 $(DLFFDIR)/$(@F) $(DLFFDESTDIR)

