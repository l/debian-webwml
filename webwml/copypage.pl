#!/usr/bin/perl -w

# This script copies the file named on the command line to the translation
# named in copypage.conf, and adds the <!--translation x.x--> string to it.
# It also will create the destination directory if necessary, and copy the
# Makefile from the source.

# Written on 2000-02-26 by peter karlsson <peter@softwolves.pp.se>
# © Copyright 2000 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

# Get command line and configuration
$page = $ARGV[0];

if (open CONF, "<language.conf")
{
	$language = <CONF>;
	chomp $language;
	close CONF;
}
else
{
	$language = 'swedish';
}

# Check usage.
unless ($page)
{
	print "Usage: $0 page\n";
	print "Copies the page from the english/ directory to the $language/ directory\n";
	print "and adds the  translation  string\n";
	print "If the directory does not exist, it will be created, and the Makefile\n";
	print "copied.\n";
	print "You can either keep or not keep the 'english/' part of the path.\n";
	exit;
}

# Check if valid source
unless ($page =~ /wml$/)
{
	print "$page does not seem to be a valid page.\n";
	exit;
}

# Remove english/ from path
if ($page =~ m[^english/])
{
	$page =~ s[^english/][];
}

# Create needed file and directory names
$srcfile = "english/$page";					# Source file path
$dstfile = "$language/$page";				# Destination file path

$srcdir =  $srcfile;
$srcdir =~ s[(.*/).*][$1];					# Source directory (trailing /)
$dstdir =  $dstfile;
$dstdir =~ s[(.*/).*][$1];					# Desination directory (trailing /)

$filename = $srcfile;
$filename =~ s[$srcdir][];					# Pathless filename

$cvsfile = "$srcdir/CVS/Entries";			# Name of file with CVS revisions

$srcmake = $srcdir . "Makefile";			# Name of source Makefile
$dstmake = $dstdir . "Makefile";			# Name of destination Makefile

# Sanity checks
die "Directory $srcdir does not exist\n" unless -d $srcdir;
die "File $srcfile does not exist\n"     unless -e $srcfile;

# Check if destination exists, if not - create it
unless (-d $dstdir)
{
	print "Destination directory $dstdir does not exist,\n";
	print "creating and copying	$dstmake\n";

	mkdir $dstdir, 0755
		or die "Could not create $dstdir: $!\n";
	system "cp $srcmake $dstmake";
}

# Open the files
open CVS, $cvsfile
	or die "Could not read $cvsfile ($!)\n";

open SRC, $srcfile
	or die "Could not read $srcfile ($!)\n";

open DST, ">$dstfile"
	or die "Could not create $dstfile ($!)\n";

# Retrieve CVS revision number
while (<CVS>)
{
	if (m[^/$filename/([0-9]*\.[0-9]*)/]o)
	{
		$revision = $1;
	}
}

close CVS;

unless ($revision)
{
	print "Could not get revision number - bug in script?\n";
	revision = '1.1';
}

# Copy the file and insert the revision number
$insertedrevision = 0;

while (<SRC>)
{
	unless ($insertedrevision || /^#/)
	{
		print DST "# <!--translation $revision-->\n";
		$insertedrevision = 1;
	}
	print DST $_;
}

close SRC;
close DST;

# We're done
print "Copying done, remember to edit $dstfile\n";
