#
# $Id$
#
# make to find which files in translation are outdated
# works in pair with whatsnew.sh
# you have to set environment variables:
#  OFILE: full path of the Englich file
#  TFILE: full path of the translation
#

all: $(TFILE)

$(TFILE): $(OFILE)
	@echo "Outdated: $(TFILE)"

