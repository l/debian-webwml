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
%.$(LANGUAGE).html: %.wml $(WMLBASE)/../spanish/ltcp.pl $(WMLBASE)/../spanish/current_status.pl $(WMLBASE)/../spanish/documents-bd.pl
# As a matter of fact the www pages should depend on all the www tree..
# ¿How to make this run always?
