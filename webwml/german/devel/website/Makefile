# This Makefile should need no changes from webwml/english/devel/website/Makefile
# Please send a message to debian-www if you need to modify anything
# so the problem can be fixed.

WMLBASE=../..
CUR_DIR=devel/website
SUBS=

include $(WMLBASE)/Make.lang

translation_coordinators.$(LANGUAGE).html: translation_coordinators.wml \
  $(ENGLISHDIR)/$(CUR_DIR)/tc.data

ifeq "$(LANGUAGE)" "en"
todo.en.html: todo.wml
	$(WML) -p 1,2,5,7,8,9 -W1,-N $< 
endif
