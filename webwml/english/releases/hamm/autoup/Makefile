# If this makefile is not generic enough to support a translation,
# please contact debian-www.

WMLBASE=../../..
CUR_DIR=releases/hamm/autoup/

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"

autoupfiles := $(wildcard libc5-libc6-Mini-HOWTO*) $(wildcard autoup*)

destautoupfiles := $(patsubst %,$(HTMLDIR)/%,$(autoupfiles))

install:: $(destautoupfiles)

$(destautoupfiles): $(HTMLDIR)/%: %
	@mkdir -p $(HTMLDIR) \ 
	install -m 664 -p $< $(HTMLDIR)


cleandest::
	rm -f $(destautoupfiles)

endif

