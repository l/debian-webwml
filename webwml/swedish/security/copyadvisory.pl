#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000-2002 by Peter Karlsson <peterk@debian.org>
# � Copyright 2000-2002 Software in the public interest, Inc.
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
$year = 2002;
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

	s/We recommend that you upgrade your (.*) package immediately/Vi rekommenderar att ni uppgraderar ert $1-paket omedelbart/;
	s/We recommend that you upgrade your (.*) packages immediately/Vi rekommenderar att ni uppgraderar era $1-paket omedelbart/;
	s/We recommend that you upgrade your (.*) packages/Vi rekommenderar att ni uppgraderar era $1-paket/;
	s/We recommend that you upgrade your (.*) package/Vi rekommenderar att ni uppgraderar ert $1-paket/;
	s/buffer overflows?/buffertspill/;
	s/integer overflow/heltalsspill/;
	s/format string vulnerability/formatstr�ngss�rbarhet/;
	s/format string vulnerabilities/formatstr�ngss�rbarheter/;
	s/insecure temporary files/os�kra tempor�ra filer/;
	s/This problem has been fixed/Detta problem har r�ttats/;
	s/These problems have been fixed/Dessa problem har r�ttats/;
	s/\bin version\b/i version/;
	s/>local root exploit</>lokal rootattack</;
	s/>remote root exploit</>fj�rr-rootattack</;
	s/>symlink attack</>attack mot symboliska l�nkar</;
	s/>remote exploit</>fj�rrattack</;
	s/This has been fixed in version/Detta har r�ttats i version/;
	s/of the Debian package/av Debianpaketet/;
	s/upstream version/uppstr�msversion/;
	s/for the old stable distribution/f�r den gamla stabila utg�van/;
	s/for the old stable/f�r den gamla stabila/;
	s/for the current stable distribution/f�r den nuvarande stabila utg�van/;
	s/for the current stable/f�r den nuvarande stabila/;
	s/for the unstable distribution/f�r den instabila utg�van/;
	s/for the unstable/f�r den instabila/;
	s/current stable distribution/nuvarande stabila utg�van/;
	s/unstable distribution/instabila utg�van/;
	s/The old stable distribution/Den gamla stabila utg�van/;
	s/^stable distribution/stabila utg�van/;
	s/^unstable distribution/instabila utg�van/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/inneh�ller inte n�got $1-paket/;
	s/distribution (\(potato|woody|sarge\))/utg�van $1/;
	s/privilege escalation/ut�kning av privilegier/;
	s/cross site/server�verskridande/;

	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
