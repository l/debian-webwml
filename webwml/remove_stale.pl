#!/usr/bin/perl

# This script searches through all the translation directories for HTML
# files not having a matching WML file, and removes those HTML files from
# both the local directory and the install directory. This is needed so that
# a removing a WML file from the repository causes the corresponding HTML file
# to go away.

# Originally written 2001-03-22 by Peter Krefting <peterk@debian.org>
# Revised in 2010 by Bas Zoetekouw <bas@debian.org>
# © Copyright 2001-2010 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

## $Id$

use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;
use File::Spec::Functions;
use File::Find;

use FindBin;
FindBin::again();
use lib "$FindBin::Bin/Perl";

use Webwml::Langs;
use Local::VCS 'vcs_file_info';


# directory where "make install" installs the website
use constant INSTALLDIR => '../www';

###############################################################
# "main"
{

	my %opts;
	show_help("Unknown option\n")     if not getopts('dh',\%opts);
	show_help()                       if exists $opts{'h'};
	show_help("Not in webwml root\n") if not -d 'english';

	my $reallyremove =  exists( $opts{'d'} );

	# Read the list of languages
	my @languages = sort Webwml::Langs->new()->names();

	# check all subdirs to find stale html files
	my @files;
	foreach my $language (@languages)
	{
		push @files, find_stale_files($language);
	}


	# remove or report the files
	foreach my $file (@files)
	{
		if ( $reallyremove )
		{
			remove_file( $file, \@languages );
		}
		else
		{
			report_file( $file, \@languages );
		}
	}

	my $numfiles = @files;
	print "\n$numfiles stale translations found.\n";
	print "Use -d option to remove files.\n"
		if @files and not $reallyremove;

	# Done.
	exit;
}


#############################################################
# show help text
sub show_help
{
	my $help = shift;

	print $help if $help;

	open(my $fd, '<:utf8', $0) or return;
	while (my $line = <$fd>)
	{
		next if $line =~ m/^#!/;
		next if $line =~ m/^##/;
		last if $line =~ /^[^#\s]/;

		chomp $line;
		$line =~ s/^#\s+//;

		print $line, "\n";
	}
	close($fd);

	print "Run this script from the webwml directory to remove stale HTML files.\n\n";
	print "Usage: $0 [-d]\n\n";
	print "  -d  Remove files, just not report.\n";

	exit defined($help) ? 1 : 0;
}

#############################################################
# Find the stale html files in the specified directory
sub find_stale_files
{
	# Get parameter.
	my $dir       = shift or die('No directory specified');

	print "Recursing into `$dir'\n";

	# the language subdir possibly doesn't exist yet for newly 
	# started translations
	return 0  unless  -d $dir;

	# create a list of *.html files and a hash of *.wml files in this translation
	#my (%wmlfiles,@htmlfiles);
	#find( sub { $wmlfiles{$File::Find::name}++     if -f and /\.wml$/  }, $dir );
	#find( sub { push @htmlfiles, $File::Find::name if -f and /\.html$/ }, $dir );

	my @htmlfiles =                 find_files_ext( $dir, 'html' );
	my %wmlfiles  = map { $_ => 1 } find_files_ext( $dir, 'wml' );

	# Locate all HTML files, and find out which ones do not correspond
	# to a WML file, and does not live in the CVS by itself.
	my @toremove;
	foreach my $htmlfile (sort @htmlfiles)
	{
		# the name of the wml file that this html file is potentially
		# generated from
		my $source = $htmlfile;
		$source =~ s/(?:\.[-\w]+)?\.html$/.wml/  
			or die("Can't determine WML source file for `$htmlfile'");

		# Don't try to do anything in subdirectories of l10n.
		next  if  $htmlfile =~ m{/international/l10n/po[-\w]*/[\w_\@]+\.[-\w]+\.html$};
		
		# Don't try to do anything in stats either.
		next  if  $htmlfile =~ m{/devel/website/stats/[-\w]+\.[-\w]+\.html$};

		# Don't try to remove yaboot-howto.
		next  if  $htmlfile =~ m{/ports/powerpc/inst/yaboot-howto.html};

		# does the wml source file exist?
		my $haswml = exists( $wmlfiles{$source} ) || -f $source || 0;

		# is the html file checked in the VCS?
		my $checkedin = vcs_file_info($htmlfile , quiet => 1 ) ? 1 : 0;

		#if ($checkedin) 
		#{ print "==> `$htmlfile' : `$source' : $haswml : $checkedin\n"; }

		# we're done if the file has a corresponding wml source, or if the html
		# file itself is checked in
		next  if  $haswml or $checkedin;

		# as a special exception, sitemaps don't have a wml source in the
		# translation tree (they are generated from english/)
		next  if  $htmlfile =~ m{/sitemap\.[-\w]+\.html$};

		# File has no reason for being here.
		push @toremove, $htmlfile;
	}

	return @toremove;
}

#############################################################
# returns a list of filenames with the given extension
sub find_files_ext
{
	my $dir = shift or die('Internal error: No dir specified');
	my $ext = shift or die('Internal error: No ext specified');

	my @files;
    find( sub { push @files, $File::Find::name if -f and m/\.$ext$/ }, $dir );
	return @files;
}

#############################################################
# get the filenames of files related to the given htmlfile
sub gather_file_info 
{
	my $htmlfile  = shift or die('Internal error: No htmlfile specified');
	my $languages = shift or die('Internal error: No languages specified');

	die("Not an html file: `$htmlfile'\n") unless $htmlfile =~ m/\.html$/;

	my $wmlsrc = $htmlfile;
	$wmlsrc =~ s{\.[-\w]+\.html$}{.wml};
	die("No valid wml source for `$htmlfile' could be constructed\n")
		if $wmlsrc eq $htmlfile;

	# Name of file installed by make install.
	my $installed = $htmlfile;
	$installed =~ s{^[^/]+/}{}; # remove "dutch/" at the beginning
	$installed = catfile(INSTALLDIR,$installed);

	# Name of corresponding ICS file for events.
	my $icslocal = $htmlfile;
	$icslocal =~ s/html$/ics/;
	my $icsinstalled = $installed;
	$icsinstalled =~ s/html$/ics/;

	# Extra symlinks for languages
	my $extra = $installed;
	$extra =~ s/\.no\.html$/.nb.html/  or  $extra = '';
	#what about en-us and en-gb ?

	# Check for translations to other languages, they
	# need to have their .wml file touched
	my @translations = findtranslations($wmlsrc,$languages);

	return ($wmlsrc,$installed,$icslocal,$icsinstalled,$extra,@translations);
}

#############################################################
# remove the given html file and all files related to it
sub remove_file
{
	my $htmlfile  = shift or die('Internal error: No htmlfile specified');
	my $languages = shift or die('Internal error: No languages specified');

	my ($wmlsrc,$installed,$icslocal,$icsinstalled,$extra,@translations) 
		= gather_file_info( $htmlfile, $languages );

	if (-f $extra or -l $extra)
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
	if (@translations)
	{
		utime(undef,undef,@translations)
			or warn "touch: error code $?";
	}

	print "Removing $htmlfile\n";
	unlink $htmlfile
		or die "Unable to remove $htmlfile: $!\n";

}

#############################################################
# report files that would be removed
sub report_file 
{
	my $htmlfile  = shift or die('Internal error: No htmlfile specified');
	my $languages = shift or die('Internal error: No languages specified');

	my ($wmlsrc,$installed,$icslocal,$icsinstalled,$extra,@translations) 
		= gather_file_info( $htmlfile, $languages );

	print "$htmlfile is stale\n";
	print "  installed file is $installed";
	print "  (does not exist)"  unless  -f $installed;
	print "\n";
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

#############################################################
# Locate all translated copies of this wml file
sub findtranslations
{
	my $wml       = shift or die('Internal error: no wml file specified');
	my $languages = shift or die('Internal error: no languages specified');

	my @files;

	# Remove the first component of the path (which contains the
	# current language)
	my $tail = $wml;
	$tail =~ s{^[^/]+/}{};

	# Locate all translated copies
	foreach my $language (@$languages)
	{
		my $translated = "$language/$tail";
		push @files, $translated   if  -f $translated;
	}

	return @files;
}

__END__
