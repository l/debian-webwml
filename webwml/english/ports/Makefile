# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=..
CUR_DIR=ports
SUBS=alpha arm beowulf freebsd kfreebsd-gnu hppa hurd i386 ia64 m68k mips netbsd powerpc sparc sparc64 s390 amd64
# java parisc ultrasparc

GETTEXTFILES = ports.mo

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
install::
	test -L $(HTMLDIR)/mipsel || ln -sf mips $(HTMLDIR)/mipsel
	test -L $(HTMLDIR)/armel || ln -sf arm $(HTMLDIR)/armel
	test -L $(HTMLDIR)/kfreebsd-amd64 || ln -sf kfreebsd-gnu $(HTMLDIR)/kfreebsd-i386
	test -L $(HTMLDIR)/kfreebsd-i386 || ln -sf kfreebsd-gnu $(HTMLDIR)/kfreebsd-amd64
endif

index.$(LANGUAGE).html:: $(TEMPLDIR)/release_info.wml
