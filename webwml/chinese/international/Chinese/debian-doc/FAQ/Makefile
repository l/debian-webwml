TEX =	latex

SRCS = $(wildcard *.sgml) debian-faq.sgml

all:	html txt ps dvi


install: install-ftp install-www

release::
	LC_ALL=en && date +'%-d %B %Y' >RELEASE
	make all

clean::	
	rm -f debian-faq.{txt,ps,dvi,info*,aux,log,man,tex,toc,sgml}
	rm -f *~ .*~ core debian-faq*html tsa*

debian-faq.sgml:	debian-faq.in.sgml RELEASE
	sed -e "s/@@DATE@@/$(shell cat RELEASE)/g" <debian-faq.in.sgml >$@

txt::	debian-faq.txt

html::	debian-faq.html

ps::	debian-faq.ps

info::	debian-faq.info

dvi::	debian-faq.dvi

debian-faq.dvi:		debian-faq.sgml
	sgml2latex -o dvi debian-faq.sgml

debian-faq.man: 	$(SRCS)
	sgml2txt -man debian-faq.sgml

debian-faq.info:	$(SRCS)
#	sdc -Rlinuxdoc -O info -o debian-faq.info debian-faq.sgml
	sgml2info debian-faq.sgml

debian-faq.txt:		$(SRCS)
#	sdc -Rlinuxdoc -Rno-margin -O ascii -o debian-faq.tmp debian-faq.sgml
#	cat debian-faq.tmp | sed 's/--  / -  /g' >debian-faq.txt
#	rm -f debian-faq.tmp
	sgml2txt debian-faq.sgml

debian-faq.html:	$(SRCS)
	sgml2html debian-faq.sgml

debian-faq.ps:	$(SRCS)
	sgml2latex -o ps debian-faq.sgml

install-www:
	ssh master.debian.org \
		'cd /home/Archives/DebianWebMaster/debian.org/FAQ  && \
		 co -l debian-faq*.html'
	scp debian-faq*.html \
		master.debian.org:/home/Archives/DebianWebMaster/debian.org/FAQ
	ssh master.debian.org \
		'cd /home/Archives/DebianWebMaster/debian.org/FAQ  &&  \
		 ci -u -m. debian-faq*.html'

install-ftp:
	scp tweaked/debian-faq.txt debian-faq.info debian-faq*.html \
		debian-faq.ps \
		master.debian.org:../ftp/debian/doc/FAQ/
