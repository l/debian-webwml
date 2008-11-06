<<<<<<< Makefile
# This Makefile should need no changes from webwml/english/events/2002/Makefile
# Please send a message to debian-www if you need to modify anything, so the
# problem can be fixed.
=======
# If this makefile is not generic enough to support a translation,
# please contact debian-www.
>>>>>>> 1.5

WMLBASE=../..
CUR_DIR=events/2002
SUBS=
MLOCAL = $(wildcard Makefile.reports)

GETTEXTFILES += newsevents.mo

NOGENERICDEP := true
include $(WMLBASE)/Make.lang

<<<<<<< Makefile

all:: Makefile.reports

# Do Not modify the following lines
=======
>>>>>>> 1.5
index.$(LANGUAGE).html: index.wml $(wildcard [0-9]*\-*.wml) $(TEMPLDIR)/template.wml $(TEMPLDIR)/recent_list.wml

%.$(LANGUAGE).html: %.wml $(TEMPLDIR)/event.wml
	$(WML) $(<F)

Makefile.reports: *-report.wml $(ENGLISHSRCDIR)/$(CUR_DIR)/*-report.wml
	$(ENGLISHSRCDIR)/events/make_makefile_reports.pl $(LANG) $(ENGLISHSRCDIR)/$(CUR_DIR)

ifneq "$(MLOCAL)" ""
include Makefile.reports
endif
