#!/bin/sh

# This script makes the Debian buttons, it is often a good idea
# to have gimp perl up and running so it is a lot faster.
#
# Uncomment this line to run the server
# You now MUST have a perl server running, so either uncomment this line
# or run gimp and select menu item Xtns->Perl->Server
# You have been (belatedly) warned!!
#
gimp --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# If you want to go into totally evil mode with no X display, try
# this on for size. I hope it works :/
# Xvfb :1 -screen 0 10x10x8 -pixdepths 1 &
# gimp --display :1.0 --no-interface --no-data --batch '(extension-perl-server 0 0 0)' &
#
# TRANSLATORS, Edit the stuff in ""s
LANG="pt"
HOME_TEXT="Principal"
ABOUT_TEXT="Sobre o Debian"
NEWS_TEXT="Novidades"
DISTRIB_TEXT="Distribuição"
SUPPORT_TEXT="Suporte"
DEVEL_TEXT="Desenvolvimento"
SEARCH_TEXT="Busca"

cwd=`pwd`
# Dont' edit below this line
./debbar.pl -words "${HOME_TEXT}" -o ${cwd}/home.${LANG}.gif
./debbar.pl -words "${ABOUT_TEXT}" -o ${cwd}/about.${LANG}.gif
./debbar.pl -words "${NEWS_TEXT}" -o ${cwd}/news.${LANG}.gif
./debbar.pl -words "${DISTRIB_TEXT}" -o ${cwd}/distrib.${LANG}.gif
./debbar.pl -words "${SUPPORT_TEXT}" -o ${cwd}/support.${LANG}.gif
./debbar.pl -words "${DEVEL_TEXT}" -o ${cwd}/devel.${LANG}.gif
./debbar.pl -words "${SEARCH_TEXT}" -o ${cwd}/search.${LANG}.gif

