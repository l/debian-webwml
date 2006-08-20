#!/bin/sh

# A simple script which checks that the included DSA data file matches the
# current DSA. dsa-1000.wml should contain:
#include "$(ENGLISHDIR)/security/2006/dsa-1000.data"
#
# It outputs all wrong files. There is no output if all files are OK.
#
# Jens Seidel (jensseidel@users.sf.net), (c) 2006, GPL

if ! test -e english/security; then
  echo Please start $0 from the top level directory containing
  echo english/security
  echo
  exit 1
fi

for dir in $(find -name "security" -type d); do
  cd $dir
  for dsa in $(find -name "dsa-[0-9]*.wml" -o -name "[0-9]*.wml"); do
    file=$(echo $dsa | sed 's,^.,$(ENGLISHDIR)/security,;s,.wml$,.data,')
    grep --color=no "#include ['\"]$file['\"]" $dsa > /dev/null || \
    (echo -n "$dir/$dsa: "; grep "#include" $dsa)
   done
   cd - > /dev/null
done

