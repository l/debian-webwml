#!/usr/bin/perl -w

# This script copies the file named on the command line to the translation
# named in language.conf, and adds the translation-check header to it.
# It also will create the destination directory if necessary, and create the
# Makefile.  It will do this by simply including the English version -- copied
# Makefiles are not supported anymore for they bear too much space for errors.

# Originally written 2000-02-26 by Peter Karlsson <peterk@debian.org>
# � Copyright 2000-2002 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use File::Path;

# Declare variables only used in references to avoid warnings
use vars qw(@iso_8859_2_compat  @iso_8859_3_compat  @iso_8859_4_compat
            @iso_8859_5_compat  @iso_8859_6_compat  @iso_8859_7_compat
            @iso_8859_8_compat  @iso_8859_9_compat  @iso_8859_10_compat
            @iso_8859_13_compat @iso_8859_14_compat @iso_8859_15_compat
            @iso_8859_16_compat);

# Get configuration
if (exists $ENV{DWWW_LANG}) 
{
     $language = $ENV{DWWW_LANG};
} 
elsif (open CONF, "<language.conf")
{
	while (<CONF>)
	{
		next if /^#/;
		chomp;
		$language = $_, next unless defined $language;
	}
}
else
{
	die "Language not defined in DWWW_LANG or language.conf\n";
}

# Check usage.
if ($#ARGV == -1)
{
	print "Usage: $0 page ...\n\n";
	print "Copies the page from the english/ directory to the $language/ directory\n";
	print "and adds the translation-check header with the current revision.\n";
	print "If the directory does not exist, it will be created, and the Makefile\n";
	print "copied or created, depending on your language.conf setting.\n\n";
	print "The 'english/' part of the input path is optional.\n";
	exit;
}

# Table of entities used when copying to non-latin1 encodings
@entities = (
	'&nbsp;', '&iexcl;', '&cent;', '&pound;', '&curren;', '&yen;',
	'&brvbar;', '&sect;', '&uml;', '&copy;', '&ordf;', '&laquo;', '&not;',
	'&shy;', '&reg;', '&macr;', '&deg;', '&plusmn;', '&sup2;', '&sup3;',
	'&acute;', '&micro;', '&para;', '&middot;', '&cedil;', '&sup1;',
	'&ordm;', '&raquo;', '&frac14;', '&frac12;', '&frac34;', '&iquest;',
	'&Agrave;', '&Aacute;', '&Acirc;', '&Atilde;', '&Auml;', '&Aring;',
	'&AElig;', '&Ccedil;', '&Egrave;', '&Eacute;', '&Ecirc;', '&Euml;',
	'&Igrave;', '&Iacute;', '&Icirc;', '&Iuml;', '&ETH;', '&Ntilde;',
	'&Ograve;', '&Oacute;', '&Ocirc;', '&Otilde;', '&Ouml;', '&times;',
	'&Oslash;', '&Ugrave;', '&Uacute;', '&Ucirc;', '&Uuml;', '&Yacute;',
	'&THORN;', '&szlig;', '&agrave;', '&aacute;', '&acirc;', '&atilde;',
	'&auml;', '&aring;', '&aelig;', '&ccedil;', '&egrave;', '&eacute;',
	'&ecirc;', '&euml;', '&igrave;', '&iacute;', '&icirc;', '&iuml;',
	'&eth;', '&ntilde;', '&ograve;', '&oacute;', '&ocirc;', '&otilde;',
	'&ouml;', '&divide;', '&oslash;', '&ugrave;', '&uacute;', '&ucirc;',
	'&uuml;', '&yacute;', '&thorn;', '&yuml;'
);

# Compatibility tables for the iso-8859 series; 1 indicates that the
# codepoint is the same as in iso-8859-1. Used to perform partial remaps
# for these.
@iso_8859_2_compat = (1,0,0,0,1,0,0,1,1,0,0,0,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,1,0,1,0,0,1,0,1,0,1,0,1,1,0,0,0,0,1,1,0,1,1,0,0,1,0,1,1,0,1,0,1,1,0,1,0,0,1,0,1,0,1,0,1,1,0,0,0,0,1,1,0,1,1,0,0,1,0,1,1,0,0);
@iso_8859_3_compat = (1,0,0,1,1,0,0,1,1,0,0,0,0,1,0,0,1,0,1,1,1,1,0,1,1,0,0,0,0,1,0,0,1,1,1,0,1,0,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,0,1,1,1,1,0,0,0);
@iso_8859_4_compat = (1,0,0,0,1,0,0,1,1,0,0,0,0,1,0,1,1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,0,1,0,1,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,0,0,1,0,1,1,1,1,1,1,0,0,1,0,1,0,1,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,0,0,0);
@iso_8859_5_compat = (1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
@iso_8859_6_compat = (1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
@iso_8859_7_compat = (1,0,0,1,0,0,1,1,1,1,0,1,1,1,0,0,1,1,1,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
@iso_8859_8_compat = (1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
@iso_8859_9_compat = (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1);
@iso_8859_10_compat =(1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,0,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0,1,0,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,1,1,1,1,1,0);
@iso_8859_13_compat =(1,0,1,1,1,0,1,1,0,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,0,1,0,1,1,1,1,0,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,1,0,0,1,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,1,0,0,0);
@iso_8859_14_compat =(1,0,0,1,0,0,0,1,0,1,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1);
@iso_8859_15_compat =(1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
@iso_8859_16_compat =(1,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,0,0,0,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,0,1,0,0,1,1,1,1,0,0,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,0,1,0,0,1,1,1,1,0,0,1);

# Check destination character encoding
my $recode = 0;
if (open WMLRC, "$language/.wmlrc")
{
	while (<WMLRC>)
	{
		if (s/^-D CHARSET=//)
		{
			$recode = 1 unless /^iso-8859-1$/i;
			if ($recode && /^iso-8859-([0-9]+)$/)
			{
				my $compattablename = 'iso_8859_' . $1 . '_compat';
				$compat = \@{$compattablename} if defined @{$compattablename};
			}
			last;
		}
	}
}

# Loop over command line
foreach $page (@ARGV)
{
	# Check if valid source
	if ($page =~ /wml$/)
	{
		&copy($page, $recode, $compat);
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
	my $recodelatin1 = shift;
	my $compattable = shift;
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
		if ( -e $srcmake )
		{
			print "creating it and making a $dstmake\n";
			open MK, "> $dstmake"
				or die "Could not create $dstmake: $!\n";
			print MK "include \$(subst webwml/$language,webwml/english,\$(CURDIR))/Makefile\n";
			close MK;
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

	while (<SRC>)
	{
		next if /\$Id/;

		unless ($insertedrevision || /^#/)
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
			if (defined $compattable)
			{
				# Recode non-ASCII characters that are not identical to
				# ISO 8859-1 into entitites
				s/([\xA0-\xFF])/$$compattable[ord($1)-160]?$1:$entities[ord($1)-160]/ge;
			}
			elsif ($recodelatin1)
			{
				# Recode any non-ASCII characters into entities
				s/([\xA0-\xFF])/$entities[ord($1)-160]/ge;
			}

			print DST $_;
		}
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
