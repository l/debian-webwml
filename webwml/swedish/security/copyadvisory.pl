#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000-2002 by peter karlsson <peter@softwolves.pp.se>
# © Copyright 2000-2002 Software in the public interest, Inc.
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

# Copy the file and insert the revision number
$insertedrevision = 0;

while (<SRC>)
{
	next if /\$Id/;

	if (/^#use wml::debian::security/)
	{
		print DST $_;
		print DST qq'#use wml::debian::translation-check translation="$revision" mindelta="1"\n';
		$insertedrevision = 1;
	}
	else
	{
		s/<h4>Source:/<h4>Källkod:/;
        s/<h4>Source archives:/<h4>Källkodsarkiv:/;
        s/ architecture:</</;
		s/<h4>Architech?ture-independent component:/<h4>Arkitekturoberoende arkiv:/;
		s/We recommend that you upgrade your (.*) package immediately/Vi rekommenderar att ni uppgraderar era $1-paket omedelbart/;
		s/We recommend that you upgrade your (.*) packages immediately/Vi rekommenderar att ni uppgraderar ert $1-paket omedelbart/;
		s/We recommend that you upgrade your (.*) packages/Vi rekommenderar att ni uppgraderar era $1-paket/;
		s/We recommend that you upgrade your (.*) package/Vi rekommenderar att ni uppgraderar ert $1-paket/;
		s/buffer overflows?/buffertspill/;
		s/format string vulnerability/formatsträngssårbarhet/;
		s/This problem has been fixed/Detta problem har rättats/;
		s/>local root exploit</>lokal rootattack</;
		s/>remote root exploit</>fjärr-rootattack</;
		s/>symlink attack</>attack mot symboliska länkar</;
		s/>remote exploit</>fjärrattack</;
		print DST $_;
	}
}

unless ($insertedrevision)
{
	print DST qq'#use wml::debian::translation-check translation="$revision" mindelta="1"\n';
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
