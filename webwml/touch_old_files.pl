#! /usr/bin/perl

# this script finds new files and touches old ones so that the list of
# languages at the bottom is updated to include the new file.
# or something like that. made by Joey.

%config = ('wmldir'  => '/org/www.debian.org/webwml',
	   'datadir' => '/org/www.debian.org/cron/scripts_daily',
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
    return if (! -f "$config{'datadir'}/wmlfiles.old" || ! -f "$config{'datadir'}/wmlfiles");
    if (open (IN, "diff -0 $config{'datadir'}/wmlfiles.old $config{'datadir'}/wmlfiles|")) {
	while (<IN>) {
	    next until (/^> \.\//);
	    s/^> \.\///;
	    chomp ();
	    push (@list, $_);
	}
	close (IN);
    }
    return @list;
}

chdir ($config{'wmldir'});

make_listing ();

@new_files = obtain_files ();

foreach $file (@new_files) {
    @components = split (/\//, $file);
    shift @components;
    # printf "%s\t%s\n", $file, join ("/", @components);
    printf "touch */%s;\n", join ("/", @components);
}
