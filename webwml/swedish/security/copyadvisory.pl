#!/usr/bin/perl -w

# This script copies a security advisory named on the command line, and adds
# the translation-check header to it. It also will create the
# destination directory if necessary, and copy the Makefile from the source.

# Written in 2000 by peter karlsson <peter@softwolves.pp.se>
# © Copyright 2000 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# Get command line
$date = $ARGV[0];

# Check usage.
unless ($date)
{
	print "Usage: $0 advisorydate\n\n";
	print "Copies the advisory from the English directory to the local one and adds\n";
	print "the translation-check header\n";
	exit;
}

# Create needed file and directory names
$year = substr($date, 0, 4);
$srcdir = "../../english/security/$year";
$srcfile= "$srcdir/$date.wml";
$cvsfile= "$srcdir/CVS/Entries";
$dstdir = "./$year";
$dstfile= "$dstdir/$date.wml";

# Sanity checks
die "Directory $srcdir does not exist\n" unless -d $srcdir;
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
	if (m[^/$date\.wml/([0-9]*\.[0-9])*/]o)
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
		s/<h4>Architechture-independent component:/<h4>Arkitekturoberoende arkiv:/;
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
