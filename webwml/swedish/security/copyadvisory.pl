#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000-2006 by Peter Karlsson <peterk@debian.org>
# © Copyright 2000-2005 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# Get command line
$number = $ARGV[0];

# Check usage.
unless ($number)
{
	print "Usage: $0 advisorynumber\n\n";
	print "Copies the advisory from the English directory to the local one and adds\n";
	print "the translation-check header\n";
	exit;
}

# Locate advisory
$number = "dsa-" . $number if $number !~ /^dsa-/;
$year = 2008;
YEAR: while (-d "../../english/security/$year")
{
	last YEAR if -e "../../english/security/$year/$number.wml";
	$year ++;
}

# Create needed file and directory names
$srcdir = "../../english/security/$year";
die "Unable to locate English version of advisory $number.\n"
	if ! -d $srcdir;
$srcfile= "$srcdir/$number.wml";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year";
$dstfile= "$dstdir/$number.wml";

# Sanity checks
die "File $srcfile does not exist\n"     unless -e $srcfile;
die "File $dstfile already exists\n"     if     -e $dstfile;
mkdir $dstdir, 0755                      unless -d $dstdir;

# Open the files
open CVS, $cvsfile
	or die "Could not read $cvsfile ($!)\n";

open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

# Retrieve the CVS version number
while (<CVS>)
{
	if (m[^/$number\.wml/([0-9]*\.[0-9]*)/]o)
	{
		$revision = $1;
	}
}

close CVS;

unless ($revision)
{
	print "Could not get revision number - bug in script?\n";
	$revision = '1.1';
}

# Insert the revision number
print DST qq'#use wml::debian::translation-check translation="$revision" mindelta="1"\n';

# Copy the file
while (<SRC>)
{
	next if /\$Id/;

	s/^(<p>)?A problem has been discovered in\b/$1Ett problem har upptäckts i/;
	s/\bdiscovered a problem in\b/upptäckte ett problem i/;
	s/^(<p>)?A vulnerability was discovered in\b/$1En sårbarhet upptäcktes i/;
	s/^(<p>)?Two vulnerabilities were discovered in\b/$1Två sårbarheter upptäcktes i/;
	s/Several local and remote vulnerabilities/Flera lokala och utifrån nåbara sårbarheter/;
	s/It was discovered that /Man har upptäckt att /;
	s/We recommend that you upgrade your (.*) package immediately/Vi rekommenderar att ni uppgraderar ert $1-paket omedelbart/;
	s/We recommend that you upgrade your (.*) packages immediately/Vi rekommenderar att ni uppgraderar era $1-paket omedelbart/;
	s/We recommend that you upgrade your (.*) and (.*) packages/Vi rekommenderar att ni uppgraderar era $1- och $2-paket/;
	s/We recommend that you upgrade your (.*) packages/Vi rekommenderar att ni uppgraderar era $1-paket/;
	s/We recommend that you upgrade your (.*) package/Vi rekommenderar att ni uppgraderar ert $1-paket/;
	s/We recommend that you update your (.*) package immediately/Vi rekommenderar att ni uppgraderar ert $1-paket omedelbart/;
	s/We recommend that you update your (.*) packages immediately/Vi rekommenderar att ni uppgraderar era $1-paket omedelbart/;
	s/We recommend that you update your (.*) packages/Vi rekommenderar att ni uppgraderar era $1-paket/;
	s/We recommend that you update your (.*) package/Vi rekommenderar att ni uppgraderar ert $1-paket/;
	s/buffer overflows?/buffertspill/;
	s/integer overflow/heltalsspill/;
	s/format string vulnerability/formatsträngssårbarhet/;
	s/format string vulnerabilities/formatsträngssårbarheter/;
	s/insecure temporary files/osäkra temporära filer/;
	s/>insecure temporary file creation</>osäkra temporära filer</;
	s/>local root exploit</>lokal rootattack</;
	s/>remote root exploit</>fjärr-rootattack</;
	s/>symlink attack</>attack mot symboliska länkar</;
	s/>remote exploit</>fjärrattack</;
	s/>missing input sanitising</>städar inte indata</;
	s/>insufficient input sanitising</>otillräcklig städning av indata</;
	s/>programming error</>programmeringsfel</;
	s/>various</>diverse</;
	s/(Several|Multiple) vulnerabilities/Flera sårbarheter/;
	s/(several|multiple) vulnerabilities/flera sårbarheter/;
	s/>several</>flera</;
	s/>unsanitised input</>städar ej indata</;
	s/\bidentifies the following problems:/identifierar följande problem:/;
	s/The following matrix explains which kernel version for which architecture/Följande tabell beskriver vilka versioner av kärnan för vilka arkitekturer som/;
	s/fix the problems mentioned above:/rättar problemen som beskrivs ovan:/;
	s/fix the problem mentioned above:/rättar problemet som beskrivs ovan:/;
	s/This has been fixed in version/Detta har rättats i version/;
	s/(<td>.*) architecture/$1-arkitekturen/;
	s/The following matrix lists additional packages that were rebuilt for/Följande tabell beskriver ytterligare paket som byggts om för kompatibilitet/;
	s/compatibility with or to take advantage of this update:/med, eller för att dra nytta av, denna uppdatering:/;
	s/(?:,)?( )?th(?:is|e) problem (?:has been|was) fixed in/$1har detta problem rättats i/;
	s/(?:,)?( )?th(?:is|e) problem (?:has been|was) fixed$/$1har detta problem rättats/;
	s/(?:,)?( )?th(?:is|e) problem has(?: been)?$/$1har detta problem/;
	s/This problem has been fixed/Detta problem har rättats/;
	s/(?:,)?( )?this problem is fixed in/$1rättas detta problem i/;
	s/(?:,)?( )?this problem is fixed/$1rättas detta problem/;
	s/These problems have been fixed/Dessa problem har rättats/;
	s/(?:,)?( )?these problems have been fixed in/$1har dessa problem rättats i/;
	s/(?:,)?( )?these problems have been fixed$/$1har dessa problem rättats/;
	s/(?:,)?( )?these problems have(?: been)?$/$1har dessa problem/;
	s/(?:,)?( )?these problem are fixed in/$1rättas dessa problem i/;
	s/(?:,)?( )?these problem are fixed/$1rättas dessa problem/;
	s/(?:,)?( )?these problems will be fixed soon/$1kommer dessa problem att rättas inom kort/;
	s/this problem with be fixed soon/kommer detta problem att rättas inom kort/;
	s/(?:been )?fixed in version/rättats i version/;
	s/\bin version\b/i version/;
	s/of the Debian package/av Debianpaketet/;
	s/upstream version/uppströmsversion/;
	s/([Ff])or the old ?stable distribution/$1ör den gamla stabila utgåvan/;
	s/([Ff])or the old ?stable/$1ör den gamla stabila/;
	s/([Ff])or the current stable distribution/$1ör den nuvarande stabila utgåvan/;
	s/([Ff])or the current stable/$1ör den nuvarande stabila/;
	s/([Ff])or the upcoming stable distribution/$1ör den kommande stabila utgåvan/;
	s/([Ff])or the upcoming stable/$1ör den kommande stabila/;
	s/([Ff])or the Debian stable distribution/$1ör Debians stabila utgåva/;
	s/([Ff])or the stable distribution/$1ör den stabila utgåvan/;
	s/([Ff])or the stable/$1ör den stabila/;
	s/([Ff])or the testing distribution/$1ör uttestningsutgåvan/;
	s/([Ff])or the Debian unstable distribution/$1ör Debians instabila utgåva/;
	s/([Ff])or the unstable distribution/$1ör den instabila utgåvan/;
	s/([Ff])or the unstable/$1ör den instabila/;
	s/current stable distribution/nuvarande stabila utgåvan/;
	s/unstable distribution/instabila utgåvan/;
	s/The old stable distribution/Den gamla stabila utgåvan/;
	s/^stable distribution/stabila utgåvan/;
	s/^unstable distribution/instabila utgåvan/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/innehåller inte paketet $1/;
	s/distribution (\(potato|woody|sarge\))/utgåvan $1/;
	s/privilege escalation/utökning av privilegier/;
	s/cross site/serveröverskridande/;
	s/\bis not affected/påverkas inte/;
	s/does not contain ([[:word:]]*) packages?/innehåller inte $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/innehåller inte några $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/innehåller inte något $1-paket/;
	s/this problem will be fixed soon/kommer detta problem rättas inom kort/;
	s/\(potato\)/(Potato)/;
	s/\(woody\)/(Woody)/;
	s/\(sarge\)/(Sarge)/;
	s/\(etch\)/(Etch)/;
	s/\(sid\)/(Sid)/;
	s/Refer to Debian (<.*>)?bug #([0-9]+)</Se Debians $1felrapport $2</;
	s/(of|from) the Debian Security Audit (Project|Team)/från Debians säkerhetsgranskningsprojekt/i;
	s/å/å/g;
	s/ä/ä/g;
	s/ö/ö/g;
	s/\bSeveral remote vulnerabilities have been discovered in /Man har upptäckt flera utifrån nåbara sårbarheter i /;
	s/\bSeveral local\/remote vulnerabilities have been discovered in /Man har upptäckt flera lokala och utifrån nåbara sårbarheter i /;
	s/\bSeveral vulnerabilities have been discovered in /Man har upptäckt flera sårbarheter i /;
	s/an unbranded version of the Firefox browser/en varumärkesfri version av webbläsaren Firefox/;
	s/an unbranded version of the /en varumärkesfri version av /;

	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
