#!/usr/bin/perl -w

# Usage: make_all.pl <file1> <file2>...

# 	This will update every version of <file?>, each of which should be
#	the path to a .wml file (without the language directory).

# Note: this script was previously known as new_translation.pl.
# That functionality is replaced by touch_old_files.pl.

require 5.001;
use strict;

# This module resides under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Webwml::Langs;

my $l = Webwml::Langs->new();
my %langs = $l->name_iso();
my @languages = $l->names();

if (!@ARGV) {
  open SELF, "<$0" or die "Unable to display help: $!\n";
  HELP: while (<SELF>)
  {
    last HELP if (/^require/);
    s/^# ?//;
    next if /^!/;
    print;
  }
  exit;
}

foreach my $file (@ARGV) {
  $file =~ s,^english/,,;
  my $path = ""; my $filename = $file;
  if ($file =~ m,(.*)/([^/]+)$,) { $path = $1; $filename = $2; };
  foreach my $lang (@languages) {
      if ( -f "$lang/$file" ) {
         my $pid = fork;
         if ($pid) { # parent
            # do nothing
         }
         else {      # child
            print "Making the " . ucfirst $lang . " copy:\n";
            system("make -C $lang/$path -W $filename install SUBS="); # no need to handle make's errors
            exit 0;
         }
         waitpid($pid,0);
      }
      else {
         print "The file isn't translated into " . ucfirst $lang . ".\n";
      }
  }
}
