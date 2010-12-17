# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=CD
SUBS=artwork faq http-ftp jigdo-cd torrent-cd mirroring netinst releases vendors

GETTEXTFILES += cdimage.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

%.$(LANGUAGE).html: %.wml $(WMLRCDEP) $(GETTEXTDEP) $(TEMPLDIR)/cdimage.wml
	$(WML) $(<F)

ifneq "$(wildcard releases/index.wml)" ""
RELEASESDEP := releases/index.wml
else
RELEASESDEP := $(ENGLISHDIR)/CD/releases/index.wml
endif

index.$(LANGUAGE).html: index.wml $(TEMPLDIR)/cdimage.wml $(TEMPLDIR)/release_info.wml $(RELEASESDEP) $(GETTEXTDEP)
	$(WML) $(<F) -I $(ENGLISHDIR)/CD/

misc.$(LANGUAGE).html: misc.wml $(TEMPLDIR)/cdimage.wml $(GETTEXTDEP)
	$(WML) $(<F)
