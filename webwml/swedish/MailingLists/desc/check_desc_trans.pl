#!/usr/bin/perl -w
#
# Check translation status for mailing list descriptions. Since these files
# aren't WML files, the translation data is stored in a separate file in
# each directory, listing the names of the files and the corresponding
# English version.
#
# Since I couldn't figure out how to add this to the regular check_trans.pl
# script, this is a separate script.
#
# The script MUST be called from the top-level webwml directory!
# There are no command line parameters.

die "Must be callede from the top-level directory!\n"
    unless -e 'swedish/MailingLists/desc/check_desc_trans.pl';

# Load configuration
open CONF, '<language.conf' or die "Cannot read language.conf: $!\n";
$language = <CONF>;
chomp $language;
close CONF;

# Counter
$old = 0;
$uptodate = 0;
$unknown = 0;

# Start-up
$directory = 'MailingLists/desc';
&process($directory);

# Results
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
            if (/^(.+)\t([0-9\.]+)$/)
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
