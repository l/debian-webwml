# This Makefile should need no changes from webwml/english/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=international/spanish
# list any subdirectories in the following variable. Any directories listed
# must exist or the make will not work
SUBS=

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common

include $(WMLBASE)/Make.dep.generic
include $(WMLBASE)/Make.dep.templ

# Do Not modify the following line

a-releer.es.html a-revisar.es.html a-traducir.es.html \
en-curso.es.html no-disponible.es.html www-a-revisar.es.html \
www-ok.es.html www-nok.es.html www.es.html : ltcp.pl current_status.pl documents-bd.pl
