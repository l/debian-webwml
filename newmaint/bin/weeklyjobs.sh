#!/bin/sh
# It is run every week from tbm's crontab
# 56 23 * * sun /org/nm.debian.org/bin/weeklyjobs.sh

DATE=`date +'AM Report for Week Ending %d %b %Y'`
/org/nm.debian.org/bin/weekrpt.pl --email | mailx -s "$DATE" -a "From: NM Front Desk <new-maintainer@debian.org>" debian-newmaint@lists.debian.org

