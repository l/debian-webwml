# This Makefile should need no changes from webwml/english/logos/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
THISDIR=ipv6

HTMLFILES= deadsite.html 
PHPFILES=index.php main.php ammain.php amnew.php amnew2.php amprofile.php exit.php amstatus.php amupdate.php todo.php amlist.php fddelete.php leaderboard.php amlogin2.php login2.php nmlist.php whoisam.php newnm.php newnm2.php nmelist.php deletenm.php nmstatus.php stats.php nmadvocate.php maintainers.php gpg.php gpgmain.php gpglogin2.php gpglogin.php gpgpasswd.php gpgregister.php gpgplace.php gpguserdel.php
INCFILES=config.inc common.inc gpgcommon.inc gpgconfig.inc
WMLFILES=$(wildcard *.wml)
IMAGES=$(wildcard *.gif) $(wildcard *.jpg)
ifneq "$(wildcard ${HOME}/web-source/webwml/english/template)" ""
DEBTEMPLATEDIR := ${HOME}/web-source/webwml/english/template
else
DEBTEMPLATEDIR := ../webwml/english/template
endif
DEBTEMPLATES=$(wildcard $(DEBTEMPLATEDIR)/debian/*.wml) $(DEBTEMPLATEDIR)/debian/countries.def $(DEBTEMPLATEDIR)/debian/language_names.def $(wildcard template/*.wml)
#WML_DEFS= -DINTRO="http://www.debian.org/intro" -DDISTRIB="http://www.debian.org/distrib" -DHOME="http://www.debian.org" -DPICS="http://www.debian.org/Pics" -DCUR_ISO_LANG="en" -I $(DEBTEMPLATEDIR) -I template -DSEARCH="http://search.debian.org/"
TARGETDIR=../../web

WML_DEFS= -I $(DEBTEMPLATEDIR)

all: $(HTMLFILES) $(PHPFILES)

%.html: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

%.php: %.wml $(DEBTEMPLATES)
	wml $(WML_DEFS) $< -o UNDEFuEN:$@

rsync: $(HTMLFILES) $(PHPFILES) 
	rsync -e ssh $(HTMLFILES) $(PHPFILES) $(IMAGES) $(INCFILES) pandora.debian.org:/org/nm.debian.org/web

backup:
	rsync -e ssh -r template $(WMLFILES) $(INCFILES) Makefile pandora.debian.org:/org/nm.debian.org/wml

install: $(HTMLFILES) $(PHPFILES) 
	cp $(HTMLFILES) $(PHPFILES) $(IMAGES) $(INCFILES) $(TARGETDIR)

clean:
	rm -f $(PHPFILES) $(HTMLFILES)

$(DEBTEMPLATEDIR)/debian/countries.def: $(DEBTEMPLATEDIR)/debian/countries.wml
	cd $(DEBTEMPLATEDIR)/debian && sed -e /^#/d countries.wml | eperl -B '<:' -E ':>' - >/dev/null

$(DEBTEMPLATEDIR)/debian/language_names.def: $(DEBTEMPLATEDIR)/debian/language_names.wml
	cd $(DEBTEMPLATEDIR)/debian && sed -e '/^#/d' -e '/^<perl>/,/^<\/perl>/!d' language_names.wml  | eperl -B '<perl>' -E '</perl>' - >/dev/null

