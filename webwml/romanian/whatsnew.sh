#!/bin/sh

#  $Id$
#
#  script to check out the English versions only for the translations
#  reason: the site has grown to 30Mb
#  works in pair with whatsnew.mak
#

translation=romanian

cd ..
cvs update .wmlrc
cvs update Makefile.common

files=`find $translation -name '*' -print | grep -v CVS`

for f in $files
do
  if [ -f $f ]; then
    ef=`echo $f | sed s/$translation/english/`
    echo "$f <=> $ef"
    cvs update -d $f
    cvs update -d $ef
  fi
done

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

