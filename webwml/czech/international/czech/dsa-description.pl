#!/usr/bin/perl -w -p     -*- mode: perl ; coding: iso-8859-2-unix -*-

# Translate dsa-*.wml file from English to Czech language.
# USAGE: dsa-description.pl file.wml

# Read by paragraph
$/="\n\n";

# Delete \n except comment line and last \n in paragraph
s/\n([^\#])/ $1/g;
s/ $/\n/g;

#
# Descriptions
#

s{<define-tag description>([^<]*)several vulnerabilities([^<]*)</define-tag>}
{<define-tag description>${1}nìkolik zranitelností${2}</define-tag>}g;

s{<define-tag description>([^<]*)integer overflows([^<]*)</define-tag>}
{<define-tag description>${1}celoèíselná pøeteèení${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neo¹etøený vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)buffer overflows([^<]*)</define-tag>}
{<define-tag description>${1}pøeteèení bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary file([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivý doèasný soubor${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neo¹etøený vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)infinite loop([^<]*)</define-tag>}
{<define-tag description>${1}nekoneèná smyèka${2}</define-tag>}g;

s{<define-tag description>([^<]*)format string([^<]*)</define-tag>}
{<define-tag description>${1}formátování øetìzce${2}</define-tag>}g;

s{<define-tag description>([^<]*)insufficient input validation([^<]*)</define-tag>}
{<define-tag description>${1}nedostateèná kontrola vstupu${2}</define-tag>}g;

#
# More info
#

# exploit
# vyu¾ít

s{Several vulnerabilities have been discovered in}
{Bylo objeveno nìkolik zranitelností v}g;

s{A vulnerability has been discovered in}
{Objevena zranitelnost v}g;

s{discoverd multiple vulnerabilities in}
{objevil mnohonásobné zranitelnosti v}g;

#
# More info about programs
#

s{a picture viewer for X11 with a thumbnail-based selector}
{programu pro prohlí¾ení obrázkù pro X11 s výbìrem z miniatur}g;

#
# remote exploitation
#

s{Remote exploitation of an integer overflow vulnerability could allow the execution of arbitrary code.}
{Vzdálené vyu¾ití zranitelnosti celoèíselného pøeteèení dovoluje vykonání libovolného kódu.}g;

#
# Fixed in packages
#

s{<p>For the (stable|unstable) distribution}
{<p>Pro $1 distribuci}g;

s{this problem has been fixed in version}
{byl tento problém opraven ve verzi}g;

s{these problems have been fixed in version}
{byly tyto problémy opraveny ve verzi}g;

s{these problems will be fixed soon.</p>}
{budou tyto problémy brzy odstranìny.</p>}g;

s{<p>This package is not present in the testing and unstable distributions.</p>}
{<p>Tento balíèek není obsa¾en v testing a unstable distribuci.</p>}g;

#
# Upgrade it
#

s{<p>We recommend that you upgrade your (\w+) package immediately.</p>}
{<p>Doporuèujeme vám ihned aktualizovat vá¹ balíèek ${1}.</p>}g;

s{<p>We recommend that you upgrade your (\w+) package.</p>}
{<p>Doporuèujeme vám aktualizovat vá¹ balíèek ${1}.</p>}g;

#
# Cleaning
#

s{ </define-tag>}{\n</define-tag>}g;
s{<define-tag moreinfo> }{<define-tag moreinfo>\n}g;

#print "---\n";
