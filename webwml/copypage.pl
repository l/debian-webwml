#!/usr/bin/perl -w

# This script copies the file named on the command line to the translation
# named in language.conf, and adds the translation-check header to it.
# It also will create the destination directory if necessary, and copy the
# Makefile from the source.

# Originally written 2000-02-26 by peter karlsson <peterk@debian.org>
# © Copyright 2000-2002 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use File::Path;

# Get configuration
if (exists $ENV{DWWW_LANG}) 
{
     $language = $ENV{DWWW_LANG};
} 
elsif (open CONF, "<language.conf")
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
if ($#ARGV == -1)
{
	print "Usage: $0 page ...\n\n";
	print "Copies the page from the english/ directory to the $language/ directory\n";
	print "and adds the translation-check header with the current revision.\n";
	print "If the directory does not exist, it will be created, and the Makefile\n";
	print "copied.\n\n";
	print "You can either keep or not keep the 'english/' part of the path.\n";
	exit;
}

# Loop over command line
foreach $page (@ARGV)
{
	# Check if valid source
	if ($page =~ /wml$/)
	{
		&copy($page);
	}
	else
	{
		print "$page does not seem to be a valid page.\n";
	}
}

# Subroutine to copy a page
sub copy
{
	my $page = shift;
	print "Processing $page...\n";

	# Remove english/ from path
	if ($page =~ m[^english/])
	{
		$page =~ s[^english/][];
	}

	# Create needed file and directory names
	my $srcfile = "english/$page";		# Source file path
	$dstfile = "$language/$page";		# Destination file path

	my $srcdir =  $srcfile;
	$srcdir =~ s[(.*/).*][$1];			# Source directory (trailing /)
	my $dstdir =  $dstfile;
	$dstdir =~ s[(.*/).*][$1];			# Desination directory (trailing /)

	my $filename = $srcfile;
	$filename =~ s[$srcdir][];			# Pathless filename

	my $cvsfile = "$srcdir/CVS/Entries";# Name of file with CVS revisions

	my $srcmake = $srcdir . "Makefile";	# Name of source Makefile
	my $dstmake = $dstdir . "Makefile";	# Name of destination Makefile

	my $dsttitle = $dstfile;
	$dsttitle =~ s/\.wml$/.title/;		# Name of possible title translation

	# Sanity checks
	die "Directory $srcdir does not exist\n" unless -d $srcdir;
	die "File $srcfile does not exist\n"     unless -e $srcfile;
	die "File $dstfile already exists\n"     if     -e $dstfile;

	# Check if destination exists, if not - create it
	unless (-d $dstdir)
	{
		print "Destination directory $dstdir does not exist,\n";

		mkpath([$dstdir],0,0755)
			or die "Could not create $dstdir: $!\n";
		if ( -e $srcmake ) {
		     print "creating and copying	$dstmake\n";
		     system "cp $srcmake $dstmake";
		}
	}

	# Check if title translation exists, if so - load it
	my $pagetitle;
	if (-e $dsttitle)
	{
		open TTL, $dsttitle
			or die "Could not read $dsttitle ($!)\n";

		# Scan for title;
		while (<TTL>)
		{
			$pagetitle = $_, last
				if /^<define-tag pagetitle>/;
		}

		close TTL;
	}
	else
	{
		undef $dsttitle;
	}

	# Open the files
	open CVS, $cvsfile
		or die "Could not read $cvsfile ($!)\n";

	open SRC, $srcfile
		or die "Could not read $srcfile ($!)\n";

	open DST, ">$dstfile"
		or die "Could not create $dstfile ($!)\n";

	# Retrieve CVS revision number
	my $revision;
	while (<CVS>)
	{
		if (m[^/$filename/([0-9]*\.[0-9]*)/])
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
	my $insertedrevision = 0;
	my $isdefinetag = 0;
	my $ignorews = 0;

	while (<SRC>)
	{
		next if /\$Id/;

		$isdefinetag = 1 if /<define-tag/;
		$ignorews = 1 if $isdefinetag;

		unless ($insertedrevision || /^#/ || $isdefinetag ||
		        ($ignorews && /^$/))
		{
			print DST qq'#use wml::debian::translation-check translation="$revision"\n';
			$insertedrevision = 1;
		}
		if (defined $pagetitle && /^<define-tag pagetitle>/)
		{
			print DST $pagetitle;
		}
		else
		{
			print DST $_;
		}

		$isdefinetag = 0 if m'</define-tag>';
		$ignorews = 0 if /^#/;
	}

	unless ($insertedrevision)
	{
		print DST qq'#use wml::debian::translation-check translation="$revision"\n';
	}

	close SRC;
	close DST;

	# We're done
	print "Copied $page, remember to edit $dstfile\n";
	print "and to remove $dsttitle when finished\n"
		if defined $dsttitle;
}

