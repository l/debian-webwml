# This Makefile should need no changes from webwml/english/News/weekly/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

# Get the current year.
YEAR=$(shell date +%Y)

WMLBASE=../..
CUR_DIR=News/weekly

include $(WMLBASE)/Make.lang
include $(WMLBASE)/Make.common
include $(WMLBASE)/Make.dep.templ
# Notice I do not include Make.dep.generic, since I have my own special
# %.html.$(LANGUAGE) rule.

# When building the html files we have to take into account which directory
# they are in.
WMLOUTFILE=$(@D)/$(@F)
%.html.$(LANGUAGE) : %.wml
	$(WML) $(<)

# This Makefile will handle converting all .wml files in this directory
# and all subdirectories to .html files. It did it this way so I don't need
# a new Makefile for each new issue.
ALLHTML=$(shell find . -type f -name \*.wml | sed 's/.wml/.html.$(LANGUAGE)/')
all:: index.html.$(LANGUAGE) $(ALLHTML)

# Have to override the default clean rule to clean up all the html the
# above target produces.
clean::
	-find . -type f -name \*.html.$(LANGUAGE) | xargs rm -f

# Need to rebuild the index when anything changes.
index.html.$(LANGUAGE): $(wildcard $(YEAR)/*) \
      $(wildcard $(ENGLISHSRCDIR)/News/weekly/$(YEAR)/*) \
      $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml
