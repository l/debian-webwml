#!/usr/bin/perl -w

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
# There are no command line parameters.

# Originally written 2002-10-05 by Peter Karlsson <peterk@debian.org>
# © Copyright 2002-2007 Software in the public interest, Inc.
# This program is released under the GNU General Public License, v2.

# $Id$

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

die "Language not defined in DWWW_LANG or language.conf\n"
	unless defined $language;

# Counters
$old = 0;
$uptodate = 0;
$unknown = 0;
$needtranslation = 0;

# Start-up
$directory = 'MailingLists/desc';
&process($directory);

# Results
print $needtranslation, " need to be translated.\n" if $needtranslation;
print $old, " need to be updated.\n" if $old;
print $uptodate, " are up to date.\n" if $uptodate;
print $unknown, " are orphaned.\n" if $unknown;

sub process
{
    my $curdir = shift;
    my $source = 'english/' . $curdir;
    my $destination = $language . '/' . $curdir;

    my %sourcefile;
    my @subdirs;

    print "Checking $curdir\n";

    # Read the Entries file for the source directory
    open CVS, $source . '/CVS/Entries'
        or die "Cannot read $source/CVS/Entries: $!\n";

    while (<CVS>)
    {
    	next if /README/;
		if (m[^/([^/]+)/([0-9\.]+)/])
        {
            $sourcefile{$1} = $2;
        }
		elsif (m[^D/([^/]+)/])
        {
            push @subdirs, $1;
        }
    }
    close CVS;

    # Read the translation-check file for the destination directory
    if (open CHECK, $destination . '/translation-check')
    {
        # Get data for the entries and compare
        while (<CHECK>)
        {
            if (/^([^\s]+)\s*([0-9\.]+)$/)
            {
            	print "Ghost entry $destination/$1\n"
            		unless -f "$destination/$1";
                if (defined $sourcefile{$1})
                {
                    my ($file, $oldrev, $newrev) = ($1, $2, $sourcefile{$1});
                    if ($oldrev ne $newrev)
                    {
                        $old ++;
                        print "Need to update $destination/$file from ",
                              $oldrev, " to ", $newrev, "\n";
                    }
                    else
                    {
                        $uptodate ++;
                    }
		            delete $sourcefile{$1};
                }
                else
                {
                    print "Unknown translated file: $destination/$1\n";
                    $unknown ++;
                }
            }
        }
        foreach $untranslated (keys %sourcefile)
        {
        	print "Untranslated file: $destination/$untranslated ",
        	      $sourcefile{$untranslated}, "\n";
            $needtranslation ++;
        }
    }
    else
    {
        warn "Cannot read $destination/translation-check: $!\nDirectory skipped\n";
    }


    # Process subdirs
    foreach $subdir (@subdirs)
    {
        &process($curdir . '/' . $subdir);
    }
}
