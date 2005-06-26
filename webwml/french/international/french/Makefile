WMLBASE=../..
CUR_DIR=international/french
SUBS=dico

include $(WMLBASE)/Make.lang

DESCFILES=$(shell find $(ENGLISHSRCDIR)/MailingLists/desc -type f)
JRFREEFILES=$(shell find $(ENGLISHSRCDIR)/devel/debian-jr/packaged -type f)
JRNONFREEFILES=$(shell find $(ENGLISHSRCDIR)/devel/debian-jr/packaged-non-free -type f)

desc.$(LANGUAGE).html: desc.wml translated_txt.db $(DESCFILES)\
                        $(JRFREEFILES) $(JRNONFREEFILES)

DLFFDIR := debian-l10n-french-faq.html
DLFFSOURCE := $(wildcard $(DLFFDIR)/*.html)
DLFFDESTFILES := $(patsubst %,$(HTMLDIR)/%,$(DLFFSOURCE))
DLFFDESTDIR := $(HTMLDIR)/$(DLFFDIR)

install:: $(DLFFDESTFILES)

$(DLFFDESTFILES): $(DLFFSOURCE)
	@test -d $(DLFFDESTDIR) || mkdir -p -m g+w $(DLFFDESTDIR)
	install -m664 $(DLFFDIR)/$(@F) $(DLFFDESTDIR)
