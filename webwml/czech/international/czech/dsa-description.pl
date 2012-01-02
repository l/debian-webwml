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
{<define-tag description>${1}několik zranitelností${2}</define-tag>}g;

s{<define-tag description>([^<]*)integer overflows([^<]*)</define-tag>}
{<define-tag description>${1}celočíselná přetečení${2}</define-tag>}g;

s{<define-tag description>([^<]*)integer overflow([^<]*)</define-tag>}
{<define-tag description>${1}celočíselné přetečení${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neošetřený vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)missing input sanitising([^<]*)</define-tag>}
{<define-tag description>${1}chybí ošetření vstupu${2}</define-tag>}g;

s{<define-tag description>([^<]*)buffer overflows([^<]*)</define-tag>}
{<define-tag description>${1}přetečení bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)buffer overflow([^<]*)</define-tag>}
{<define-tag description>${1}přetečení bufferu${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary files([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivé dočasné soubory${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary file([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivý dočasný soubor${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure temporary directory([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivý dočasný adresář${2}</define-tag>}g;

s{<define-tag description>([^<]*)insecure file access([^<]*)</define-tag>}
{<define-tag description>${1}nespolehlivý přístup k&nbsp;souboru${2}</define-tag>}g;

s{<define-tag description>([^<]*)unsanitised input([^<]*)</define-tag>}
{<define-tag description>${1}neošetřený vstup${2}</define-tag>}g;

s{<define-tag description>([^<]*)infinite loop([^<]*)</define-tag>}
{<define-tag description>${1}nekonečná smyčka${2}</define-tag>}g;

s{<define-tag description>([^<]*)format string([^<]*)</define-tag>}
{<define-tag description>${1}formátování řetězce${2}</define-tag>}g;

s{<define-tag description>([^<]*)insufficient input validation([^<]*)</define-tag>}
{<define-tag description>${1}nedostatečná kontrola vstupu${2}</define-tag>}g;

s{<define-tag description>([^<]*)weak hostname and username validation([^<]*)</define-tag>}
{<define-tag description>${1}slabá kontrola jména počítače a jména uživatele${2}</define-tag>}g;

s{<define-tag description>([^<]*)missing privilege release([^<]*)</define-tag>}
{<define-tag description>${1}chybějící kontrola práv${2}</define-tag>}g;

#
# More info
#

# exploit
# využít

s{An attacker could create a carefully crafted image file in such a way that it could cause an application linked with imlib or imlib2 to execute arbitrary code when the file was opened by a victim\.}
{Útočník může vytvořit pečlivě zhotovený soubor obrázku, který pak
způsobí u aplikace slinkované s imlib nebo imlib2 spuštění libovolného
kódu, když oběť tento soubor otevře.}g;

s{An attacker could prepare specially crafted input that would not be sanitised by namazu2 and hence displayed verbatim for the victim\.}
{Útočník může připravit speciálně upravený vstup, který není programem vyčištěn a proto je doslovně zobrazen oběti.}g;

# s{A cross-site scripting vulnerability}
# {}g;

s{Several vulnerabilities have been discovered in}
{Bylo objeveno několik zranitelností v}g;

s{A vulnerability has been discovered in}
{Objevena zranitelnost v}g;

s{discoverd multiple vulnerabilities in}
{objevil mnohonásobné zranitelnosti v}g;

s{An ([\w-]+) security researcher}
{Bezpečnostní výzkumný pracovník ${1}}g;

s{The Common Vulnerabilities and Exposures project}
{Projekt Common Vulnerabilities and Exposures}g;

s{identifies the following problems}
{zjistil následující problémy}g;

s{Multiple heap-based buffer overflows\.}
{Mnohonásobná přetečení bufferu typu halda (heap).}g;

s{No such code is present in ([\w-]+)\.}
{Tento kód není obsažen v ${1}.}g;

s{([Mm])ultiple integer overflows}
{${1}nohonásobná celočíselná přetečení}g;

s{in ([\w-]+) library}
{v knihovně ${1}}g;

#
# info about packages
#

# libTIFF
s{the Tag Image File Format library for processing TIFF graphics files}
{knihovně Tag Image File Format pro zpracování grafických souborů TIFF}g;

s{a picture viewer for X11 with a thumbnail-based selector}
{programu pro prohlížení obrázků pro X11 s výběrem z miniatur}g;

s{the ([pP])ortable ([dD])ocument ([fF])ormat \(PDF\) suite}
{sestavě ${1}ortable ${2}ocument ${3}ormat (PDF)}g;

# perl
s{the popular scripting language}
{populárním skriptovacím jazyce}g;

s{the general-purpose x86 assembler}
{univerzálním x86 assembleru}g;

# zip
s{the archiver for .zip files}
{správce .zip archívů}g;

# pcal
s{a program to generate Post([sS])cript calendars}
{programu generujícího Post${1}cript kalendáře}g;

s{a full text search engine}
{fulltextovém vyhledávacím stroji}g;

# imlib
s{imaging libraries for X11}
{obrazových knihovnách pro X11}g;

s{an imaging library for X and X11}
{obrazové knihovně pro X a X11}g;



#
# other info
#

s{Remote exploitation of an integer overflow vulnerability could allow the execution of arbitrary code.}
{Vzdálené využití zranitelnosti celočíselného přetečení dovoluje vykonání libovolného kódu.}g;

s{A maliciously crafted ([\w-]+) file could exploit this problem, leading to the execution of arbitrary code.}
{Zlomyslně vytvořený ${1} soubor může využít tento problém a&nbsp;spustit libovolný kód.}g;

#
# Fixed in packages
#

s{For the unstable distribution \(sid\) these problems should already be fixed since they were backported from current versions.}
{V&nbsp;unstable distribuci (sid) by již měly být tyto problémy\nopraveny, protože byly vzaty z&nbsp;aktuálních verzí.}g;

s{<p>For the (stable|unstable) distribution}
{<p>Pro $1 distribuci}g;

s{this problem has been fixed in version}
{byl tento problém opraven\nve verzi}g;

s{these problems have been fixed in version}
{byly tyto problémy opraveny\nve verzi}g;

s{this problem will be fixed soon.</p>}
{bude tento problém brzy\nodstraněn.</p>}g;

s{these problems will be fixed soon.</p>}
{budou tyto problémy brzy\nodstraněny.</p>}g;

s{<p>This package is not present in the testing and unstable distributions.</p>}
{<p>Tento balíček není obsažen v testing a unstable distribuci.</p>}g;

s{<p>The unstable distribution \(sid\) does not contain this package.</p>}
{<p>Unstable distribuce (sid) neobsahuje tento balíček.</p>}g;

s{<p>The unstable distribution \(sid\) does not contain a ([\w-]+) package\.}
{<p>Unstable distribuce (sid) neobsahuje balíček ${1}.}g;

s{In the unstable distribution \(sid\) this package does not exist anymore\.}
{V&nbsp;unstable distribuci (sid) již tento balíček neexistuje.}g;

s{<p>In the unstable distribution \(sid\) CUPSYS does not use its own xpdf variant anymore but uses xpdf-utils.</p>}
{<p>V&nbsp;unstable distribuci (sid) CUPSYS již nepoužívá svoji vlastní xpdf variantu, ale používá xpdf-utils.</p>}g;

s{It has been replaced by ([\w-]+)\.}
{Byl nahrazen balíčkem ${1}.}g;

#
# Upgrade it
#

s{<p>We recommend that you upgrade your ([\w-]+) package immediately.</p>}
{<p>Doporučujeme vám ihned aktualizovat váš balíček ${1}.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) package.</p>}
{<p>Doporučujeme vám aktualizovat váš balíček ${1}.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) packages.</p>}
{<p>Doporučujeme vám aktualizovat vaše ${1} balíčky.</p>}g;

s{<p>We recommend that you upgrade your ([\w-]+) and ([\w-]+) packages.</p>}
{<p>Doporučujeme vám aktualizovat vaše balíčky ${1} a ${2}.</p>}g;


#
# Cleaning
#

s{ </define-tag>}{\n</define-tag>}g;
s{<define-tag moreinfo> }{<define-tag moreinfo>\n}g;

print ;
} # while
