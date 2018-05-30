#!/usr/bin/perl -w

# This script copies the file named on the command line to the translation
# named in language.conf, and adds the translation-check header to it.
# It also will create the destination directory if necessary, and create the
# Makefile.  It will do this by simply including the English version -- copied
# Makefiles are not supported anymore for they bear too much space for errors.

# Originally written 2000-02-26 by Peter Krefting <peterk@debian.org>
#
# Modified by Javier Fernandez-Sanguino <jfs@debian.org> to support CVS
# status of files in order to detect removed files or out-of-date CVS copies
#
# © Copyright 2000-2008 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use FindBin;
FindBin::again();
use lib "$FindBin::Bin/Perl";

use File::Path;
use Local::VCS;
use File::Temp qw/tempfile/;
use Getopt::Std;

# Get configuration
# Read first two valid lines from language.conf
if (open CONF, "<language.conf")
{
	while (<CONF>)
	{
		next if /^#/;
		chomp;
		$language = $_, next unless defined $language;
		$maintainer = $_, next unless defined $maintainer;
	}
	close CONF;
}
else
{
	warn "Unable to open language.conf. Using environment variables...\n";
}

# Values are overwritten by environment variables
if (exists $ENV{DWWW_LANG})
{
	$language = $ENV{DWWW_LANG};
}
if (exists $ENV{DWWW_MAINT})
{
	$maintainer = $ENV{DWWW_MAINT};
}

my $VCS = Local::VCS->new();

# Options
our ($opt_n, $opt_t, $opt_l);
getopts('nm:l:'); 

# Values overwritten by commandline
if (defined $opt_m)
{
        $maintainer = $opt_m;
}
if (defined $opt_l)
{
        $language = $opt_l;
}

# Check usage.
if ($#ARGV == -1)
{
	print "Usage: $0 [-n] [-l language] [-m maintainer] page ...\n\n";
	print "Copies the page from the english/ directory to the $language/ directory\n";
	print "and adds the translation-check header with the current revision,\n";
	print "optionally adds also the maintainer name.\n";
	print "If the directory does not exist, it will be created, and the Makefile\n";
	print "copied or created, depending on the setting of your language.conf file.\n\n";
	print "The 'english/' part of the input path is optional.\n\n";
        print "If the file already exists in the $language/ repository either\n";
        print "because it was removed (and is in the Attic) or has been removed\n";
        print "locally the program will abort and warn the user (unless '-n' is used)\n";
        print "Environment variables:\n";
        print "\tDWWW_LANG\tSets the language for the translation\n";
        print "\t\t(overwrites language.conf definition\n";
        print "\tDWWW_MAINT\tSets maintainer for the translation\n";
        print "Options:\n";
        print "\t-m\tSets the maintainer for the translation (overwrites environment)\n";
        print "\t-l\tSets the language for the translation (overwrites environment)\n";
        print "\n";

}

die "Language not defined in DWWW_LANG or language.conf\n"
	if not defined $language;

#warn "Maintainer name not defined in DWWW_MAINT or language.conf\n"
#	if not defined $maintainer;

# Loop over command line
foreach $page (@ARGV)
{
	# Check if valid source
	if ($page =~ /wml$/ || $page =~ /src$/)
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

	my $srcmake = $srcdir . "Makefile";	# Name of source Makefile
	my $dstmake = $dstdir . "Makefile";	# Name of destination Makefile

	my $dsttitle = $dstfile;
	$dsttitle =~ s/\.wml$/.title/;		# Name of possible title translation

	# Sanity checks
	die "Directory $srcdir does not exist\n" unless -d $srcdir;
	die "File $srcfile does not exist\n"     unless -e $srcfile;
	if (-e $dstfile)
	{
		warn "File $dstfile already exists\n";
		return;
	}

	# Check if destination exists, if not - create it
	unless (-d $dstdir)
	{
		print "Destination directory $dstdir does not exist,\n";

		mkpath([$dstdir],0,0755)
			or die "Could not create $dstdir: $!\n";
	}
	if ( -e $srcmake && ! -e $dstmake )
	{
		print "creating it and making a $dstmake\n";
		open MK, ">", "$dstmake"
			or die "Could not create $dstmake: $!\n";
		print MK "include \$(subst webwml/$language,webwml/english,\$(CURDIR))/Makefile\n";
		close MK;
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

	# Retrieve VCS revision number
	my %vcsinfo = $VCS->file_info( $srcfile );

	if ( not %vcsinfo  or  not exists $vcsinfo{'cmt_rev'}  )
	{
		die "Could not get revision number for `$srcfile' - bug in script?\n";
	}

	# Open the files
	open SRC, $srcfile
		or die "Could not read $srcfile ($!)\n";

	open DST, ">$dstfile"
		or die "Could not create $dstfile ($!)\n";

	# Copy the file and insert the revision number
	my $insertedrevision = 0;

	while (<SRC>)
	{
		next if /\$Id/;

		unless ($insertedrevision || /^#/)
		{
			printf DST qq'#use wml::debian::translation-check translation="%s"', $vcsinfo{'cmt_rev'};
			print DST qq' maintainer="$maintainer"'
				if defined $maintainer;
			print DST qq'\n';
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
	}

	unless ($insertedrevision)
	{
		printf DST qq'#use wml::debian::translation-check translation="%s"', $vcsinfo{'cmt_rev'};
		print DST qq' maintainer="$maintainer"'
			if defined $maintainer;
		print DST qq'\n';
	}

	close SRC;
	close DST;

	# We're done
	print "Copied $page, remember to edit $dstfile\n";
	print "and to remove $dsttitle when finished\n"
		if defined $dsttitle;
}
