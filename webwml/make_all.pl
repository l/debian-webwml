#!/usr/bin/perl -w

# Usage: new_translation.pl <file1> <file2>...

# 	This will update every version of <file?>, each of which should be
#	the path to a .wml file (without the language directory).

# Note: this script old functionality is replaced by touch_old_files.pl

require 5.001;
use strict;

# This module resides under webwml/Perl
use lib ($0 =~ m|(.*)/|, $1 or ".") ."/Perl";
use Webwml::Langs;

my $l = Webwml::Langs->new();
my %langs = $l->name_iso();

#print "$_ $langs{$_}\n" foreach (keys %langs); exit;

my (@languages, @parts, $file, $filename, $lang, $path, $pid);

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

opendir(DIR, ".") || die "can't open directory $!";
@languages = grep { /^\w+$/ && -d $_ } readdir(DIR);
closedir DIR;
# print @languages;

my $relhtmlbase = "../debian.org/";

foreach $file (@ARGV) {
  $file =~ s,^english/,,;
  my $level = 0;
  my $destfile = "";
  my @parts = split '/', $file;
  my $dir = pop @parts;
  my $path = join '/', @parts;
# system ("mkdir -p $relhtmlbase$path");
  while ($dir) { $destfile .= "../"; $dir = pop @parts; }
  $destfile .= $relhtmlbase . $file;
  foreach $lang (@languages) {
      next if ($lang eq "CVS");
      if ( -f "$lang/$file" ) {
         $pid = fork;
         if ($pid) { # parent
            # do nothing
         }
         else {      # child
	    $destfile =~ s/.wml$/.$langs{$lang}.html/;
            print "Making the " . ucfirst $lang . " copy:\n";
            system("make -C $lang/$path $destfile") == 0 or die "$!\n";
            exit 0;
         }
         waitpid($pid,0);
      }
      else {
         print "The file isn't translated into " . ucfirst $lang . ".\n";
      }
  }
}
