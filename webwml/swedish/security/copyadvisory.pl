#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000-2004 by Peter Karlsson <peterk@debian.org>
# � Copyright 2000-2004 Software in the public interest, Inc.
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
$year = 2004;
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

	s/^(<p>)?A problem has been discovered in\b/$1Ett problem har uppt�ckts i/;
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
	s/format string vulnerability/formatstr�ngss�rbarhet/;
	s/format string vulnerabilities/formatstr�ngss�rbarheter/;
	s/insecure temporary files/os�kra tempor�ra filer/;
	s/>local root exploit</>lokal rootattack</;
	s/>remote root exploit</>fj�rr-rootattack</;
	s/>symlink attack</>attack mot symboliska l�nkar</;
	s/>remote exploit</>fj�rrattack</;
	s/Several vulnerabilities/Flera s�rbarheter/;
	s/several vulnerabilities/flera s�rbarheter/;
	s/>several</>flera</;
	s/This has been fixed in version/Detta har r�ttats i version/;
	s/this problem has been fixed in/har detta problem r�ttats i/;
	s/this problem has been fixed$/har detta problem r�ttats/;
	s/this problem has(?: been)?$/har detta problem/;
	s/This problem has been fixed/Detta problem har r�ttats/;
	s/this problem is fixed in/r�ttas detta problem i/;
	s/this problem is fixed/r�ttas detta problem/;
	s/These problems have been fixed/Dessa problem har r�ttats/;
	s/these problems have been fixed in/har dessa problem r�ttats i/;
	s/these problems have been fixed$/har dessa problem r�ttats/;
	s/these problems have(?: been)?$/har dessa problem/;
	s/these problem are fixed in/r�ttas dessa problem i/;
	s/these problem are fixed/r�ttas dessa problem/;
	s/these problems will be fixed soon/kommer dessa problem att r�ttas inom kort/;
	s/(?:been )?fixed in version/r�ttats i version/;
	s/\bin version\b/i version/;
	s/of the Debian package/av Debianpaketet/;
	s/upstream version/uppstr�msversion/;
	s/([Ff])or the old stable distribution/$1�r den gamla stabila utg�van/;
	s/([Ff])or the old stable/$1�r den gamla stabila/;
	s/([Ff])or the current stable distribution/$1�r den nuvarande stabila utg�van/;
	s/([Ff])or the current stable/$1�r den nuvarande stabila/;
	s/([Ff])or the Debian stable distribution/$1�r Debians stabila utg�va/;
	s/([Ff])or the stable distribution/$1�r den stabila utg�van/;
	s/([Ff])or the stable/$1�r den stabila/;
	s/([Ff])or the Debian unstable distribution/$1�r Debians instabila utg�va/;
	s/([Ff])or the unstable distribution/$1�r den instabila utg�van/;
	s/([Ff])or the unstable/$1�r den instabila/;
	s/current stable distribution/nuvarande stabila utg�van/;
	s/unstable distribution/instabila utg�van/;
	s/The old stable distribution/Den gamla stabila utg�van/;
	s/^stable distribution/stabila utg�van/;
	s/^unstable distribution/instabila utg�van/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/inneh�ller inte n�got $1-paket/;
	s/distribution (\(potato|woody|sarge\))/utg�van $1/;
	s/privilege escalation/ut�kning av privilegier/;
	s/cross site/server�verskridande/;
	s/\bis not affected/p�verkas inte/;
	s/does not contain ([[:word:]]*) packages?/inneh�ller inte $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/inneh�ller inte n�gra $1-paket/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/inneh�ller inte n�got $1-paket/;
	s/this problem will be fixed soon/kommer detta problem r�ttas inom kort/;
	s/\(potato\)/(Potato)/;
	s/\(woody\)/(Woody)/;
	s/\(sarge\)/(Sarge)/;
	s/\(sid\)/(Sid)/;
	s/Refer to Debian (<.*>)?bug #([0-9]+)</Se Debians $1felrapport $2</;

	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
