#!/usr/bin/perl -w -p     -*- mode: perl ; coding: iso-8859-2-unix -*-

# Translate dsa-*.wml file from English to Czech language.
# USAGE: dsa-description.pl file.wml

# Read by paragraph
$/="\n\n";

# Delete \n except comment line and last \n in paragraph
s/\n([^\#])/ $1/g;
s/ $/\n/g;
s/  */ /g;

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

s{<define-tag description>([^<]*)buffer overflow([^<]*)</define-tag>}
{<define-tag description>${1}pøeteèení bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary files([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivé doèasné soubory${2}</define-tag>}g;

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

s{An attacker could create a carefully crafted image file in such a way that it could cause an application linked with imlib or imlib2 to execute arbitrary code when the file was opened by a victim\.}
{Útoèník mù¾e vytvoøit peèlivì zhotovený soubor obrázku, který pak
zpùsobí u aplikace slinkované s imlib nebo imlib2 spu¹tìní libovolného
kódu, kdy¾ obì» tento soubor otevøe.}g;

# s{A cross-site scripting vulnerability}
# {}g;

s{Several vulnerabilities have been discovered in}
{Bylo objeveno nìkolik zranitelností v}g;

s{A vulnerability has been discovered in}
{Objevena zranitelnost v}g;

s{discoverd multiple vulnerabilities in}
{objevil mnohonásobné zranitelnosti v}g;

s{An (\w+) security researcher}
{Bezpeènostní výzkumný pracovník ${1}}g;

s{The Common Vulnerabilities and Exposures project}
{Projekt Common Vulnerabilities and Exposures}g;

s{identifies the following problems}
{zjistil následující problémy}g;

s{Multiple heap-based buffer overflows\.}
{Mnohonásobná pøeteèení bufferu typu halda (heap).}g;

s{No such code is present in (\w+)\.}
{Tento kód není obsa¾en v ${1}.}g;

s{([Mm])ultiple integer overflows}
{${1}nohonásobná celoèíselná pøeteèení}g;

s{in (\w+) library}
{v knihovnì ${1}}g;

#
# info about packages
#

# libTIFF
s{the Tag Image File Format library for processing TIFF graphics files}
{knihovnì Tag Image File Format pro zpracování grafických souborù TIFF}g;

s{a picture viewer for X11 with a thumbnail-based selector}
{programu pro prohlí¾ení obrázkù pro X11 s výbìrem z miniatur}g;

s{the ([pP])ortable ([dD])ocument ([fF])ormat \(PDF\) suite}
{sestavì ${1}ortable ${2}ocument ${3}ormat (PDF)}g;

# perl
s{the popular scripting language}
{populárním skriptovacím jazyce}g;

s{the general-purpose x86 assembler}
{univerzálním x86 assembleru}g;

# zip
s{the archiver for .zip files}
{správce .zip archívù}g;

# pcal
s{a program to generate Post([sS])cript calendars}
{programu generujícího Post${1}cript kalendáøe}g;

s{a full text search engine}
{fulltextovém vyhledávacím stroji}g;

# imlib
s{imaging libraries for X11}
{obrazových knihovnách pro X11}g;

s{an imaging library for X and X11}
{obrazové knihovnì pro X a X11}g;



#
# other info
#

s{Remote exploitation of an integer overflow vulnerability could allow the execution of arbitrary code.}
{Vzdálené vyu¾ití zranitelnosti celoèíselného pøeteèení dovoluje vykonání libovolného kódu.}g;

s{A maliciously crafted (\w+) file could exploit this problem, leading to the execution of arbitrary code.}
{Zlomyslnì vytvoøený ${1} soubor mù¾e vyu¾ít tento problém a&nbsp;spustit libovolný kód.}g;

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

s{<p>The unstable distribution \(sid\) does not contain this package.</p>}
{<p>Unstable distribuce (sid) neobsahuje tento balíèek.</p>}g;


#
# Upgrade it
#

s{<p>We recommend that you upgrade your (\w+) package immediately.</p>}
{<p>Doporuèujeme vám ihned aktualizovat vá¹ balíèek ${1}.</p>}g;

s{<p>We recommend that you upgrade your (\w+) package.</p>}
{<p>Doporuèujeme vám aktualizovat vá¹ balíèek ${1}.</p>}g;

s{<p>We recommend that you upgrade your (\w+) packages.</p>}
{<p>Doporuèujeme vám aktualizovat va¹e ${1} balíèky.</p>}g;

#
# Cleaning
#

s{ </define-tag>}{\n</define-tag>}g;
s{<define-tag moreinfo> }{<define-tag moreinfo>\n}g;

#print "---\n";
