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
$year = 2006;
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

# Copy the file
while (<SRC>)
{
	#next if /\$Id/;

	s/^(<p>)?A problem has been discovered in\b/$1Ein Problem wurde in entdeckt/;
	s/^(<p>)?It was discovered that\b/$1Es wurde entdeckt, dass/;
	s/\bdiscovered a problem in\b/entdeckte ein Problem in/;
	s/\bdiscovered a/entdeckte ein/;
	s/\bdiscovered that\b/entdeckte, dass/;
	s/^(<p>)?A vulnerability was discovered in\b/$1Eine Verwundbarkeit wurde in entdeckt/;
	s/^(<p>)?Two vulnerabilities were discovered in\b/$1Zwei Verwundbarkeiten wurden in entdeckt/;
	s/which could lead to the execution of arbitrary code/Dies kann zur Ausführung beliebigen Codes führen/;
	s/We recommend that you upgrade your (.*) package immediately/Wir empfehlen Ihnen, Ihr $1-Paket zu aktualisieren/;
	s/We recommend that you upgrade your (.*) packages immediately/Wir empfehlen Ihnen, Ihre $1-Pakete zu aktualisieren/;
	s/We recommend that you upgrade your (.*) and (.*) packages/Wir empfehlen Ihnen, Ihre $1- und $2-Pakete zu aktualisieren/;
	s/We recommend that you upgrade your (.*) packages/Wir empfehlen Ihnen, Ihre $1-Pakete zu aktualisieren/;
	s/We recommend that you upgrade your (.*) package/Wir empfehlen Ihnen, Ihr $1-Paket zu aktualisieren/;
	s/We recommend that you update your (.*) package immediately/Wir empfehlen Ihnen, Ihr $1-Paket zu aktualisieren/;
	s/We recommend that you update your (.*) packages immediately/Wir empfehlen Ihnen, Ihre $1-Pakete zu aktualisieren/;
	s/We recommend that you update your (.*) packages/Wir empfehlen Ihnen, Ihre $1-Pakete zu aktualisieren/;
	s/We recommend that you update your (.*) package/Wir empfehlen Ihnen, Ihr $1-Paket zu aktualisieren/;
	s/denial of service/Diensteverweigerung (<q>denial of service<\/q>)/;
	s/buffer overflows?/Pufferüberlauf/;
	s/integer overflow/Integer-Überlauf/;
	s/format string vulnerability/Formatierungszeichenkettenverwundbarkeit/;
	s/format string vulnerabilities/Formatierungszeichenkettenverwundbarkeiten/;
	s/insecure temporary files/unsichere temporäre Dateien/;
	s/>insecure temporary file creation</>Unsichere Erstellung temporärer Dateien</;
	s/>local root exploit</>Lokale root-Ausnutzung</;
	s/>remote root exploit</>Entfernte root-Ausnutzung</;
	s/>symlink attack</>Symlink-Angriff</;
	s/>remote exploit</>entfernter Exploit</;
	s/>missing input sanitising</>Fehlende Eingabebereinigung</;
	s/>programming error</>Programmierfehler</;
	s/Several vulnerabilities/Mehrere Verwundbarkeiten/;
	s/several vulnerabilities/mehrere Verwundbarkeiten/;
	s/Multiple vulnerabilities/Mehrere Verwundbarkeiten/;
	s/>several</>mehrere</;
	s/>unsanitise</>Fehlende Entschärfung</;
	s/ identifies the following problems:/ identifiziert die folgenden Probleme:/;
	s/The following matrix explains which kernel version for which architecture/The following matrix explains which kernel version for which architecture/;
	s/fix the problems mentioned above:/fix the problems mentioned above:/;
	s/fix the problem mentioned above:/fix the problem mentioned above:/;
	s/This has been fixed in version/This has been fixed in version/;
	s/(<td>.*) architecture/$1 architecture/;
	s/The following matrix lists additional packages that were rebuilt for/The following matrix lists additional packages that were rebuilt for/;
	s/compatibility with or to take advantage of this update:/compatibility with or to take advantage of this update:/;
	s/(?:,)?( )?this problem has been fixed in/$1wurde dieses Problem in/;
	s/(?:,)?( )?this problem has been fixed$/$1wurde dieses Problem/;
	s/(?:,)?( )?this problem has(?: been)?$/$1this problem has/;
	s/This problem has been fixed/This problem has been fixed/;
	s/(?:,)?( )?this problem is fixed in/$1this problem is fixed in/;
	s/(?:,)?( )?this problem is fixed/$1this problem is fixed/;
	s/These problems have been fixed/diese Probleme wurden in behoben/;
	s/(?:,)?( )?these problems have been fixed in/$1wurden diese Probleme in Version behoben/;
	s/(?:,)?( )?these problems have been fixed$/$1wurden diese Probleme behoben/;
	s/(?:,)?( )?these problems have(?: been)?$/$1diese Probleme wurden/;
	s/(?:,)?( )?these probleme are fixed in/$1diese Probleme wurden in behoben/;
	s/(?:,)?( )?these probleme are fixed/wurden diese Probleme behoben/;
	s/(?:,)?( )?these problems will be fixed soon/diese Probleme werden bald behoben sein/;
	s/(?:been )?fixed in version/wurde in Version behoben/;
	s/\bin version\b/in Version/;
	s/of the Debian package/des Debian-Pakets/;
	s/upstream version/Originalversion/;
	s/([Ff])or the old stable distribution/$1ür die alte Stable-Distribution/;
	s/([Ff])or the old stable/$1ür die alte Stable/;
	s/([Ff])or the current stable distribution/$1ür die aktuelle Stable-Distribution/;
	s/([Ff])or the current stable/$1ür die aktuelle Stable/;
	s/([Ff])or the upcoming stable distribution/$1ür die kommende Stable-Distribution/;
	s/([Ff])or the upcoming stable/$1ür die kommende Stable/;
	s/([Ff])or the Debian stable distribution/$1ür die Debian-Stable-Distribution/;
	s/([Ff])or the stable distribution/$1ür die Stable-Distribution/;
	s/([Ff])or the stable/$1ür die Stable/;
	s/([Ff])or the testing distribution/$1ür die Testing-Distribution/;
	s/([Ff])or the Debian unstable distribution/$1ür die Debian-Unstable-Distribution/;
	s/([Ff])or the unstable distribution/$1ür die Unstable-Distribution/;
	s/([Ff])or the unstable/$1ür die Unstable/;
	s/current stable distribution/aktuelle Stable-Distribution/;
	s/unstable distribution/Unstable-Distribution/;
	s/The old stable distribution/Die alte Stable-Distribution/;
	s/^stable distribution/^Stable-Distribution/;
	s/^unstable distribution/^Unstable-Distribution/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/enthält kein $1-Paket/;
	s/distribution (\(potato|woody|sarge\))/Distribution $1/;
	s/privilege escalation/Privilegienerweiterung/;
	s/cross site/Site-übergreifend/;
	s/\bis not affected/ist nicht betroffen/;
	s/does not contain ([[:word:]]*) packages?/enthält keine $1-Pakete?/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/enthält kein $1-Pakete/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/enthält kein $1-Paket/;
	s/this problem will be fixed soon/wird dieses Problem bald behoben sein/;
	s/\(potato\)/(Potato)/;
	s/\(woody\)/(Woody)/;
	s/\(sarge\)/(Sarge)/;
	s/\(etch\)/(Etch)/;
	s/\(sid\)/(Sid)/;
	s/Refer to Debian (<.*>)?bug #([0-9]+)</Verweisen auf $1 Debian-Fehler #$2</;
	s/(of|from) the Debian Security Audit (Project|Team)/vom Debian-Sicherheits-Audit-$2/;

	print DST $_;
}

# Insert the revision number
print DST qq'#use wml::debian::translation-check translation="$revision"\n';

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
