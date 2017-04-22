# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=intro
SUBS=

include $(WMLBASE)/Make.lang

about.$(LANGUAGE).html: $(TEMPLDIR)/release_info.wml

organization.$(LANGUAGE).html: organization.wml \
  $(ENGLISHSRCDIR)/intro/organization.data \
  $(ENGLISHDIR)/MailingLists/lists.cfg \
  $(ENGLISHDIR)/devel/leader.data \
  $(TEMPLDIR)/language_names.wml \
  $(TEMPLDIR)/common_tags.wml
