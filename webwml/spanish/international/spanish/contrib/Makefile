# Top-level makefile for the Debian Documentation Project manuals

# live documentation
SUBDIRS	:= apt-get-mini-COMO apt-guia-usuarios making-packages \
           mitos-debian

SUBDIRS-publish := $(addsuffix -publish,$(SUBDIRS))
SUBDIRS-clean := $(addsuffix -clean,$(SUBDIRS))

# where we should publish to
PUBLISHDIR := /org/www.debian.org/www/doc/manuals/es
THISSUBDIR :=	$(shell basename $(shell pwd))
# How to install stuff in publish directory
install_file := install -p -m 664
install_dir := install -d -m 2775
# arguments to make publish
publish_args := PUBLISHDIR=$(PUBLISHDIR)/$(THISSUBDIR) install_file="$(install_file)" install_dir="$(install_dir)"

.SUFFIXES: 
.PHONY: all publish clean $(SUBDIRS) $(SUBDIRS-publish) $(SUBDIRS-clean)

all: $(SUBDIRS)

publish::
	[ -d $(PUBLISHDIR)/$(THISSUBDIR) ] || mkdir -p $(PUBLISHDIR)/$(THISSUBDIR)
publish:: $(SUBDIRS-publish)

clean: $(SUBDIRS-clean)

$(SUBDIRS):
	$(MAKE) -C $@

$(SUBDIRS-publish):
	$(MAKE) -C $(subst -publish,,$@) publish $(publish_args)

$(SUBDIRS-clean):
	$(MAKE) -C $(subst -clean,,$@) clean
