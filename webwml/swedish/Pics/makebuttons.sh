#!/bin/sh

# This script makes the Debian buttons, it is often a good idea
# to have gimp perl up and running so it is a lot faster.
#
# Uncomment this line to run the server
#
# gimp --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# TRANSLATORS, Edit the stuff in ""s
LANG="sv"
HOME_TEXT="Hem"
ABOUT_TEXT="Om Debian"
NEWS_TEXT="Nyheter"
DISTRIB_TEXT="Distribution"
SUPPORT_TEXT="Support"
DEVEL_TEXT="Utvecklarhörnet"
SEARCH_TEXT="Sök"

cwd=`pwd`
# Dont' edit below this line
./debbar.pl -words "${HOME_TEXT}" -o ${cwd}/home.${LANG}.gif
./debbar.pl -words "${ABOUT_TEXT}" -o ${cwd}/about.${LANG}.gif
./debbar.pl -words "${NEWS_TEXT}" -o ${cwd}/news.${LANG}.gif
./debbar.pl -words "${DISTRIB_TEXT}" -o ${cwd}/distrib.${LANG}.gif
./debbar.pl -words "${SUPPORT_TEXT}" -o ${cwd}/support.${LANG}.gif
./debbar.pl -words "${DEVEL_TEXT}" -o ${cwd}/devel.${LANG}.gif
./debbar.pl -words "${SEARCH_TEXT}" -o ${cwd}/search.${LANG}.gif

