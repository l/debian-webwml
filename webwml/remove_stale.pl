#!/usr/bin/perl -w

# This script searches through all the translation directories for HTML
# files not having a matching WML file, and removes those HTML files from
# both the local directory and the install directory. This is needed so that
# a removing a WML file from CVS causes the corresponding HTML file to go
# away.

# Written 2001-03-22 by peter karlsson <peterk@debian.org>
# © Copyright 2001 Software in the public interest, Inc.
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

# Recurse.
my $files = &recurse('.') || 'No';
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

	# Don't try to do anything in the WNPP, l10n or intl/french directories.
	return 0 if $directory =~ /wnpp$/ or $directory =~ /l10n$/ or $directory =~ /ional\/french$/;

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

				# Remove or report.
				if ($opt_d)
				{
					if (-f $installed)
					{
						print "Removing $installed\n";
						unlink $installed
							or die "Unable to remove $installed: $!\n";
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
