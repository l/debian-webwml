#!/bin/sh

# This script makes the Debian buttons, it is often a good idea
# to have gimp perl up and running so it is a lot faster.
#
# Uncomment this line to run the server
#
# gimp --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# TRANSLATORS, Edit the stuff in ""s
HOME_TEXT="Home"
ABOUT_TEXT="About Debian"
NEWS_TEXT="News"
DISTRIB_TEXT="Distribution"
SUPPORT_TEXT="Support"
DEVEL_TEXT="Development"
SEARCH_TEXT="Search"

cwd=`pwd`
# Dont' edit below this line
./debbar.pl -words "${HOME_TEXT}" -o ${cwd}/home.gif
./debbar.pl -words "${ABOUT_TEXT}" -o ${cwd}/about.gif
./debbar.pl -words "${NEWS_TEXT}" -o ${cwd}/news.gif
./debbar.pl -words "${DISTRIB_TEXT}" -o ${cwd}/distrib.gif
./debbar.pl -words "${SUPPORT_TEXT}" -o ${cwd}/support.gif
./debbar.pl -words "${DEVEL_TEXT}" -o ${cwd}/devel.gif
./debbar.pl -words "${SEARCH_TEXT}" -o ${cwd}/search.gif

