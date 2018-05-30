#!/usr/bin/perl

# Check translation status for mailing list descriptions. Since these files
# aren't WML files, the translation data is stored in a separate file in
# each directory, listing the names of the files and the corresponding
# English version.
#
# Since I couldn't figure out how to add this to the regular check_trans.pl
# script, this is a separate script.
#
# To use this script, create a file called translation-check in each
# directory under <language>/MailingLists/desc/. In it you list the name of
# the translated file and the version of the English original, separated by
# whitespace. Then run this script, and it will tell you about which files
# are missing, which files are outdated, and if there are files translating
# files that are no longer in the English directory.
#
# The language to check can be specified on the command line, in 
# language.conf, or in the DWWW_LANG environment variable.
#
# Originally written 2002-10-05 by Peter Karlsson <peterk@debian.org>
# © Copyright 2002-2007 Software in the public interest, Inc.
# Complete rewrite 2008 by Bas Zoetekouw <bas@debian.org>
# © Copyright 2008 by Bas Zoetekouw <bas@debian.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#

# $Id$

use FindBin;
use lib "$FindBin::Bin/Perl";

use File::Basename;
use File::Spec::Functions;
use File::Find::Rule;
use Term::ANSIColor;

use Local::VCS  ':all';
use Local::Util 'uniq';

use strict;
use warnings;

# see if -c was specified 
if ( $ARGV[0] eq '-c' )
{
	shift @ARGV;
	$ENV{'ANSI_COLORS_DISABLED'} = '1';
}

# Get language configuration
my $language;
if ( $ARGV[0] )
{
	$language = $ARGV[0];
}
elsif (exists $ENV{DWWW_LANG}) 
{
	$language = $ENV{DWWW_LANG};
} 
elsif ( open( my $conf, '<', 'language.conf' ) )
{
	while ( my $line  = <$conf> )
	{
		next if $line =~ /^#/;
		chomp $line ;
		$language = $line;
		last;
	}

	close $conf;
}

die "Language not defined in DWWW_LANG or language.conf\n"
	unless defined $language;
die "Language `$language' doesn't exist\n"
	unless -d $language;

# Counters
my $old = 0;
my $uptodate = 0;
my $unknown = 0;
my $needtranslation = 0;

# directories
my $directory = catdir( 'MailingLists' , 'desc' );
my $srcdir    = catdir( 'english', $directory );
my $destdir   = catdir( $language, $directory );

my $VCS = Local::VCS->new();

# read VCS info about files in source dir
my %revision_info = $VCS->path_info( $srcdir, 'recursive' => 1 );

# read the translation-check files in dest dir
my %transcheck = read_transcheck( $destdir );

# check all files
my ($nr_uptodate,$nr_old,$nr_needtrans,$nr_obsolete,$nr_error) = 
	check_all( $VCS, $language, $directory, \%transcheck, \%revision_info );

# print results
print "\nResults:\n";
printf "  %3i are up to date.\n",        $nr_uptodate;
printf "  %3i need to be updated.\n",    $nr_old;
printf "  %3i need to be translated.\n", $nr_needtrans;
printf "  %3i are obsolete.\n",          $nr_obsolete;
printf "  %3i are broken.\n",            $nr_error;

exit 0;


#============================================================


# read in all transcheck files under the specified directory
sub read_transcheck
{
	my $dir = shift  or  die("No directory specified");

	# get a listof all translation-check files
	my @files = File::Find::Rule->file()->name('translation-check')->in($dir);

	my %info;
	foreach my $file (@files)
	{
		my $thisdir = dirname $file;

		# TODO: use a nice File::Spec function for this
		$thisdir =~ s{^$dir/*}{} ;

		open( my $fd, '<', $file ) or die("Can't open `$file': $!\n");
		while ( my $line = <$fd> )
		{
			chomp $line;

			# skip comments and empty lines
			next if $line =~ m{^#};
			next if $line =~ m{^\s+$};

			# read the file name and the revision from the file
			my ($listfile,$revision) = split( /\s+/, $line, 2 );
			warn "Couldn't parse line $. of $file\n" unless $revision;

			# prepend the directory name, if needed
			my $thefile = $thisdir ? catfile( $thisdir, $listfile ) : $listfile;

			# save the data 
			$info{ $thefile } = $revision;
		}
		close( $fd );
	}

	return %info;

}


# check all translations
sub check_all
{
	my $VCS     = shift;
	my $lang    = shift  or  die("No language specified");
	my $dir     = shift  or  die("No directory specified");
	my $files   = shift  or  die("No transcheck files specified");
	my $revinfo = shift  or  die("No revision info specified");

	die("Language `$lang' doesn't exists\n") unless -d $lang;

	my $source      = catdir( 'english', $dir );
	my $destination = catdir( $lang,     $dir );

	# create a list of all files (note that the filenames are relative to the
	# english and translated mailinglist directories)
	my @allfiles = sort {$a cmp $b} uniq( keys %$files, keys %$revinfo );

	# counters
	my ($nr_uptodate,$nr_old,$nr_obsolete,$nr_needtrans,$nr_error) = (0,0,0,0,0);

	foreach my $file ( @allfiles )
	{
		# special case, this doesn't need to be translated
		next if $file eq 'README';

		my $file_english = catfile( 'english', $dir, $file );
		my $file_transl  = catfile( $lang,     $dir, $file );

		# check if the info from vcs and from the fs are consistent
		if ( -e $file_english  and  not exists $revinfo->{$file} )
		{
			warn "$file_english: english version found, but no revision info available!\n";
			next;
		}
		# check if the info from translation-check and from the fs are consistent
		if ( -e $file_transl  and  not exists $files->{$file} )
		{
			warn "$file_transl: $lang version found, but not found in a translation-check file!\n";
			next;
		}

		# now check for out-of-dateness and other things
		if ( -e $file_english and -e $file_transl )
		{
			# needs update
			if ( $VCS->cmp_rev( $file_english, $files->{$file}, $revinfo->{$file}->{'cmt_rev'} ) == -1 )
			{
				$nr_old++;
				print color('blue'), $file_transl, color('reset');
				printf ": needs to be updated from revision %s to revison %s\n", 
					$files->{$file}, $revinfo->{$file}->{'cmt_rev'};
			}
			# translated file is too new
			elsif ( $VCS->cmp_rev( $file_english, $files->{$file}, $revinfo->{$file}->{'cmt_rev'} ) == -1 )
			{
				$nr_error++;
				print color('blue'), $file_transl, color('reset');
				printf ": %s revision %s is larger than english revision %s\n",
					$lang, $files->{$file}, $revinfo->{$file}->{'cmt_rev'};
			}
			# up to date!
			else
			{
				$nr_uptodate++;
			}
		}
		# file not translated yet
		elsif ( -e $file_english )
		{
			$nr_needtrans++;
			print color('blue'), $file_transl, color('reset');
			printf ": need to translate revision %s\n", $revinfo->{$file}->{'cmt_rev'};
		}
		# translation exists, but original has been removed
		elsif ( -e $file_transl )
		{
			$nr_obsolete++;
			print color('blue'), $file_transl, color('reset');
			print ": no english file found!\n";
		}
		# weirdness
		else
		{
			$nr_error++;
			print color('blue'), $file, color('reset');
			print ": Woopsie, neither english nor $lang file found\n";
			next;
		}
	}

	return ($nr_uptodate,$nr_old,$nr_needtrans,$nr_obsolete,$nr_error);
}


__END__
