#!/bin/sh

# A simple script which checks that the included DSA data file matches the
# current DSA. dsa-1000.wml should contain:
#include "$(ENGLISHDIR)/security/2006/dsa-1000.data"
#
# It also checks that the package versions in DSA match across
# all translations.
#
# It outputs all wrong files. There is no output if all files are OK.
# Japanese files are sometime false positives (because of a word search).
#
# Jens Seidel (jensseidel@users.sf.net), (c) 2006, GPL

if ! test -e english/security; then
  echo Please start $0 from the top level directory containing
  echo english/security
  echo
  exit 1
fi

# search for proper inclusion
for dir in $(find -name "security" -type d); do
  cd $dir
  for dsa in $(find -name "dsa-[0-9]*.wml" -o -name "[0-9]*.wml"); do
    file=$(echo $dsa | sed 's,^.,$(ENGLISHDIR)/security,;s,.wml$,.data,')
    grep --color=no "#include ['\"]$file['\"]" $dsa > /dev/null || \
    (echo -n "$dir/$dsa: "; grep "#include" $dsa)
   done
   cd - > /dev/null
done

# search for proper version numbers
rm -f /tmp/dsa
for dsa in $(find english/security -name "dsa-[0-9]*.wml"); do
  # append all lines to one to simplify search
  cat $dsa | awk '{file=file " " $0} END {print file }' | sed 's/  * / /g' > .dsa
  # extract the version string after $phrase
  for phrase in ' been fixed in version ' \
                ' will be fixed in version ' \
		' is fixed in version ' \
		' are fixed in version ' \
		' was fixed in version ' \
		' in version ' \
		' fixed in upstream version '
#		' fixed in the upstream version ' # "of Linux "
  do
    while grep "$phrase" .dsa > /dev/null; do
      # matches the last version string (line limit of sed exceeds)
      #version=$(cat .dsa | sed -n "s/^.*$phrase\([^,< ]*\).*$/\1/p" | sed 's/\.$//')
      version=$(cat .dsa | perl -p -e "s/^.*$phrase([^,< ]*).*$/\1/" | sed 's/\.$//')
      version_regex=$(echo $version | sed 's/\./\\./g')
      # removed the last found match
      #cat .dsa | sed "s/^\(.*\)$phrase\([^,< ]*\)\(.*\)$/\1\3/" > .dsa.tmp; mv .dsa.tmp .dsa
      perl -p -i -e "s/^(.*)$phrase([^,< ]*)(.*)$/\1\3/" .dsa
      for dsa_tr in */$(echo $dsa | sed 's,^english/,,'); do
        if ! grep -w "$version_regex" $dsa_tr > /dev/null; then
          echo "Error: version $version does not occur in $dsa_tr"
        fi
      done
    done
  done
  # record ignored version strings (to be analyzed later)
  cat .dsa >> /tmp/dsa
done

