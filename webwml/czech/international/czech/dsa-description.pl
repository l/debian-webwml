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
{<define-tag description>${1}n�kolik zranitelnost�${2}</define-tag>}g;

s{<define-tag description>([^<]*)integer overflows([^<]*)</define-tag>}
{<define-tag description>${1}celo��seln� p�ete�en�${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neo�et�en� vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)buffer overflows([^<]*)</define-tag>}
{<define-tag description>${1}p�ete�en� bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary file([^<]*)</define-tag>}
{<define-tag description>${1}nespolehliv� do�asn� soubor${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neo�et�en� vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)infinite loop([^<]*)</define-tag>}
{<define-tag description>${1}nekone�n� smy�ka${2}</define-tag>}g;

s{<define-tag description>([^<]*)format string([^<]*)</define-tag>}
{<define-tag description>${1}form�tov�n� �et�zce${2}</define-tag>}g;

s{<define-tag description>([^<]*)insufficient input validation([^<]*)</define-tag>}
{<define-tag description>${1}nedostate�n� kontrola vstupu${2}</define-tag>}g;

#
# More info
#

# exploit
# vyu��t

s{Several vulnerabilities have been discovered in}
{Bylo objeveno n�kolik zranitelnost� v}g;

s{A vulnerability has been discovered in}
{Objevena zranitelnost v}g;

s{discoverd multiple vulnerabilities in}
{objevil mnohon�sobn� zranitelnosti v}g;

#
# More info about programs
#

s{a picture viewer for X11 with a thumbnail-based selector}
{programu pro prohl�en� obr�zk� pro X11 s v�b�rem z miniatur}g;

#
# remote exploitation
#

s{Remote exploitation of an integer overflow vulnerability could allow the execution of arbitrary code.}
{Vzd�len� vyu�it� zranitelnosti celo��seln�ho p�ete�en� dovoluje vykon�n� libovoln�ho k�du.}g;

#
# Fixed in packages
#

s{<p>For the (stable|unstable) distribution}
{<p>Pro $1 distribuci}g;

s{this problem has been fixed in version}
{byl tento probl�m opraven ve verzi}g;

s{these problems have been fixed in version}
{byly tyto probl�my opraveny ve verzi}g;

s{these problems will be fixed soon.</p>}
{budou tyto probl�my brzy odstran�ny.</p>}g;

s{<p>This package is not present in the testing and unstable distributions.</p>}
{<p>Tento bal��ek nen� obsa�en v testing a unstable distribuci.</p>}g;

#
# Upgrade it
#

s{<p>We recommend that you upgrade your (\w+) package immediately.</p>}
{<p>Doporu�ujeme v�m ihned aktualizovat v� bal��ek ${1}.</p>}g;

s{<p>We recommend that you upgrade your (\w+) package.</p>}
{<p>Doporu�ujeme v�m aktualizovat v� bal��ek ${1}.</p>}g;

#
# Cleaning
#

s{ </define-tag>}{\n</define-tag>}g;
s{<define-tag moreinfo> }{<define-tag moreinfo>\n}g;

#print "---\n";
