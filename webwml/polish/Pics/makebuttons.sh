#!/bin/sh

# This script makes the Debian buttons, it is often a good idea
# to have gimp perl up and running so it is a lot faster.
#
# Uncomment this line to run the server
#
# gimp --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# TRANSLATORS, Edit the stuff in ""s
PLANG="pl"
HOME_TEXT="Strona g³ówna"
ABOUT_TEXT="O Debianie"
NEWS_TEXT="Wiadomo¶ci"
DISTRIB_TEXT="Dystrybucja"
SUPPORT_TEXT="Pomoc"
DEVEL_TEXT="Rozwijanie"
SEARCH_TEXT="Przeszukiwanie"

cwd=`pwd`
# Dont' edit below this line
./debbar.pl -words "${HOME_TEXT}" -o ${cwd}/home.${PLANG}.gif
./debbar.pl -words "${ABOUT_TEXT}" -o ${cwd}/about.${PLANG}.gif
./debbar.pl -words "${NEWS_TEXT}" -o ${cwd}/news.${PLANG}.gif
./debbar.pl -words "${DISTRIB_TEXT}" -o ${cwd}/distrib.${PLANG}.gif
./debbar.pl -words "${SUPPORT_TEXT}" -o ${cwd}/support.${PLANG}.gif
./debbar.pl -words "${DEVEL_TEXT}" -o ${cwd}/devel.${PLANG}.gif
./debbar.pl -words "${SEARCH_TEXT}" -o ${cwd}/search.${PLANG}.gif

