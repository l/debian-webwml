# This Makefile should need no changes from webwml/english/consultants/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

BASE=..
CUR_DIR=consultants

HTMLDIR=$(BASE)/../../debian.org/$(CUR_DIR)
TEMPLDIR=$(BASE)/template/debian
# Do Not Modify
ENGLISHSRCDIR=$(BASE)/../english

# include $(BASE)/Make.lang

# Only the LANGUAGE variable needs to be changed between the different languages.
# If you find this is not the case please report it to debian-www.
LANGUAGE=en

# The '-q' forces wml to be quiet. Very useful in scripts.
# It is sometimes useful to add '--epilog=weblint' to check for errors
# in the html generated.
# Other languages may want to change the wml command to execute programs
# that get run before or after wml. For example,
#    WML="wml -q --prolog="/usr/bin/tcs <options here>" \
#                --epilog="/usr/bin/tcs <options here>"
WML=wml -q

WMLFILES := $(wildcard *.wml)
HTMLFILES := $(patsubst %.wml,$(HTMLDIR)/%.html.$(LANGUAGE),$(WMLFILES))
JPGSOURCE := $(wildcard *.gif)  
JPGDEST := $(patsubst %.gif,$(HTMLDIR)/%.gif,$(JPGSOURCE))

all: $(HTMLFILES) $(JPGDEST)

$(HTMLDIR)/%.html.$(LANGUAGE) : %.wml $(TEMPLDIR)/consultant.wml $(TEMPLDIR)/basic.wml
	$(WML) $(EPILOG) $(<F)
