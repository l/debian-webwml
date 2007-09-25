#!/bin/sh

#  $Id$
#
#  script to check out the English versions only for the translations
#  reason: the site has grown to 30Mb
#
#  Usage: cd romanian && ./whatsnew.sh 
#

translation=romanian
efiles=""
tfiles=""

cd ..
cvs update .wmlrc
cvs update Makefile.common
cvs update check_trans.pl
cvs update -d Perl
cvs update -d english/template
cvs update -d italian/po

cvs update -d $translation
  rm -rf $translation/CD
files=`find $translation -name '*' -print | grep -v CVS`

for f in $files
do
  if [ -f $f ]; then
    case $f in
	*html)
	    echo "   Skipping $f..."
	    continue
		;;
	esac
	
    ef=`echo $f | sed s/$translation/english/`
    echo "$f <=> $ef"
    efiles=$efiles" "$ef
    tfiles=$tfiles" "$f
    #cvs update -d $f
    cvs update -d $ef
  fi
done
#echo $tfiles
#echo $efiles
#cvs update $tfiles
#cvs update $efiles


# check which one is newer
echo 
echo "====== Outdated files: "
for f in $files
do
  if [ -f $f ]; then
    ef=`echo $f | sed s/$translation/english/`
	if [ $ef -nt $f ]; then
	    echo "    $f"
	fi
  fi
done

cd $translation
echo "====== Done "

cd .. && ./check_trans.pl -q $translation

