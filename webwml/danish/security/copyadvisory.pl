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

	s/^(<p>)?A problem has been discovered in\b/$1Et problem er opdaget i/;
	s/\bdiscovered a problem in\b/opdaget et problem i/;
	s/We recommend that you upgrade your (.*) package immediately/Vi anbefaler at du omg�ende opgraderer din $1-pakke/;
	s/We recommend that you upgrade your (.*) packages immediately/Vi anbefaler at du omg�ende opgraderer dine $1-pakker/;
        s/We recommend that you upgrade your (.*) and (.*) packages/Vi anbefaler at du opgraderer dine $1- og $2-pakker/;	
	s/We recommend that you upgrade your (.*) packages/Vi anbefaler at du opgraderer dine $1-pakker/;
	s/We recommend that you upgrade your (.*) package/Vi anbefaler at du opgraderer din $1-pakke/;
	s/We recommend that you update your (.*) package immediately/Vi anbefaler at du omg�ende opdaterer din $1-pakke/;
	s/We recommend that you update your (.*) packages immediately/Vi anbefaler at du omg�ende opdaterer dine $1-pakker/;
	s/We recommend that you update your (.*) packages/Vi anbefaler at du opdaterer dine $1-pakker/;
	s/We recommend that you update your (.*) package/Vi anbefaler at du opdaterer din $1-pakke/;
	s/buffer overflows?/bufferoverl�b/;
	s/integer overflow/heltalsoverl�b/;
	s/format string vulnerability/formatstrengss�rbarhed/;
	s/format string vulnerabilities/formatstrengss�rbarheder/;
	s/insecure temporary files/usiker midlertidige filer/;
	s/>insecure temporary file creation</>usikker oprettelse af fil</;
	s/>local root exploit</>lokal root-udnyttelse</;
	s/>remote root exploit</>fjern root-udnyttelse</;
	s/>symlink attack</>symbolsk l�nke-angreb</;
	s/>remote exploit</>fjernangreb</;
	s/>missing input sanitising</>manglende kontrol af inddata</;
	s/Several vulnerabilities/Flere s�rbarheder/;
	s/several vulnerabilities/flere s�rbarheder/;
	s/>several</>flere</;
	s/This has been fixed in version/Dette er rettet i version/;
	s/this problem has been fixed in/er dette problem rettet i/;
	s/this problem has been fixed$/er dette problem rettet/;
	s/this problem has(?: been)?$/er dette problem/;
	s/This problem has been fixed/Dette problem er rettet/;
	s/this problem is fixed in/er dette problem rettet i/;
	s/this problem is fixed/rettet dette problem/;
	s/These problems have been fixed/Disse problemer er rettet/;
	s/these problems have been fixed in/er disse problemer rettet i/;
	s/these problems have been fixed$/er disse problemer rettet/;
	s/these problems have(?: been)?$/er disse problemer/;
	s/these problem are fixed in/rettet disse problemer i/;
	s/these problem are fixed/rettet disse problemer/;
	s/these problems will be fixed soon/disse problemer vil snart blive rettet/;
	s/(?:been )?fixed in version/rettet i version/;
	s/\bin version\b/i version/;
	s/of the Debian package/af Debian-pakken/;
	s/upstream version/opstr�msversion/;
	s/([Ff])or the old stable distribution/I den gamle stabile distribution/;
	s/([Ff])or the old stable/I den gamle stabile/;
	s/([Ff])or the current stable distribution/I den nuv�rende stabile distribution/;
	s/([Ff])or the current stable/I den nuv�rende stabile/;
	s/([Ff])or the Debian stable distribution/I Debians stabile distribution/;
	s/([Ff])or the stable distribution/I den stabile distribution/;
	s/([Ff])or the stable/I den stabile/;
	s/([Ff])or the Debian unstable distribution/I Debians ustabile distribution/;
	s/([Ff])or the unstable distribution/I den ustabile distribution/;
	s/([Ff])or the unstable/I den ustabile/;
	s/current stable distribution/nuv�rende stabile distribution/;
	s/unstable distribution/ustabile distribution/;
	s/The old stable distribution/Den gamle stabile distribution/;
	s/^stable distribution/stabile distribution/;
	s/^unstable distribution/ustabile distribution/;
	s/does(?: not|n't) contain a(?:ny)? ([^ ]) package/indeholder ikke pakken $1/;
	s/distribution (\(potato|woody|sarge\))/distributionen $1/;
	s/privilege escalation/rettighedsfor�gelse/;
	s/cross site/p� tv�rs af servere/;
	s/\bis not affected/er ikke p�virket/;
	s/does not contain ([[:word:]]*) packages?/indeholder ikke pakker $1-pakker/;
	s/does not contain a(?:ny)? ([[:word:]]*) packages/indeholder ikke $1-pakker/;
	s/does not contain a(?:ny)? ([[:word:]]*) package/indeholder ikke pakken $1/;
	s/this problem will be fixed soon/vil dette problem snart blive rettet/;
	s/\(potato\)/(potato)/;
	s/\(woody\)/(woody)/;
	s/\(sarge\)/(sarge)/;
	s/\(sid\)/(sid)/;
	s/Refer to Debian (<.*>)?bug #([0-9]+)</Se Debians $1fejl nummer $2</;

	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
