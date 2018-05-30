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

use FindBin;
use lib "$FindBin::Bin/../../Perl";
use Local::VCS;

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
$dstdir = "./$year";
$dstfile= "$dstdir/$number.wml";

# Sanity checks
die "File $srcfile does not exist\n"     unless -e $srcfile;
die "File $dstfile already exists\n"     if     -e $dstfile;
mkdir $dstdir, 0755                      unless -d $dstdir;

my $VCS = Local::VCS->new();
my %file_info = $VCS->file_info($srcfile);
$revision = $file_info{'cmt_rev'};
unless ($revision)
{
	die "Could not get revision number - bug in script?\n";
}

# Open the files
open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

# Insert the revision number
print DST qq'#use wml::debian::translation-check translation="$revision" mindelta="1"\n';

# Copy the file
while (<SRC>)
{
	next if /\$Id/;

	s/^(<p>)?A problem has been discovered in\b/$1Ett problem har upptäckts i/;
	s/\bdiscovered a problem in\b/upptäckte ett problem i/;
	s/Updates for the oldstable distribution \(wheezy\) will be released shortly/Uppdateringar för den gamla stabila utgåvan \(Wheezy\) kommer att släppas inom kort/;
	s/The oldstable distribution/Den gamla stabila utgåvan/;
	s/is not affected by this problem/påverkas inte av detta problem/;
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
	s/security update/säkerhetsuppdatering/;
	s/exposure of sensitive information/exponering av känslig information/;
	s/buffer overflows?/buffertspill/;
	s/integer overflow/heltalsspill/;
	s/heap overflow/heapbaserat bufferspill/;
	s/([Dd])enial of ([Ss])ervice/överbelastning/;
	s/information disclosure/utlämnande av information/;
	s/information leak/informationsläckage/;
	s/interpretation conflict/tolkningskonflikt/;
	s/format string vulnerability/formatsträngssårbarhet/;
	s/format string vulnerabilities/formatsträngssårbarheter/;
	s/arbitrary script execution/opålitlig skriptkörning/;
	s/uninitialized memory read/läsning av oinitierat minne/;
	s/insecure temporary files/osäkra temporära filer/;
	s/cross-site request forgery/serveröverskridande anropsförfalskning/;
	s/>insecure temporary file creation</>osäkra temporära filer</;
	s/>local root exploit</>lokal rootattack</;
	s/>remote root exploit</>fjärr-rootattack</;
	s/>symlink attack</>attack mot symboliska länkar</;
	s/>remote exploit</>fjärrattack</;
	s/>missing input sanitising</>städar inte indata</;
	s/>insufficient input sanitising</>otillräcklig städning av indata</;
	s/>insufficient input validation</>otillräcklig validering av indata</;
	s/>programming error</>programmeringsfel</;
	s/>certificate verification flaw</>problem vid kontroll av certifikat</;
	s/cross-site scripting vulnerability/serveröverskridande skriptsårbarhet/;
	s/>various</>diverse</;
	s/>unsanitised input</>städar ej indata</;
	s/The Common Vulnerabilities and Exposures project/Projektet Common Vulnerabilities and Exposures/;
	s/The Common Vulnerabilities and/Projektet Common Vulnerabilities and/;
	s/Exposures project/Exposures/;
	s/The Common Vulnerabilities and Exposures/Projektet Common Vulnerabilities and/;
	s/The Common Vulnerabilities/Projektet Common Vulnerabilities/;
	s/and Exposures project/and Exposures/;
	s/The Common/Projektet Common/;
	s/Vulnerabilities and Exposures project/Vulnerabilities and Exposures/;
	s/\bidentifies the following (?:problems|issues):/identifierar följande problem:/;
	s/The following matrix explains which kernel version for which architecture/Följande tabell beskriver vilka versioner av kärnan för vilka arkitekturer som/;
	s/fix the problems mentioned above:/rättar problemen som beskrivs ovan:/;
	s/fix the problem mentioned above:/rättar problemet som beskrivs ovan:/;
	s/This has been fixed in version/Detta har rättats i version/;
	s/([Ff])or the testing distribution \(wheezy\)\, this problem will be fixed soon./För uttestningsutgåvan \(Wheezy\) kommer detta problem att rättas inom kort/;
	s/(<td>.*) architecture/$1-arkitekturen/;
	s/The following matrix lists additional packages that were rebuilt for/Följande tabell beskriver ytterligare paket som byggts om för kompatibilitet/;
	s/The following matrix lists additional source packages that were rebuilt for/Följande tabell beskriver ytterligare källkodspaket som byggts om för kompatibilitet/;
	s/compatibility with or to take advantage of this update:/med, eller för att dra nytta av, denna uppdatering:/;
	s/For the unstable distribution \(sid\)\, this problem will be fixed (?:soon|shortly)./För den instabila utgåvan (Sid) kommer detta problem att rättas inom kort./;
	s/For the testing \(stretch\) and unstable \(sid\) distributions\, this/För uttestningsutgåvan \(Stretch\) och den instabila utgåvan \(Sid\)\, har/;
	s/\(sid\)\, this problem has been fixed in version/\(Sid\)\, har detta problem rättats i version/;
	s/problem has been fixed in version/detta problem rättats i version/;
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
	s/(?:,)?( )?these problems will be fixed in/$1kommer dessa problem att rättas i/;
	s/(?:,)?( )?these problems will be/$1kommer dessa problem att/;
	s/this problem will be fixed soon/kommer detta problem att rättas inom kort/;
	s/this problem will be fixed in/kommer detta problem att rättas i/;
	s/this problem will be/kommer detta problem att/;
	s/fixed soon/rättas inom kort/;
	s/For the unstable (sid) and testing (wheezy) distribution, this problem/För den instabila utgåvan (Sid) och uttestningsutgåvan (Wheezy) kommer detta problem/;
	s/will be fixed soon/att rättas inom kort./;
	s/(?:been )?fixed in version/rättats i version/;
	s/\bin version\b/i version/;
	s/of the Debian package/av Debianpaketet/;
	s/upstream version/uppströmsversion/;
	s/The testing distribution \(wheezy\), and the unstable distribution \(sid\)/Uttestningsutgåvan (Wheezy) och den instabila utgåvan (Sid)/;
	s/([Ff])or the old ?stable distribution/$1ör den gamla stabila utgåvan/;
	s/([Ff])or the old ?stable/$1ör den gamla stabila/;
	s/([Ff])or the current stable distribution/$1ör den nuvarande stabila utgåvan/;
	s/([Ff])or the current stable/$1ör den nuvarande stabila/;
	s/([Ff])or the upcoming stable \(jessie\) and unstable \(sid\) distributions/$1ör den kommande stabila utgåvan (Jessie) och den instabila utgåvan (Sid)/;
	s/([Ff])or the upcoming stable distribution/$1ör den kommande stabila utgåvan/;
	s/([Ff])or the upcoming stable/$1ör den kommande stabila/;
	s/([Ff])or the Debian stable distribution/$1ör Debians stabila utgåva/;
	s/([Ff])or the stable distribution/$1ör den stabila utgåvan/;
	s/([Ff])or the stable/$1ör den stabila/;
	s/([Ff])or the testing (wheezy) and unstable (sid) distributions/$1ör uttestningsutgåvan (Wheezy) och den instabila utgåvan (Sid)/;
	s/([Ff])or the testing (wheezy) and the unstable distribution/$1ör uttestningsutgåvan (Wheezy) och den instabila utgåvan/;
	s/([Ff])or the testing \(([Ww])heezy\) and unstable distribution/$1ör uttestningsutgåvan (Wheezy) och den instabila utgåvan/;
	s/([Ff])or the testing distribution \(jessie\) and?( )(?:the) unstable distribution/$1ör uttestningsutgåvan \(Jessie\) och den instabila utgåvan/;
	s/([Ff])or the testing distribution \(stretch\) and the unstable distribution/$1ör uttestningsutgåvan \(Stretch\) och den instabila utgåvan/;
	s/([Ff])or the testing distribution \(stretch\) and unstable distribution/$1ör uttestningsutgåvan \(Stretch\) och den instabila utgåvan/;
	s/([Ff])or the testing distribution \(([Ww])heezy\)(?:,)?( )and (?:the )?unstable distribution/$1ör uttestningsutgåvan \(Wheezy\) och den instabila utgåvan/;
	s/([Ff])or the testing distribution/$1ör uttestningsutgåvan/;
	s/([Ff])or the Debian unstable distribution/$1ör Debians instabila distribution/;
	s/([Ff])or the unstable distribution/$1ör den instabila distributionen/;
	s/([Ff])or the unstable/$1ör den instabila/;
	s/no longer contain this package./innehåller inte längre detta paket./;
	s/current stable distribution/nuvarande stabila utgåvan/;
	s/unstable distribution/instabila distributionen/;
	s/The old stable distribution/Den gamla stabila utgåvan/;
	s/^stable distribution/stabila utgåvan/;
	s/^unstable distribution/instabila distributionen/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/innehåller inte paketet $1/;
	s/distribution (\(potato|woody|sarge\))/utgåvan $1/;
	s/privilege escalation/utökning av privilegier/;
	s/cross site/serveröverskridande/;
	s/\bis not affected/påverkas inte/;
	s/does not contain ([[:word:]]*) packages?/innehåller inte $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/innehåller inte några $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/innehåller inte något $1-paket/;
	s/this problem will be fixed soon/kommer detta problem rättas inom kort/;
	s/\, this problem will be fixed/\, kommer detta problem att rättas/;
	s/soon\.\<\/p\>/inom kort\.\<\/p\>/;
	s/\(potato\)/(Potato)/;
	s/\(woody\)/(Woody)/;
	s/\(sarge\)/(Sarge)/;
	s/\(etch\)/(Etch)/;
	s/\(lenny\)/(Lenny)/;
	s/\(squeeze\)/(Squeeze)/;
	s/\(wheezy\)/(Wheezy)/;
	s/\(jessie\)/(Jessie)/;
	s/\(stretch\)/(Stretch)/;
	s/\(buster\)/(Buster)/;
	s/\(sid\)/(Sid)/;
	s/Refer to Debian (<.*>)?bug #([0-9]+)</Se Debians $1felrapport $2</;
	s/(of|from) the Debian Security Audit (Project|Team)/från Debians säkerhetsgranskningsprojekt/i;
	s/å/å/g;
	s/ä/ä/g;
	s/ö/ö/g;
	s/\bSeveral remote vulnerabilities have been discovered in /Man har upptäckt flera utifrån nåbara sårbarheter i /;
	s/\bSeveral local\/remote vulnerabilities have been discovered in /Man har upptäckt flera lokala och utifrån nåbara sårbarheter i /;
	s/\bSeveral vulnerabilities (were|have been) discovered in /Flera sårbarheter har upptäckts i /;
	s/(Several|Multiple) vulnerabilities/Flera sårbarheter/;
	s/(several|multiple) vulnerabilities/flera sårbarheter/;
	s/>several</>flera</;
	s/an unbranded version of the Firefox browser/en varumärkesfri version av webbläsaren Firefox/;
	s/an unbranded version of the /en varumärkesfri version av /;
	s/directory traversal/katalogtraversering/;
	s/<p><b>Note<\/b>\: Debian carefully tracks all known security issues across every/<p><b>Observera<\/b>\: Debian spårar försiktigt alla kända säkerhetsproblem i alla/;
	s/linux kernel package in all releases under active security support./paket för linuxkärnan i alla utgåvor som är under aktivt säkerhetsstöd./;
	s/However\, given the high frequency at which low-severity security/Dock\, givet den höga frekvensen som säkehetsproblem med låg allvarlighetsgrad/;
	s/issues are discovered in the kernel and the resource requirements of/upptäcks i kärnan och resurserna som krävs för att göra en uppdatering/;
	s/doing an update, updates for lower priority issues will normally not/så kommer uppdateringar för problem med lägre prioritet inte släppas/;
	s/be released for all kernels at the same time. Rather, they will be/samtidigt för alla kärnor på samma gång. Istället kommer dom att släppas/;
	s/released in a staggered or "leap-frog" fashion.<\/p>/i större klumpar.<\/p>/;
	s/\<p\>For the detailed security status of (.*) please refer to/<p>För detaljerad säkerhetsstatus om $1 vänligen se/;
	s/its security tracker page at\:/dess säkerhetsspårare på/;
	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
