#!/usr/bin/perl -w

# This script is used during build of English documents to check if
# translations are up-to date.

# This script takes full path to a original .wml file, and the language of
# the original.
# For every language defined in @langs, the script:
#	- checks if a translated file exists for such language
#	- checks if the translated file is at least N revisions old
#	  (N is any number defined in @stages)
#	- if it is, and it hasn't been touched because of this particular
#	  "N", it is touched and a marker file is created
# This allows the file to be rebuilt _exactly_ the number of times it should
# (i.e. $#stages times)

# (C) 2000 by Marcin Owsiany <porridge@pandora.info.bielsko.pl>

# TODOs:
#	- compare both major and minor revision number
#	- think of a better way to check when the file has been rebuilt last


# This should contain all languages
%langs = (
	"ar" => "arabic",
	"zh" => "chinese",
	"hr" => "croatian",
	"da" => "danish",
	"nl" => "dutch",
	"el" => "hellas",
	"en" => "english",
	"eo" => "esperanto",
	"fi" => "finnish",
	"fr" => "french",
	"de" => "german",
	"hu" => "hungarian",
	"it" => "italian",
	"ja" => "japanese",
	"ko" => "korean",
	"no" => "norwegian",
	"pl" => "polish",
	"pt" => "portuguese",
	"ro" => "romanian",
	"ru" => "russian",
	"es" => "spanish",
	"sv" => "swedish",
	"tr" => "turkish");

@langs = values(%langs);

# Set this to 1 for debugging
$debug = 0;

sub rebuild {
    my $file = shift;
    $now = time;
    print "touching $file\n" if $debug;
    utime $now, $now, $file or die "$file: $!";
}

sub mark_forced {
    my $file = shift;
    my $val = shift;
    my $foo = "$file".".forced";
    open LOG, ">$foo" or die "$foo: $!";
    print LOG "$val";
    close LOG;
    print "Created $file.forced with $val inside\n" if $debug;
}

sub was_forced {
    my $file = shift;
    if (open LOG, "<$file.forced") {
        close LOG;
        print "$file.forced exists\n" if $debug;
        return 1;
    } else {
        print "$file.forced does not exists\n" if $debug;
        return 0;
    }
}

sub when_forced {
    my $file = shift;
    if (open LOG, "<$file.forced") {
        $_ = <LOG>;
        chomp($_);
        print "$file.forced contains $_"."\n" if $debug;
        close LOG;
        return $_;
    } else {
        print "$file.forced : $!\n" if $debug;
        return 0;
    }
}

$argfile = $ARGV[0] or die "Invalid number of arguments";
die "Invalid number of arguments" unless $ARGV[1];
$arglang = $langs{$ARGV[1]} or die "Invalid lang argument: $ARGV[1]";
$argfile =~ m+(.*)/(.*)\.wml+ or die "pattern does not match";
my ($path, $file) = ($1, $2);

# Get the revision of the original file
my $origrev;
if (open FILE, "${path}/CVS/Entries") {
  while (<FILE>) {
    if (m,^/$file.wml/([^/]+)/,) {
        $origrev = $1;
        last;
    }
  }
} else {
    $origrev = "1.0";
}

foreach $lang (@langs) {
    next if ($lang eq $arglang);
    my $transfile = $argfile;
    my ($maxdelta, $mindelta) = (5, 2);
    my ($original, $langrev);
    print "Now checking $lang\n" if $debug;
    $transfile =~ s+$arglang+$lang+ or die "wrong argument: pattern does not match file: $transfile";

    # Parse the translated file
    open FILE, "$transfile" or next;
    while (<FILE>) { 
        if (/translation-check translation="([.0-9]*)"\s*(.*)/oi) {
            $langrev = $1;
            my $stuff = $2;
            if ($stuff =~ /original="([^"]+)"/) {
                $original = $1;
            }
            if ($stuff =~ /maxdelta="([^"]+)"/) {
                $maxdelta = $1;
            }
            if ($stuff =~ /mindelta="([^"]+)"/) {
                $mindelta = $1;
            }
            last;
        }
    }
    close FILE;
    next if not defined $langrev;
    # TODO - would cause unspecified results if 1. changed to 2.
    $origrev =~ s/1\.//;
    $langrev =~ s/1\.//;
    
    next unless not defined $original or $original eq $arglang;

    # Compare the revisions
    print "Orig: $origrev, lang: $langrev\n" if $debug;
    $difference = $origrev-$langrev;
    if ($difference < $mindelta) {
        next unless was_forced($transfile);
        print "unlinking $transfile.forced\n" if $debug;
        unlink "$transfile.forced";
        next;
    }
    my $forced_at = when_forced($transfile);
    if ($difference < $maxdelta) {
        if ($forced_at != $mindelta) {
            print "difference matches $mindelta, but wasn't rebuilt at $mindelta\n" if $debug;
            rebuild($transfile);
            mark_forced($transfile, $mindelta);
            last;
        }
    } elsif ($forced_at != $maxdelta) {
        print "difference matches $maxdelta, but wasn't rebuilt at $maxdelta\n" if $debug;
        rebuild($transfile);
        mark_forced($transfile, $maxdelta);
        last;
    }
}
