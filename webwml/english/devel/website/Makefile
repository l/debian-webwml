# This Makefile should need no changes from webwml/english/devel/website/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/website
SUBS=

include $(WMLBASE)/Make.lang

ifeq "$(LANGUAGE)" "en"
translation_coordinators.$(LANGUAGE).html : translation_coordinators.wml \
  $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(ENGLISHDIR)/$(CUR_DIR)/tc.data
else
translation_coordinators.$(LANGUAGE).html : translation_coordinators.wml \
  $(WMLBASE)/../.wmlrc $(WMLBASE)/.wmlrc \
  $(TEMPLDIR)/template.wml $(TEMPLDIR)/languages.wml \
  $(ENGLISHDIR)/$(CUR_DIR)/tc.data $(LOCALEDIR)/others.mo
endif

ifeq "$(LANGUAGE)" "en"
todo.en.html: todo.wml
	$(WML) -p 1,2,5,7,8,9 -W1,-N $< 
endif
