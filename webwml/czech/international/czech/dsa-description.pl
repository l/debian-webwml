#!/usr/bin/perl -w     -*- mode: perl ; coding: iso-8859-2-unix -*-

# Translate dsa-*.wml file from English to Czech language.
# USAGE: dsa-description.pl file.wml

# Read by paragraph
$/="\n\n";

while (<>) {

# Delete \n except comment line and last \n in paragraph
s/\n([^\#])/ $1/g;
s/ $/\n/g;
s/  */ /g;

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

s{<define-tag description>([^<]*)buffer overflow([^<]*)</define-tag>}
{<define-tag description>${1}p�ete�en� bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary files([^<]*)</define-tag>}
{<define-tag description>${1}nespolehliv� do�asn� soubory${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary file([^<]*)</define-tag>}
{<define-tag description>${1}nespolehliv� do�asn� soubor${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary directory([^<]*)</define-tag>}
{<define-tag description>${1}nespolehliv� do�asn� adres��${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neo�et�en� vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)infinite loop([^<]*)</define-tag>}
{<define-tag description>${1}nekone�n� smy�ka${2}</define-tag>}g;

s{<define-tag description>([^<]*)format string([^<]*)</define-tag>}
{<define-tag description>${1}form�tov�n� �et�zce${2}</define-tag>}g;

s{<define-tag description>([^<]*)insufficient input validation([^<]*)</define-tag>}
{<define-tag description>${1}nedostate�n� kontrola vstupu${2}</define-tag>}g;

s{<define-tag description>weak hostname and username validation</define-tag>}
{<define-tag description>slab� kontrola jm�na po��ta�e a jm�na u�ivatele</define-tag>}g;


#
# More info
#

# exploit
# vyu��t

s{An attacker could create a carefully crafted image file in such a way that it could cause an application linked with imlib or imlib2 to execute arbitrary code when the file was opened by a victim\.}
{�to�n�k m��e vytvo�it pe�liv� zhotoven� soubor obr�zku, kter� pak
zp�sob� u aplikace slinkovan� s imlib nebo imlib2 spu�t�n� libovoln�ho
k�du, kdy� ob� tento soubor otev�e.}g;

s{An attacker could prepare specially crafted input that would not be sanitised by namazu2 and hence displayed verbatim for the victim\.}
{�to�n�k m��e p�ipravit speci�ln� upraven� vstup, kter� nen� programem vy�i�t�n a proto je doslovn� zobrazen ob�ti.}g;

# s{A cross-site scripting vulnerability}
# {}g;

s{Several vulnerabilities have been discovered in}
{Bylo objeveno n�kolik zranitelnost� v}g;

s{A vulnerability has been discovered in}
{Objevena zranitelnost v}g;

s{discoverd multiple vulnerabilities in}
{objevil mnohon�sobn� zranitelnosti v}g;

s{An ([\w-]+) security researcher}
{Bezpe�nostn� v�zkumn� pracovn�k ${1}}g;

s{The Common Vulnerabilities and Exposures project}
{Projekt Common Vulnerabilities and Exposures}g;

s{identifies the following problems}
{zjistil n�sleduj�c� probl�my}g;

s{Multiple heap-based buffer overflows\.}
{Mnohon�sobn� p�ete�en� bufferu typu halda (heap).}g;

s{No such code is present in ([\w-]+)\.}
{Tento k�d nen� obsa�en v ${1}.}g;

s{([Mm])ultiple integer overflows}
{${1}nohon�sobn� celo��seln� p�ete�en�}g;

s{in ([\w-]+) library}
{v knihovn� ${1}}g;

#
# info about packages
#

# libTIFF
s{the Tag Image File Format library for processing TIFF graphics files}
{knihovn� Tag Image File Format pro zpracov�n� grafick�ch soubor� TIFF}g;

s{a picture viewer for X11 with a thumbnail-based selector}
{programu pro prohl�en� obr�zk� pro X11 s v�b�rem z miniatur}g;

s{the ([pP])ortable ([dD])ocument ([fF])ormat \(PDF\) suite}
{sestav� ${1}ortable ${2}ocument ${3}ormat (PDF)}g;

# perl
s{the popular scripting language}
{popul�rn�m skriptovac�m jazyce}g;

s{the general-purpose x86 assembler}
{univerz�ln�m x86 assembleru}g;

# zip
s{the archiver for .zip files}
{spr�vce .zip arch�v�}g;

# pcal
s{a program to generate Post([sS])cript calendars}
{programu generuj�c�ho Post${1}cript kalend��e}g;

s{a full text search engine}
{fulltextov�m vyhled�vac�m stroji}g;

# imlib
s{imaging libraries for X11}
{obrazov�ch knihovn�ch pro X11}g;

s{an imaging library for X and X11}
{obrazov� knihovn� pro X a X11}g;



#
# other info
#

s{Remote exploitation of an integer overflow vulnerability could allow the execution of arbitrary code.}
{Vzd�len� vyu�it� zranitelnosti celo��seln�ho p�ete�en� dovoluje vykon�n� libovoln�ho k�du.}g;

s{A maliciously crafted ([\w-]+) file could exploit this problem, leading to the execution of arbitrary code.}
{Zlomysln� vytvo�en� ${1} soubor m��e vyu��t tento probl�m a&nbsp;spustit libovoln� k�d.}g;

#
# Fixed in packages
#

s{<p>For the (stable|unstable) distribution}
{<p>Pro $1 distribuci}g;

s{this problem has been fixed in version}
{byl tento probl�m opraven\nve verzi}g;

s{these problems have been fixed in version}
{byly tyto probl�my opraveny\nve verzi}g;

s{this problem will be fixed soon.</p>}
{bude tento probl�m brzy\nodstran�n.</p>}g;

s{these problems will be fixed soon.</p>}
{budou tyto probl�my brzy\nodstran�ny.</p>}g;

s{<p>This package is not present in the testing and unstable distributions.</p>}
{<p>Tento bal��ek nen� obsa�en v testing a unstable distribuci.</p>}g;

s{<p>The unstable distribution \(sid\) does not contain this package.</p>}
{<p>Unstable distribuce (sid) neobsahuje tento bal��ek.</p>}g;

s{<p>The unstable distribution \(sid\) does not contain a ([\w-]+) package\.}
{<p>Unstable distribuce (sid) neobsahuje bal��ek ${1}.}g;

s{In the unstable distribution \(sid\) this package does not exist anymore\.}
{V&nbsp;unstable distribuci (sid) ji� tento bal��ek neexistuje.}g;

s{It has been replaced by ([\w-]+)\.}
{Byl nahrazen bal��kem ${1}.}g;

#
# Upgrade it
#

s{<p>We recommend that you upgrade your ([\w-]+) package immediately.</p>}
{<p>Doporu�ujeme v�m ihned aktualizovat v� bal��ek ${1}.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) package.</p>}
{<p>Doporu�ujeme v�m aktualizovat v� bal��ek ${1}.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) packages.</p>}
{<p>Doporu�ujeme v�m aktualizovat va�e ${1} bal��ky.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) and ([\w-]+) packages.</p>}
{<p>Doporu�ujeme v�m aktualizovat va�e bal��ky ${1} a ${2}.</p>}g;


#
# Cleaning
#

s{ </define-tag>}{\n</define-tag>}g;
s{<define-tag moreinfo> }{<define-tag moreinfo>\n}g;

print ;
} # while
