# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../../..
CUR_DIR=international/spanish/contrib
SUBS=apt-guia-usuarios.html paqifaz-capturas presentacion
# disabled, doesn't work on www-master.d.o: making-packages

include $(WMLBASE)/Make.lang


install::
	install -m 664 -p apt-get-mini-COMO.html apt-get-mini-COMO.sgml \
	 apt-guia-usuarios.sgml mitos-debian.html mitos-debian.sgml\
	paqifaz.html paqifaz.sgml paqifaz.txt paquetes.html \
	tabla-historia.txt euro-howto.txt $(HTMLDIR)


cleandest::
	rm -f $(HTMLDIR)/apt-get-mini-COMO.html \
	$(HTMLDIR)/apt-get-mini-COMO.sgml $(HTMLDIR)/apt-guia-usuarios.sgml \
	$(HTMLDIR)/mitos-debian.html $(HTMLDIR)/mitos-debian.sgml  \
	$(HTMLDIR)/paqifaz.html $(HTMLDIR)/paqifaz.sgml $(HTMLDIR)/paqifaz.txt \
	$(HTMLDIR)/paquetes.html 
	$(HTMLDIR)/tabla-historia.txt $(HTMLDIR)/euro-howto.txt

# SGML files:
# build with sgml2html -c latin --split=0 -l es
