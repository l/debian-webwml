#! /usr/bin/perl

# this script finds new files and touches old ones so that the list of
# languages at the bottom is updated to include the new file.
# or something like that. made by Joey.

%config = (
	   'wmldir'  => '/org/www.debian.org/webwml',
	   'datadir' => '/org/www.debian.org/cron/datafiles',
	   );

sub make_listing
{
    unlink ("$config{'datadir'}/wmlfiles.old") if (-f "$config{'datadir'}/wmlfiles.old");
    rename ("$config{'datadir'}/wmlfiles", "$config{'datadir'}/wmlfiles.old") if (-f "$config{'datadir'}/wmlfiles");
    system ("find . -type f -name '*.wml' | sort > $config{'datadir'}/wmlfiles");
}

sub obtain_files
{
    my @list;
    return unless -s "$config{'datadir'}/wmlfiles.old";
    return unless -s "$config{'datadir'}/wmlfiles";
    if (open (IN, "diff $config{'datadir'}/wmlfiles.old $config{'datadir'}/wmlfiles|")) {
	while (<IN>) {
	    next until (/^[<>] \.\//);
	    s/^[<>] \.\///;
	    chomp ();
	    push (@list, $_);
	}
	close (IN);
    }
    return @list;
}

chdir ($config{'wmldir'}) || die;

use Getopt::Std;
$opt_d = 0;
unless (getopts('d')) {
	print <<_END_;
Usage: $0 [-d]

This script finds new translations and translations that have been
removed and touches the translations so they rebuild and include a
link to the new ones and remove links to old ones.

  -d  Remove files, just not report.
_END_
	exit;
}

make_listing ();

@files = obtain_files ();

foreach $file (@files) {
    @components = split (/\//, $file);
    shift @components;
    my $cmd = "touch */" . join '/', @components;
    printf "$cmd\n";
    if ($opt_d) {
      system($cmd) == 0 or die;
    }
}
