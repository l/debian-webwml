#!/bin/sh

#  $Id$
#
#  script to check out the English versions only for the translations
#  reason: the site has grown to 30Mb
#  works in pair with whatsnew.mak
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
    ef=`echo $f | sed s/$translation/english/`
    echo "$f <=> $ef"
    efiles=$efiles" "$ef
    tfiles=$tfiles" "$f
    #cvs update -d $f
    #cvs update -d $ef
  fi
done
#echo $tfiles
#echo $efiles
#cvs update $tfiles
cvs update $efiles

# check which one is newer
# do not know how to stat files in shell
echo
for f in $files
do
  if [ -f $f ]; then
    ef=`echo $f | sed s/$translation/english/`
    TFILE=$f
    export TFILE
    OFILE=$ef
    export OFILE
    make -f $translation/whatsnew.mak &> '.###' 
    cat '.###' | grep Outdated
  fi
done
rm '.###'

cd $translation
echo "====== Done ======"

