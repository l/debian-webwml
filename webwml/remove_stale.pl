#!/usr/bin/perl -w

# This script searches through all the translation directories for HTML
# files not having a matching WML file, and removes those HTML files from
# both the local directory and the install directory. This is needed so that
# a removing a WML file from CVS causes the corresponding HTML file to go
# away.

# Written 2001-03-22 by peter karlsson <peterk@debian.org>
# � Copyright 2001 Software in the public interest, Inc.
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
&recurse('.');

# Done.
exit;

# The function that does the heavy work, recursing down the directory tree.
sub recurse
{
	# Get parameter.
	my $directory = shift;

	# Don't try to do anything in the WNPP and l10n directories.
	return if $directory =~ /wnpp$/ or $directory =~ /l10n$/;

	# Load all entries for this directory.
	opendir THISDIR, $directory
		or die "Unable to open directory $directory: $!\n";
	my @entries =
		map { $directory . '/' . $_ } grep { !/^\./ } readdir(THISDIR);
	closedir THISDIR;

	# Read through the CVS/Entries file.
	open ENTRIES, "$directory/CVS/Entries"
		or die "Not a CVS directory: $directory\n";

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
	my $direntry;
	foreach $direntry (@entries)
	{
		if (-f $direntry && $direntry =~ /\.html$/)
		{
			my ($haswml, $incvs) = (0, 0);

			# Check for WML file.
			my $source = $direntry;
			$source =~ s/\...(-..)?\.html$/.wml/;
			my $wmlfile;
			WMLS: foreach $wmlfile (@wmlfiles)
			{
				$haswml = 1, last WMLS
					if $wmlfile eq $source;
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

				# Name of file installed by make install.
				my $installed = $direntry;
				$installed =~ s(^\./[^/]*/)(../debian.org/);

				# Remove or report.
				if ($opt_d)
				{
					print "$direntry is stale ... removing\n";
					unlink $direntry
						or die "Unable to remove $direntry: $!\n";
					print "  also removing $installed\n";
					unlink $installed
						or die "Unable to remove $installed: $!\n";
				}
				else
				{
					print "$direntry is stale (use -d to remove)\n";
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
		recurse($subdir);
	}
}
