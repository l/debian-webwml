#!/usr/bin/perl -w

# This script copies the file named on the command line to the translation
# named in language.conf, and adds the translation-check header to it.
# It also will create the destination directory if necessary, and copy the
# Makefile from the source. If the second line of the language.conf file
# contains the word "sync", a simple Makefile which just includes the English
# version will be created instead.

# Originally written 2000-02-26 by Peter Karlsson <peterk@debian.org>
# © Copyright 2000-2002 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use File::Path;

# Get configuration
$copymakefile = 1;
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
		$copymakefile = 1 if $_ eq 'copy';
		$copymakefile = 0 if $_ eq 'sync';
	}
}
else
{
	die "Language not defined in DWW_LANG or language.conf\n";
}

# Check usage.
if ($#ARGV == -1)
{
	print "Usage: $0 page ...\n\n";
	print "Copies the page from the english/ directory to the $language/ directory\n";
	print "and adds the translation-check header with the current revision.\n";
	print "If the directory does not exist, it will be created, and the Makefile\n";
	print "copied or created, depending on your language.conf setting.\n\n";
	print "You can either keep or not keep the 'english/' part of the path.\n";
	exit;
}

# Check destination character encoding
my $recode = 0;
if (open WMLRC, "$language/.wmlrc")
{
	while (<WMLRC>)
	{
		if (s/^-D CHARSET=//)
		{
			$recode = 1 unless /^iso-8859-15?$/i;
			last;
		}
	}
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

# Loop over command line
foreach $page (@ARGV)
{
	# Check if valid source
	if ($page =~ /wml$/)
	{
		&copy($page, $recode);
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
			if ($copymakefile)
			{
				print "creating it and copying $srcmake\n";
				system "cp $srcmake $dstmake";
			}
			else
			{
				print "creating it and making a $dstmake\n";
				open MK, "> $dstmake"
					or die "Could not create $dstmake: $!\n";
				print MK "include \$(subst webwml/$language,webwml/english,\$(CURDIR))/Makefile\n";
				close MK;
			}
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
			if ($recodelatin1)
			{
				# Recode any non-ASCII characters as entities
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
