#!/bin/sh

# This script makes the Debian buttons, it is often a good idea
# to have gimp perl up and running so it is a lot faster.
#
# Uncomment this line to run the server
#
# gimp --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# TRANSLATORS, Edit the stuff in ""s
LANG1="ru"
HOME_TEXT="�����"
ABOUT_TEXT="� Debian"
NEWS_TEXT="�������"
DISTRIB_TEXT="�����������"
SUPPORT_TEXT="���������"
DEVEL_TEXT="����������"
SEARCH_TEXT="�����"

cwd=`pwd`
# Dont' edit below this line
./debbar.pl -words "${HOME_TEXT}" -o ${cwd}/home.${LANG1}.gif
./debbar.pl -words "${ABOUT_TEXT}" -o ${cwd}/about.${LANG1}.gif
./debbar.pl -words "${NEWS_TEXT}" -o ${cwd}/news.${LANG1}.gif
./debbar.pl -words "${DISTRIB_TEXT}" -o ${cwd}/distrib.${LANG1}.gif
./debbar.pl -words "${SUPPORT_TEXT}" -o ${cwd}/support.${LANG1}.gif
./debbar.pl -words "${DEVEL_TEXT}" -o ${cwd}/devel.${LANG1}.gif
./debbar.pl -words "${SEARCH_TEXT}" -o ${cwd}/search.${LANG1}.gif

