# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/french
SUBS=

include $(WMLBASE)/Make.lang


# Do Not modify the following line

$(HTMLFILES): documents-bd.pl current_status.pl

# ask to install the debian-l10-french-faq files
install:: $(patsubst %,$(HTMLDIR)/%,$(wildcard debian-l10-french-faq.html))
	  
