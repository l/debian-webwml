#!/usr/bin/perl -w

# This script searches through all the translation directories for HTML
# files not having a matching WML file, and removes those HTML files from
# both the local directory and the install directory. This is needed so that
# a removing a WML file from CVS causes the corresponding HTML file to go
# away.

# Originally written 2001-03-22 by Peter Karlsson <peterk@debian.org>
# © Copyright 2001-2002,2004 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

use strict;
use vars qw($opt_d);
use Getopt::Std;

unless (-d 'english' && getopts('d'))
{
	print "Usage: $0 [-d]\n\n";
	print "Run this script from the webwml directory to remove stale HTML files.\n\n";
	print "  -d  Remove files, just not report.\n";
	exit;
}

# Read the list of languages
my @languages = readlanguages('Makefile');

# Recurse.
my $files = 0;
foreach my $language (@languages)
{
	$files += &recurse("./$language");
}
$files ||= 'No';
print "\n$files stale translations found.\n";
print "Use -d option to remove files.\n"
	if $files ne 'No' && !$opt_d;

# Done.
exit;

# The function that does the heavy work, recursing down the directory tree.
sub recurse
{
	# Get parameter.
	my $directory = shift;

	# Don't try to do anything in l10n.
	return 0 if $directory =~ /l10n$/;

	# Load all entries for this directory.
	opendir THISDIR, $directory
		or die "Unable to open directory $directory: $!\n";
	my @entries =
		map { $directory . '/' . $_ } grep { !/^\./ } readdir(THISDIR);
	closedir THISDIR;

	# Read through the CVS/Entries file.
	if (!open ENTRIES, "$directory/CVS/Entries")
	{
		warn "Not a CVS directory, ignoring $directory\n";
		return 0;
	}

	my @wmlfiles = ();
	my @htmlfiles = ();
	while (<ENTRIES>)
	{
		if (m'^/([^/]+.wml)/[0-9\.]+/.*/.*/$')
		{
			push @wmlfiles, $directory . '/' . $1;
		}
		elsif (m'^/([^/]+.html)/[0-9\.]+/.*/.*/$')
		{
			push @htmlfiles, $directory . '/' . $1;
		}
	}

	# Locate all HTML files, and find out which ones do not correspond
	# to a WML file, and does not live in the CVS by itself.
	my @subdirs = ();
	my $count = 0;
	my $direntry;
	foreach $direntry (@entries)
	{
		# sitemap.??.html files should be ignored since they don't have a .wml
		# file, except in the english dir
		if (-f $direntry && $direntry =~ /\.html$/ && $direntry !~ /sitemap\..*\.html$/)
		{
			my ($haswml, $incvs) = (0, 0);

			# Check for WML file.
			my $source = $direntry;
			$source =~ s/\...(-..)?\.html$/.wml/;
			if ($source =~ /wml$/)
			{
				my $wmlfile;
				WMLS: foreach $wmlfile (@wmlfiles)
				{
					$haswml = 1, last WMLS
						if $wmlfile eq $source;
				}

				unless ($haswml)
				{
					# Check if WML file is in the directory, even if it is
					# not in the CVS (for auto-generated WML files).
					$haswml =1 if -f $source;
				}
			}

			unless ($haswml)
			{
				# Check if HTML file is in CVS by itself.
				my $htmlfile;
				HTMLS: foreach $htmlfile (@htmlfiles)
				{
					$incvs = 1, last HTMLS
						if $htmlfile eq $direntry;
				}
			}

			unless ($haswml || $incvs)
			{
				# File has no reason for being here.
				$count ++;

				# Name of file installed by make install.
				my $installed = $direntry;
				$installed =~ s(^\./[^/]*/)(../www/);

				# Name of corresponding ICS file for events.
				my $icslocal = $direntry;
				$icslocal =~ s/html$/ics/;
				my $icsinstalled = $installed;
				$icsinstalled =~ s/html$/ics/;

				# Extra symlinks for languages
				my $extra = $installed;
				$extra =~ s/\.no\.html$/.nb.html/;

				# Check for translations to other languages, they
				# need to have their .wml file touched
				my @translations = ();
				@translations = &findtranslations($source);

				# Remove or report.
				if ($opt_d)
				{
					if (-f $extra || -l $extra)
					{
						print "Removing $extra\n";
						unlink $extra
							or die "Unable to remove $extra: $!\n";
					}
					if (-f $installed)
					{
						print "Removing $installed\n";
						unlink $installed
							or die "Unable to remove $installed: $!\n";
					}
					if (-f $icsinstalled)
					{
						print "Removing $icsinstalled\n";
						unlink $icsinstalled
							or die "Unable to remove $icsinstalled: $!\n";
					}
					if (-f $icslocal)
					{
						print "Removing $icslocal\n";
						unlink $icslocal
							or die "Unable to remove $icslocal: $!\n";
					}

					# Touch translation sources to update the list of
					# translations on them
					foreach my $translation (@translations)
					{
						print "Touching $translation\n";
						system('/usr/bin/touch', $translation) == 0
							or warn "touch: error code $?";
					}

					print "Removing $direntry\n";
					unlink $direntry
						or die "Unable to remove $direntry: $!\n";
				}
				else
				{
					print "$direntry is stale\n";
					print "  installed file is $installed\n";
					print " (does not exist)\n"
						unless -f $installed;
					print "  and $extra\n"
						if (-f $extra || -l $extra) and $extra ne $installed;
					print "  installed ICS file: $icsinstalled\n"
						if -f $icsinstalled;
					print "  local ICS file: $icslocal\n"
						if -f $icslocal;
					foreach my $translation (@translations)
					{
						print "  translation in $translation\n";
					}
				}
			}
		}
		elsif (-d $direntry && !($direntry =~ /CVS$/))
		{
			push @subdirs, $direntry;
		}
	}

	# Recurse into subdirectories.
	my $subdir;
	foreach $subdir (@subdirs)
	{
		$count += recurse($subdir);
	}

	return $count;
}

# Read the list of active languages from the Makefile
sub readlanguages
{
	my $source = shift;
	my (@languages, $langsrc);
	open MAKE, '<', $source or die "Cannot read $source: $!\n";
	LANGUAGES: while (<MAKE>)
	{
		if (/LANGUAGES := (.*)/)
		{
			$langsrc = $1;
			while ($langsrc =~ /\\$/)
			{
				my $nextline = <MAKE>;
				chomp $nextline;
				$langsrc =~ s/\\$/$nextline/;
			}
		}
	}
	close MAKE;

	return split /\s+/, $langsrc;
}

# Locate all translated copies of this wml file
sub findtranslations
{
	my $wml = shift;
	my @files;

	# Remove the first component of the path (which contains the
	# current language)
	my $tail = $wml;
	$tail =~ s(^\./[^/]+/)();

	# Locte all translated copies
	foreach my $language (@languages)
	{
		my $translated = "./$language/$tail";
		push @files, $translated if -f $translated;
	}

	return @files;
}
