#!/bin/sh
# It is run every week from tbm's crontab
# 23 56 * * sun /org/qa.debian.org/data/cronjobs/cvs-update

DATE=`date +'AM Report for Week Ending %d %b %Y'`
/org/nm.debian.org/bin/weekrpt.pl --email | mailx -s "$DATE" debian-newmaint@lists.debian.org

