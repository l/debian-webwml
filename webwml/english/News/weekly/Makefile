# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

# See "makefile" file for more information

WMLBASE=../..
CUR_DIR=News/weekly

include $(WMLBASE)/Make.lang

# Have to add to the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f -name \*.$(LANGUAGE).html | xargs rm -f

# Generate the mail for posting to debian-news. Requires the web page already
# be updated.
mail:
	@./makemail.pl
