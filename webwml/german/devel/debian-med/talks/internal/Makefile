include $(subst webwml/german,webwml/english,$(CURDIR))/Makefile

install::
ifeq ($(LANGUAGE),de)
        @echo install MGP
        -@install -m 664 -p *.mgp $(HTMLDIR)
endif

