# This Makefile should need no changes from webwml/english/ports/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=..
CUR_DIR=ports
SUBS=alpha arm beowulf hppa hurd i386 ia64 m68k mips netbsd powerpc sparc sparc64 s390
# java parisc ultrasparc

include $(WMLBASE)/Make.lang


ifeq "$(LANGUAGE)" "en"
install::
	test -L $(HTMLDIR)/mipsel || ln -sf mips $(HTMLDIR)/mipsel
endif
