WMLBASE=../..
CUR_DIR=international/french
SUBS=

include $(WMLBASE)/Make.lang

DESCFILES=$(shell find $(ENGLISHSRCDIR)/MailingLists/desc -type f)
JRFREEFILES=$(shell find $(ENGLISHSRCDIR)/devel/debian-jr/packaged -type f)
JRNONFREEFILES=$(shell find $(ENGLISHSRCDIR)/devel/debian-jr/packaged-non-free -type f)

desc.$(LANGUAGE).html: desc.wml translated_txt.db $(DESCFILES)\
                        $(JRFREEFILES) $(JRNONFREEFILES)

